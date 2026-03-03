import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:trip_wise_nepal/features/booking/presentation/pages/esewa_webview_page.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
    Future<void> _refreshBookingAndUpdateUI() async {
      await ref.read(bookingViewModelProvider.notifier).getBookingById(widget.bookingId);
      final refreshedBooking = ref.read(bookingViewModelProvider).selectedBooking;
      if (mounted) setState(() {});
    }
  Future<void> _startEsewaPayment({required double amount, required String bookingId, required BuildContext context}) async {
    try {
      final dio = Dio();
      final bookingState = ref.read(bookingViewModelProvider);
      final booking = bookingState.selectedBooking;
      final token = '';
      // If you store token in provider or elsewhere, replace '' with correct value
      final response = await dio.post(
        'http://10.0.2.2:5050/api/payment/esewa/initiate',
        data: {
          'amount': amount,
          'bookingId': bookingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data['esewaUrl'] != null && response.data['formData'] != null) {
        final esewaUrl = response.data['esewaUrl'] ?? '';
        dynamic formData = response.data['formData'] ?? {};
        if (formData is String) {
          try {
            formData = Map<String, dynamic>.from(jsonDecode(formData));
          } catch (e) {}
        }
        if (esewaUrl.isNotEmpty && formData is Map && formData.isNotEmpty) {
          final fields = formData.map((key, value) => MapEntry(key.toString(), value.toString()));
          final paymentResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EsewaWebViewPage(
                formAction: esewaUrl,
                fields: fields,
              ),
            ),
          );
          if (paymentResult == true) {
            try {
              final transactionUuid = booking?.transactionUuid ?? booking?.transaction_uuid ?? fields['transaction_uuid'] ?? '';
              final productCode = fields['product_code'] ?? 'EPAYTEST';
              final totalAmount = fields['total_amount'] ?? amount.toString();
              if (transactionUuid.isNotEmpty) {
                final response = await dio.get(
                  'http://10.0.2.2:5050/api/payment/esewa/success',
                  queryParameters: {
                    'product_code': productCode,
                    'total_amount': totalAmount,
                    'transaction_uuid': transactionUuid,
                  },
                );
              }
            } catch (e) {}
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment successful!')),
            );
            await _refreshBookingAndUpdateUI();
          } else if (paymentResult == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed or cancelled.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initiate eSewa payment. Please try again.')),
          );
        }
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to initiate eSewa payment.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating eSewa payment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final booking = bookingState.selectedBooking;
    if (booking == null || booking.id != widget.bookingId) {
      if (bookingState.status == BookingStatus.error) {
        return Scaffold(
          appBar: AppBar(title: const Text('Booking Detail')),
          body: Center(child: Text(bookingState.errorMessage ?? 'Booking not found.')),
        );
      }
      Future.microtask(() => ref.read(bookingViewModelProvider.notifier).getBookingById(widget.bookingId));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    double basePrice = (booking.totalPrice ?? 0) / 1.13;
    double tax = (booking.totalPrice ?? 0) - basePrice;
    double extrasTotal = 0.0;
    if (booking.extras.isNotEmpty) {
      for (final extra in booking.extras) {
        extrasTotal += extra.total;
      }
    }

    Future<void> _refreshBookingAndUpdateUI() async {
      await ref.read(bookingViewModelProvider.notifier).getBookingById(widget.bookingId);
      final refreshedBooking = ref.read(bookingViewModelProvider).selectedBooking;
      if (mounted) setState(() {});
    }

    String? expiresAtStr;
    if (booking.expiresAt != null) {
      try {
        final dt = DateTime.parse(booking.expiresAt!);
        expiresAtStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
    String paymentStatusRaw = booking.paymentStatus ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BottomScreenLayout(initialIndex: 2),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((paymentStatusRaw == 'pending' || paymentStatusRaw == 'unpaid') && expiresAtStr != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your booking will expire 2 hours after creation (Expires at: $expiresAtStr). Please complete payment before expiry.',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.accommodationName ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Room Type: ${booking.roomTypeName ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text('Check-in: ${booking.checkIn?.toLocal().toString().split(' ')[0] ?? ''}'),
                    Text('Check-out: ${booking.checkOut?.toLocal().toString().split(' ')[0] ?? ''}'),
                    Text('Nights: ${booking.checkOut != null && booking.checkIn != null ? booking.checkOut.difference(booking.checkIn).inDays : ''}'),
                    Text('Guests: ${booking.guests.toString()}'),
                    Text('Rooms: ${booking.roomsBooked.toString()}'),
                    if ((booking.status ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Booking Status: ${booking.status ?? ''}'),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text(
                          paymentStatusRaw,
                          style: TextStyle(
                            color: paymentStatusRaw == 'paid'
                                ? Colors.green
                                : paymentStatusRaw == 'pending' || paymentStatusRaw == 'unpaid'
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (booking.specialRequest != null && booking.specialRequest!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Special Request:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(booking.specialRequest!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Optional Extras
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Optional Extras', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (booking.extras.isEmpty)
                      const Text('No extras info available.')
                    else ...[
                      ...booking.extras.map((extra) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${extra.name} x${extra.quantity}'),
                          Text('Rs. ${extra.total.toStringAsFixed(2)}'),
                        ],
                      )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Price Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Room Subtotal:'),
                        Text('Rs. ${basePrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Extras:'),
                        Text('Rs. ${extrasTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (13%):'),
                        Text('Rs. ${tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rs. ${(booking.totalPrice ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Payment button for unpaid bookings
            if (paymentStatusRaw == 'pending' || paymentStatusRaw == 'unpaid') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    // Directly start eSewa payment flow here
                    await _startEsewaPayment(
                      amount: booking.totalPrice,
                      bookingId: booking.id,
                      context: context,
                    );
                    await _refreshBookingAndUpdateUI();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136767),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Pay with eSewa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
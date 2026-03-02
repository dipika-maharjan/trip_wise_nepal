import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/esewa_webview_page.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_list_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen_layout.dart';

class BookingDetailScreen extends ConsumerWidget {

    // Removed simulation. Use real WebView payment below.
  final String bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final booking = bookingState.selectedBooking;
    debugPrint('Booking paymentStatus: \\${booking?.paymentStatus}');
    // If not loaded or wrong booking, fetch
    if (booking == null || booking.id != bookingId) {
      if (bookingState.status == BookingStatus.error) {
        return Scaffold(
          appBar: AppBar(title: const Text('Booking Detail')),
          body: Center(child: Text(bookingState.errorMessage ?? 'Booking not found.')),
        );
      }
      // ignore: unused_result
      Future.microtask(() => ref.read(bookingViewModelProvider.notifier).getBookingById(bookingId));
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

    // Format expiry if available
    String? expiresAtStr;
    if (booking.expiresAt != null) {
      try {
        final dt = DateTime.parse(booking.expiresAt!);
        expiresAtStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
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
            if ((booking.paymentStatus == null || booking.paymentStatus == 'pending' || booking.paymentStatus == 'unpaid') && expiresAtStr != null) ...[
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
                      if ((booking.paymentStatus ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('Payment Status: ${booking.paymentStatus ?? ''}'),
                      ],
                    ],
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
            // Special Requests (field not present in BookingEntity, so skip or add if available in future)
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
            if (booking.paymentStatus == null || booking.paymentStatus == 'pending' || booking.paymentStatus == 'unpaid') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      print('Starting payment initiation...');
                      final uri = Uri.parse('http://192.168.101.10:5050/api/payment/esewa/initiate');
                      print('POST to: ' + uri.toString());
                      print('POST body: bookingId=' + booking.id);
                      final response = await http.post(
                        uri,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'bookingId': booking.id,
                          'amount': booking.totalPrice ?? 0,
                        }),
                      );
                      print('Response status: ' + response.statusCode.toString());
                      print('Response body: ' + response.body);
                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        final formAction = data['esewaUrl'];
                        final fieldsRaw = data['formData'];
                        if (formAction == null || fieldsRaw == null) {
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Payment Error'),
                              content: const Text('Invalid payment response from server.'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                            ),
                          );
                          return;
                        }
                        final fields = (fieldsRaw as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => EsewaWebViewPage(
                              formAction: formAction.toString(),
                              fields: fields,
                            ),
                          ),
                        );
                        if (result == true) {
                          // Refresh booking to update payment status
                          await ref.read(bookingViewModelProvider.notifier).getBookingById(bookingId);
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('eSewa Payment'),
                              content: const Text('Payment Successful!'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                            ),
                          );
                        } else if (result == false) {
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('eSewa Payment'),
                              content: const Text('Payment Failed or Cancelled.'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                            ),
                          );
                        }
                      } else {
                        debugPrint('Payment initiation failed. Status: ${response.statusCode}');
                        debugPrint('Response body: ${response.body}');
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Payment initiation failed'),
                            content: Text('Status: ${response.statusCode}\n${response.body}'),
                            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                          ),
                        );
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Payment initiation failed (Status: ${response.statusCode}): ${response.body}')),
                        );
                      }
                    } catch (e, st) {
                      print('Exception during payment initiation: $e');
                      print('Stacktrace: $st');
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Payment initiation error'),
                          content: Text('Exception: $e'),
                          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                        ),
                      );
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Payment initiation failed: $e')),
                      );
                    }
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

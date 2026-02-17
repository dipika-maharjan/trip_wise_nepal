import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final booking = bookingState.selectedBooking;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Text('Guests: ${booking.guests ?? ''}'),
                    Text('Rooms: ${booking.roomsBooked ?? ''}'),
                    if ((booking.status ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Booking Status: ${booking.status ?? ''}'),
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
          ],
        ),
      ),
    );
  }
}

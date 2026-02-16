import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final booking = bookingState.selectedBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
      ),
      body: bookingState.status == BookingStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const Center(child: Text('Booking not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accommodation ID: ${booking.accommodationId}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Room Type ID: ${booking.roomTypeId}'),
                      const SizedBox(height: 8),
                      Text('Status: ${booking.status}'),
                      const SizedBox(height: 8),
                      Text('Check-in: ${booking.checkIn.toLocal()}'),
                      const SizedBox(height: 8),
                      Text('Check-out: ${booking.checkOut.toLocal()}'),
                      const SizedBox(height: 8),
                      Text('Total Price: Rs. ${booking.totalPrice.toStringAsFixed(2)}'),
                      // Add more fields as needed
                    ],
                  ),
                ),
    );
  }
}

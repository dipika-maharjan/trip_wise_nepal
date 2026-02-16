import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    // Only fetch once
    Future.microtask(() {
      if (!_fetched) {
        ref.read(bookingViewModelProvider.notifier).getBookings();
        _fetched = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _buildBody(bookingState),
    );
  }

  Widget _buildBody(BookingState state) {
    if (state.status == BookingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.status == BookingStatus.error) {
      return Center(child: Text(state.errorMessage ?? 'Error loading bookings'));
    } else if (state.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have no bookings yet.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to accommodation booking screen
              },
              child: const Text('Book Accommodation'),
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        itemCount: state.bookings.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final booking = state.bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  booking.accommodationImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            booking.accommodationImage,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel, size: 40),
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.hotel, size: 40),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.accommodationName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(booking.roomTypeName, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Check-in: ${_formatDate(booking.checkIn)}'),
                        Text('Check-out: ${_formatDate(booking.checkOut)}'),
                        Text('Guests: ${booking.guests}   Rooms: ${booking.roomsBooked}'),
                        Text('Status: ${booking.status[0].toUpperCase()}${booking.status.substring(1)}'),
                        Text('Total: Rs. ${booking.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to booking detail screen
                            },
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

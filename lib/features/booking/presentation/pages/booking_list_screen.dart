import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';

import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/remote/room_type_remote_datasource.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/remote/optional_extra_remote_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

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
          final accommodationImage = booking.accommodationImage.isNotEmpty ? booking.accommodationImage : '';
          final accommodationName = booking.accommodationName.isNotEmpty ? booking.accommodationName : 'N/A';
          final roomTypeName = booking.roomTypeName.isNotEmpty ? booking.roomTypeName : 'N/A';
          final checkIn = booking.checkIn;
          final checkOut = booking.checkOut;
          final guests = booking.guests;
          final roomsBooked = booking.roomsBooked;
          final status = (booking.status.isNotEmpty ? booking.status : 'unknown');
          final totalPrice = booking.totalPrice;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  accommodationImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            accommodationImage,
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
                          accommodationName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(roomTypeName, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Check-in: ${_formatDate(checkIn)}'),
                        Text('Check-out: ${_formatDate(checkOut)}'),
                        Text('Guests: $guests   Rooms: $roomsBooked'),
                        Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                        Text('Total: Rs. ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailScreen(bookingId: booking.id),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: (status == 'cancelled' || status == 'completed')
                                      ? null
                                      : () async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => const Center(child: CircularProgressIndicator()),
                                          );
                                          List<RoomTypeEntity> roomTypes = [];
                                          List<OptionalExtraApiModel> optionalExtras = [];
                                          String token = '';
                                          try {
                                            final apiClient = ApiClient();
                                            final roomTypeDS = RoomTypeRemoteDataSource(apiClient: apiClient);
                                            final optionalExtraDS = OptionalExtraRemoteDatasource(apiClient: apiClient);
                                            roomTypes = await roomTypeDS.getRoomTypesByAccommodationId(booking.accommodationId);
                                            optionalExtras = await optionalExtraDS.getOptionalExtrasByAccommodationId(booking.accommodationId);
                                            const storage = FlutterSecureStorage();
                                            token = await storage.read(key: 'auth_token') ?? '';
                                          } catch (e) {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to load booking data: $e')),
                                            );
                                            return;
                                          }
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookingFormScreen(
                                                accommodationId: booking.accommodationId,
                                                accommodationName: accommodationName,
                                                accommodationImage: accommodationImage,
                                                accommodationLocation: '',
                                                roomTypes: roomTypes,
                                                optionalExtras: optionalExtras,
                                                token: token,
                                                booking: booking,
                                                isEdit: true,
                                              ),
                                            ),
                                          );
                                        },
                                  child: const Text('Edit Booking'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: (status == 'cancelled' || status == 'completed')
                                      ? null
                                      : () async {
                                          try {
                                            // Get token from secure storage
                                            const storage = FlutterSecureStorage();
                                            final token = await storage.read(key: 'auth_token') ?? '';
                                            final dio = Dio();
                                            final response = await dio.patch(
                                              'http://10.0.2.2:5050/api/bookings/${booking.id}/cancel',
                                              options: Options(
                                                headers: {
                                                  'Authorization': 'Bearer $token',
                                                  'Content-Type': 'application/json',
                                                  'Accept': 'application/json',
                                                },
                                              ),
                                            );
                                            if (!mounted) return;
                                            if (response.statusCode == 200 && response.data['success'] == true) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Booking cancelled.')),
                                              );
                                              // Optionally refresh bookings list here
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(response.data['message'] ?? 'Cancel failed.')),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Cancel failed: ${e.toString()}')),
                                            );
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/utils/image_url_helper.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/pages/accommodation_detail_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_list_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/accommodation_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_detail_screen.dart';

// Utility function for formatting dates
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// Place this after imports, before any class definitions:
const String kImageBaseUrl = 'http://10.0.2.2:5050'; // Updated to match backend base URL

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String search = '';

  @override
  void initState() {
    super.initState();
    // Fetch user, bookings, and accommodations on load
    Future.microtask(() {
      ref.read(bookingViewModelProvider.notifier).getBookings();
      ref.read(accommodationViewModelProvider.notifier).getAccommodations();
    });
  }

  void handleSearch(String value) {
    setState(() => search = value);
    if (value.trim().isEmpty) {
      ref.read(accommodationViewModelProvider.notifier).getAccommodations();
    } else {
      ref.read(accommodationViewModelProvider.notifier).searchAccommodations(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final accommodationState = ref.watch(accommodationViewModelProvider);
    final bookings = bookingState.bookings;
    final accommodations = accommodationState.accommodations.where((a) => a.isActive).toList();
    final upcoming = bookings.where((b) => b.checkIn.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
    final upcomingBooking = upcoming.isNotEmpty ? upcoming.first : null;
    final recentBookings = bookings.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Color(0xFF0c7272), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Search Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: 400,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search destinations, places',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    ),
                    onChanged: handleSearch,
                  ),
                ),
              ),

              // Hero Section
              Stack(
                children: [
                  // Try to load the asset, fallback if it fails
                  FutureBuilder(
                    future: precacheImage(const AssetImage('assets/images/main-section.PNG'), context, onError: (e, s) {}),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.error == null) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/main-section.PNG'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.grey[300],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image not found', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Discover Your Nepal',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Personalized trips to breathtaking destinations.',
                            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9F1C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            onPressed: accommodations.isNotEmpty
                                ? () {
                                    // Scroll to For You section
                                    Scrollable.ensureVisible(forYouKey.currentContext!, duration: const Duration(milliseconds: 500));
                                  }
                                : null,
                            child: const Text('Explore Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // For You Section
              _ForYouSection(key: forYouKey, accommodations: accommodations, loading: accommodationState.status == AccommodationStatus.loading || accommodationState.status == AccommodationStatus.searching),
              const SizedBox(height: 32),

              // Upcoming Booking Card
              if (upcomingBooking != null) ...[
                Text('Your Next Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0c7272))),
                const SizedBox(height: 8),
                UpcomingBookingCard(booking: upcomingBooking),
                const SizedBox(height: 32),
              ],

              // Recent Bookings
              Text('Recent Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0c7272))),
              const SizedBox(height: 8),
              ...recentBookings.map((b) => RecentBookingCard(booking: b)).toList(),

              // Action Buttons
              const SizedBox(height: 32),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0c7272),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccommodationScreen(),
                            ),
                          );
                        },
                        child: const Text('Book Accommodation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0c7272),
                          side: const BorderSide(color: Color(0xFF0c7272)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingListScreen(),
                            ),
                          );
                        },
                        child: const Text('My Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  final forYouKey = GlobalKey();
}

class _ForYouSection extends StatelessWidget {
  final List<AccommodationEntity> accommodations;
  final bool loading;
  const _ForYouSection({Key? key, required this.accommodations, required this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('For You', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (loading)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
        if (!loading && accommodations.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No accommodations found. Try searching or check back later!', style: TextStyle(color: Colors.grey)))),
        if (!loading && accommodations.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: accommodations.length > 6 ? 6 : accommodations.length,
            itemBuilder: (context, index) {
              final acc = accommodations[index];
              final img = acc.images.isNotEmpty ? acc.images[0] : '';
              Widget imageWidget;
              if (img.isNotEmpty && (img.startsWith('http') || img.startsWith('https') || img.startsWith('/uploads/'))) {
                imageWidget = Image.network(
                  ImageUrlHelper.buildImageUrl(img),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                );
              } else if (img.isNotEmpty) {
                final assetPath = img.startsWith('assets/') ? img : 'assets/images/$img';
                imageWidget = Image.asset(
                  assetPath,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                );
              } else {
                imageWidget = Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.hotel, size: 40),
                );
              }
              return AspectRatio(
                aspectRatio: 1.1,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccommodationDetailScreen(accommodationId: acc.id ?? ''),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: imageWidget,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(acc.address, style: const TextStyle(fontSize: 12, color: Color(0xFF0c7272)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  child: Text(
                                    acc.overview,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}


// Upcoming Booking Card
class UpcomingBookingCard extends StatelessWidget {
  final BookingEntity booking;
  const UpcomingBookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(bookingId: booking.id),
            ),
          );
        },
        child: ListTile(
          leading: Icon(Icons.hotel, color: const Color(0xFF0c7272)),
          title: Text(booking.accommodationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room: ${booking.roomTypeName}'),
              Text('Check-in: ${formatDate(booking.checkIn)}'),
            ],
          ),
          trailing: Text(booking.status, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

// Recent Booking Card
class RecentBookingCard extends StatelessWidget {
  final BookingEntity booking;
  const RecentBookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(bookingId: booking.id),
            ),
          );
        },
        child: ListTile(
          leading: Icon(Icons.hotel, color: const Color(0xFF0c7272)),
          title: Text(booking.accommodationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room: ${booking.roomTypeName}'),
              Text('Check-in: ${formatDate(booking.checkIn)}'),
            ],
          ),
          trailing: Text(booking.status, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

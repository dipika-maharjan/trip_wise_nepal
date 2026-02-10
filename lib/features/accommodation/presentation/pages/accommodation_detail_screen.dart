import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/utils/snackbar_utils.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/utils/image_url_helper.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';

class AccommodationDetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;

  const AccommodationDetailScreen({
    super.key,
    required this.accommodationId,
  });

  @override
  ConsumerState<AccommodationDetailScreen> createState() =>
      _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState
    extends ConsumerState<AccommodationDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(accommodationViewModelProvider.notifier)
          .getAccommodationById(widget.accommodationId);
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accommodationState = ref.watch(accommodationViewModelProvider);

    ref.listen<AccommodationState>(accommodationViewModelProvider,
        (previous, next) {
      if (next.status == AccommodationStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(accommodationViewModelProvider.notifier).clearError();
      }
    });

    if (accommodationState.status == AccommodationStatus.loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF136767),
          ),
        ),
      );
    }

    final accommodation = accommodationState.selectedAccommodation;

    if (accommodation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accommodation'),
        ),
        body: const Center(
          child: Text('Accommodation not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(accommodation.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            if (accommodation.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: accommodation.images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: ImageUrlHelper.buildImageUrl(accommodation.images[index]),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF136767),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.hotel,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and address
                  Text(
                    accommodation.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Color(0xFF136767),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          accommodation.address,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating and reviews
                  if (accommodation.rating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          accommodation.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (accommodation.totalReviews != null)
                          Text(
                            ' (${accommodation.totalReviews} reviews)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Overview
                  Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: Color(0xFF136767),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF136767),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    accommodation.overview,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amenities
                  if (accommodation.amenities.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.home_work,
                          color: Color(0xFF136767),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Amenities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF136767),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...accommodation.amenities.map((amenity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF136767),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                amenity,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Eco-friendly highlights
                  if (accommodation.ecoFriendlyHighlights.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.eco,
                                color: Color(0xFF136767),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Eco-Friendly Highlights',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF136767),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...accommodation.ecoFriendlyHighlights.map((highlight) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🌱 ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Expanded(
                                    child: Text(
                                      highlight,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Location
                  if (accommodation.location != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF136767),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF136767),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coordinates: ${accommodation.location!.lat.toStringAsFixed(2)}, ${accommodation.location!.lng.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map integration coming soon',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Availability
                  if (accommodation.availableFrom != null &&
                      accommodation.availableUntil != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF136767),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Availability',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF136767),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_available,
                          color: Color(0xFF136767),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'From: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(accommodation.availableFrom!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_busy,
                          color: Color(0xFF136767),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'To: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(accommodation.availableUntil!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Price and Book Now Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF136767).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF136767).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price per night display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Rs. ${accommodation.pricePerNight.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF136767),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'per night',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Rating and reviews
                        if (accommodation.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                accommodation.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (accommodation.totalReviews != null)
                                Text(
                                  ' (${accommodation.totalReviews} reviews)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 20),

                        // Book now button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to booking screen
                              SnackbarUtils.showInfo(
                                context,
                                'Booking feature coming soon!',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF136767),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "You won't be charged yet",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

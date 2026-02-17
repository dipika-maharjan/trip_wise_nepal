import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/utils/snackbar_utils.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/utils/image_url_helper.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/remote/room_type_remote_datasource.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/remote/optional_extra_remote_datasource.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';

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
  List<RoomTypeEntity> _roomTypes = [];
  bool _roomTypesLoading = false;
  String? _roomTypesError;
  List<OptionalExtraApiModel> _optionalExtras = [];
  bool _optionalExtrasLoading = false;
  String? _optionalExtrasError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(accommodationViewModelProvider.notifier).getAccommodationById(widget.accommodationId);
      await _fetchRoomTypes();
      await _fetchOptionalExtras();
    });
  }

  Future<void> _fetchRoomTypes() async {
    setState(() { _roomTypesLoading = true; _roomTypesError = null; });
    try {
      final apiClient = ApiClient();
      final ds = RoomTypeRemoteDataSource(apiClient: apiClient);
      final types = await ds.getRoomTypesByAccommodationId(widget.accommodationId);
      print('[DEBUG] Room types fetched: count = \\${types.length}, data = \\${types.map((e) => e.name).toList()}');
      setState(() { _roomTypes = types; });
    } catch (e) {
      print('[DEBUG] Room types fetch error: $e');
      setState(() { _roomTypesError = 'Failed to load room types'; });
    } finally {
      setState(() { _roomTypesLoading = false; });
    }
  }

  Future<void> _fetchOptionalExtras() async {
    setState(() { _optionalExtrasLoading = true; _optionalExtrasError = null; });
    try {
      final apiClient = ApiClient();
      final ds = OptionalExtraRemoteDatasource(apiClient: apiClient);
      final extras = await ds.getOptionalExtrasByAccommodationId(widget.accommodationId);
      setState(() { _optionalExtras = extras; });
    } catch (e) {
      print('[DEBUG] Optional extras fetch error: $e');
      setState(() { _optionalExtrasError = 'Failed to load optional extras'; });
    } finally {
      setState(() { _optionalExtrasLoading = false; });
    }
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
                            onPressed: _roomTypesLoading ? null : () async {
                              final storage = const FlutterSecureStorage();
                              final token = await storage.read(key: 'auth_token') ?? '';
                              print('[DEBUG] Booking token: $token');
                              if (token.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No valid token found. Please log in again.')),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingFormScreen(
                                    accommodationId: accommodation.id ?? '',
                                    accommodationName: accommodation.name,
                                    accommodationImage: (accommodation.images.isNotEmpty)
                                      ? ImageUrlHelper.buildImageUrl(accommodation.images[0])
                                      : '',
                                    accommodationLocation: accommodation.address,
                                    roomTypes: _roomTypes,
                                    optionalExtras: _optionalExtras,
                                    token: token,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF136767),
                            ),
                            child: _roomTypesLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ),
                        if (_roomTypesError != null) ...[
                          const SizedBox(height: 8),
                          Text(_roomTypesError!, style: TextStyle(color: Colors.red)),
                        ],
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

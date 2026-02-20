import 'package:trip_wise_nepal/features/accommodation/presentation/state/review_notifier.dart';
import 'package:trip_wise_nepal/features/accommodation/data/services/review_service.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/review_state.dart';
import 'package:dio/dio.dart';
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


import 'package:trip_wise_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:trip_wise_nepal/features/auth/presentation/state/auth_state.dart';

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

class _AccommodationDetailScreenState extends ConsumerState<AccommodationDetailScreen> {
  int? _editingIndex;
  int? _editingRating;
  String? _editingComment;
  String _reviewSort = 'Latest';
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

                  // --- Insert the review section here ---
                  _buildReviewSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    final accommodationState = ref.watch(accommodationViewModelProvider);
    final accommodation = accommodationState.selectedAccommodation;
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    print('[DEBUG] ReviewSection: authState.status = \\${authState.status}, user = \\${user?.authId}, authState.user = \\${authState.user}');
    final reviewState = ref.watch(reviewNotifierProvider(accommodation?.id ?? ''));
    final reviewNotifier = ref.read(reviewNotifierProvider(accommodation?.id ?? '').notifier);

    // Fetch reviews on first build (only if not already loaded)
    if (accommodation != null && !reviewState.hasLoaded && !reviewState.isLoading) {
      Future.microtask(() => reviewNotifier.fetchReviews(refresh: true));
    }

    // Check if user can add review (logged in, not already reviewed)
    bool isLoggedIn = user != null && authState.status == AuthStatus.authenticated;
    bool hasReviewed = isLoggedIn && reviewState.reviews.any((r) => r.userId == user!.authId);

    // Review form state
    int? editingIndex = _editingIndex;
    int? editingRating = _editingRating;
    String? editingComment = _editingComment;
    final reviewController = TextEditingController(text: editingComment ?? '');

    Widget buildReviewForm({int? initialRating, String? initialComment, required void Function(int rating, String comment) onSubmit, void Function()? onCancel}) {
      int selectedRating = initialRating ?? 0;
      final commentController = TextEditingController(text: initialComment ?? '');
      final isEditing = onCancel != null;
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(5, (i) => IconButton(
                    icon: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => selectedRating = i + 1),
                  )),
                ],
              ),
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Write your review...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF136767),
                    ),
                    onPressed: () {
                      if (selectedRating > 0 && commentController.text.trim().isNotEmpty) {
                        onSubmit(selectedRating, commentController.text.trim());
                      }
                    },
                    child: Text(isEditing ? 'Update' : 'Submit'),
                  ),
                  if (onCancel != null)
                    TextButton(onPressed: onCancel, child: const Text('Cancel')),
                ],
              ),
            ],
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 1),
        Row(
          children: [
            const Icon(Icons.reviews, color: Color(0xFF136767), size: 28),
            const SizedBox(width: 8),
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF136767),
              ),
            ),
            const Spacer(),
            if (accommodation?.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    accommodation!.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (accommodation.totalReviews != null)
                    Text(
                      ' (${accommodation.totalReviews})',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Add review form (if eligible)
        if (isLoggedIn && !hasReviewed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: buildReviewForm(
              onSubmit: (rating, comment) async {
                final acc = accommodation;
                if (acc == null || acc.id == null) return;
                await ref.read(reviewServiceProvider).createReview(
                  accommodationId: acc.id!, // safe non-null
                  rating: rating,
                  comment: comment,
                );
                reviewNotifier.resetLoaded();
                reviewNotifier.fetchReviews(refresh: true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
              },
            ),
          ),
        if (!isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Log in to add a review.', style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
          ),
        if (isLoggedIn && hasReviewed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('You have already reviewed this accommodation.', style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
          ),

        // Review list
        if (reviewState.isLoading)
          const Center(child: CircularProgressIndicator()),
        if (!reviewState.isLoading && reviewState.reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: const Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        if (reviewState.reviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewState.reviews.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, i) {
                    final review = reviewState.reviews[i];
                    final isOwn = isLoggedIn && review.userId == user?.authId;
                    final isEditing = editingIndex == i;
                    if (isEditing) {
                      return buildReviewForm(
                        initialRating: editingRating,
                        initialComment: editingComment,
                        onSubmit: (rating, comment) async {
                          await ref.read(reviewServiceProvider).updateReview(
                            reviewId: review.id,
                            rating: rating,
                            comment: comment,
                          );
                          setState(() {
                            _editingIndex = null;
                            _editingRating = null;
                            _editingComment = null;
                          });
                          reviewNotifier.resetLoaded();
                          reviewNotifier.fetchReviews(refresh: true);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review updated!')));
                        },
                        onCancel: () {
                          setState(() {
                            _editingIndex = null;
                            _editingRating = null;
                            _editingComment = null;
                          });
                        },
                      );
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          ...List.generate(5, (j) => Icon(
                            j < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          )),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              review.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(review.comment),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _formatDate(review.createdAt.toIso8601String()),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Edit',
                              onPressed: () {
                                setState(() {
                                  _editingIndex = i;
                                  _editingRating = review.rating;
                                  _editingComment = review.comment;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              tooltip: 'Delete',
                              onPressed: () async {
                                try {
                                  await ref.read(reviewServiceProvider).deleteReview(reviewId: review.id);
                                  reviewNotifier.resetLoaded();
                                  reviewNotifier.fetchReviews(refresh: true);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted!')));
                                } on DioException catch (e) {
                                  if (e.response?.statusCode == 404) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Review not found or not authorized.')),
                                    );
                                    reviewNotifier.resetLoaded();
                                    reviewNotifier.fetchReviews(refresh: true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete review: \\${e.response?.data?['message'] ?? e.toString()}')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete review: \\${e.toString()}')),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                // Add extra space to guarantee no overflow
                const SizedBox(height: 8),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

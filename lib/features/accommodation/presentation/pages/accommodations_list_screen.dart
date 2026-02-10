import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/app/routes/app_routes.dart';
import 'package:trip_wise_nepal/core/utils/snackbar_utils.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/pages/accommodation_detail_screen.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/utils/image_url_helper.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';

class AccommodationsListScreen extends ConsumerStatefulWidget {
  const AccommodationsListScreen({super.key});

  @override
  ConsumerState<AccommodationsListScreen> createState() =>
      _AccommodationsListScreenState();
}

class _AccommodationsListScreenState
    extends ConsumerState<AccommodationsListScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load accommodations on init
    Future.microtask(() {
      ref.read(accommodationViewModelProvider.notifier).getAccommodations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = ref.read(accommodationViewModelProvider);
      if (state.hasMore && state.status != AccommodationStatus.loading) {
        if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
          ref
              .read(accommodationViewModelProvider.notifier)
              .searchAccommodations(state.searchQuery!, loadMore: true);
        } else if (state.minPrice != null && state.maxPrice != null) {
          ref.read(accommodationViewModelProvider.notifier).filterByPriceRange(
                minPrice: state.minPrice!,
                maxPrice: state.maxPrice!,
                loadMore: true,
              );
        } else {
          ref
              .read(accommodationViewModelProvider.notifier)
              .getAccommodations(loadMore: true);
        }
      }
    }
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    ref.read(accommodationViewModelProvider.notifier).searchAccommodations(query);
  }

  void _handlePriceFilter() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    if (minPrice == null || maxPrice == null) {
      SnackbarUtils.showError(context, "Please enter valid prices");
      return;
    }

    if (minPrice < 0 || maxPrice < 0) {
      SnackbarUtils.showError(context, "Prices must be positive");
      return;
    }

    if (minPrice > maxPrice) {
      SnackbarUtils.showError(context, "Min price cannot exceed max price");
      return;
    }

    ref.read(accommodationViewModelProvider.notifier).filterByPriceRange(
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
    setState(() {
      _showFilters = false;
    });
  }

  void _handleClearFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    ref.read(accommodationViewModelProvider.notifier).clearFilters();
    setState(() {
      _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accommodationState = ref.watch(accommodationViewModelProvider);

    ref.listen<AccommodationState>(accommodationViewModelProvider, (previous, next) {
      if (next.status == AccommodationStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(accommodationViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodations'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search accommodations...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF136767)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF136767)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF136767),
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),

          // Price filter
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Price Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            prefixText: 'Rs ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            prefixText: 'Rs ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _handleClearFilters,
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handlePriceFilter,
                        child: const Center(
                          child: Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Accommodations list
          Expanded(
            child: _buildAccommodationsList(accommodationState),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationsList(AccommodationState state) {
    if (state.status == AccommodationStatus.loading &&
        state.accommodations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF136767),
        ),
      );
    }

    if (state.accommodations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No accommodations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (state.searchQuery != null || state.minPrice != null)
              TextButton(
                onPressed: _handleClearFilters,
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF136767),
      onRefresh: () async {
        _handleClearFilters();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.accommodations.length +
            (state.hasMore && state.status == AccommodationStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.accommodations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF136767),
                ),
              ),
            );
          }

          final accommodation = state.accommodations[index];
          return _buildAccommodationCard(accommodation);
        },
      ),
    );
  }

  Widget _buildAccommodationCard(accommodation) {
    return GestureDetector(
      onTap: () {
        AppRoutes.push(
          context,
          AccommodationDetailScreen(accommodationId: accommodation.id!),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: accommodation.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ImageUrlHelper.buildImageUrl(accommodation.images[0]),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF136767),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.hotel,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.hotel,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accommodation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accommodation.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (accommodation.rating != null)
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              accommodation.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (accommodation.totalReviews != null)
                              Flexible(
                                child: Text(
                                  ' (${accommodation.totalReviews})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${accommodation.pricePerNight.toStringAsFixed(0)} / night',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF136767),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/widgets/home_card.dart';
import 'package:trip_wise_nepal/widgets/search_field.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // simple tablet check
    final cardWidth = isTablet
        ? (screenWidth - 64) / 3 // 3 cards in a row for tablet
        : (screenWidth - 48) / 2; // 2 cards in a row for mobile

    return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Image.asset(
                    'assets/images/logo2.png',
                    fit: BoxFit.contain,
                    height: 75,
                  ),
                ),
                const Icon(
                    Icons.notifications_none,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            const SearchField(hintText: 'Search destinations'),
            const SizedBox(height: 16),

            // Top Card
            HomeCard(title: 'Top Destination', subtitle: 'Explore this amazing place'),
            const SizedBox(height: 16),

            // For You Section
            const Text('For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            HomeCard(title: 'Suggested for you', subtitle: 'Personalized recommendations'),
            const SizedBox(height: 16),

            // Popular Destination Section
            const Text('Popular Destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                4,
                    (index) => SizedBox(
                  width: cardWidth,
                  child: HomeCard(title: 'Popular Place', subtitle: 'Amazing view'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Eco-Friendly Picks Section
            const Text('Eco-Friendly Picks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                4,
                    (index) => SizedBox(
                  width: cardWidth,
                  child: HomeCard(title: 'Eco-Friendly', subtitle: 'Sustainable place'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
    );
  }
}

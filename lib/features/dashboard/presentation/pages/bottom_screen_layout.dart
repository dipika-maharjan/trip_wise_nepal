import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/booking_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/accommodation_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  final int initialIndex;
  const BottomScreenLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  late int _selectedIndex;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    AccommodationScreen(),
    BookingScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Accommodation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Color(0xFFA8C0A8),
        selectedItemColor: Color(0xFF136767),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

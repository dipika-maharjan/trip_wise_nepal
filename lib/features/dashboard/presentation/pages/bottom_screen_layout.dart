import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/booking_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/map_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const MapScreen(),
    const BookingScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
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
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

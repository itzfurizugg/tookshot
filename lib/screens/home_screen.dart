// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'camera_list_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    CameraListScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];
  
  final List<String> _titles = [
    'TookShot',
    'Histori',
    'Akun',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        // backgroundColor: Color(0xFF55829E),
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF55829E),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 0,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: 28),
              activeIcon: Icon(Icons.history, size: 28),
              label: 'Histori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
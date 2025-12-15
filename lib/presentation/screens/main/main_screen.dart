import 'package:finance_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:finance_app/presentation/screens/home/home_screen.dart';
import 'package:finance_app/presentation/screens/movements/movements_screen.dart';
import 'package:finance_app/presentation/screens/settings/settings_screen.dart';
import 'package:finance_app/presentation/screens/stats/stats_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // El Dashboard arranca seleccionado para mantenerlo como pestaña principal centrada.
  int _currentIndex = 2;

  // El IndexedStack conserva el estado de cada pestaña sin recrear sus contenidos.
  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    MovementsScreen(),
    DashboardScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Movements',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              size: 32,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

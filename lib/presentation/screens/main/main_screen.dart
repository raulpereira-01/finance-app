import 'package:finance_app/presentation/screens/home/home_screen.dart';
import 'package:finance_app/presentation/screens/movements/movements_screen.dart';
import 'package:finance_app/presentation/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Simplificamos la navegación a tres pestañas centradas en el flujo principal.
  int _currentIndex = 0;

  // El IndexedStack conserva el estado de cada pestaña sin recrear sus contenidos.
  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    MovementsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: l10n.homeTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: l10n.planTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}

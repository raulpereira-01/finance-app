import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Home / Summary')),
      body: Center(
        child: Text('Resumen rápido de la cuenta'),
      ),
    );
  }
}

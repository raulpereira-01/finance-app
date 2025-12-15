import 'package:flutter/material.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Movements')),
      body: Center(
        child: Text('Listado de movimientos'),
      ),
    );
  }
}

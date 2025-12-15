import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Center(
        child: Text('Indicadores y gráficos'),
      ),
    );
  }
}

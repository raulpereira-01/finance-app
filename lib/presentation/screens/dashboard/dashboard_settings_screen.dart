import 'package:flutter/material.dart';

import '../../../domain/entities/dashboard_widget_type.dart';

class DashboardSettingsScreen extends StatefulWidget {
  final Map<DashboardWidgetType, bool> enabledWidgets;

  const DashboardSettingsScreen({
    super.key,
    required this.enabledWidgets,
  });

  @override
  State<DashboardSettingsScreen> createState() =>
      _DashboardSettingsScreenState();
}

class _DashboardSettingsScreenState
    extends State<DashboardSettingsScreen> {
  late Map<DashboardWidgetType, bool> _state;

  @override
  void initState() {
    super.initState();
    _state = Map.from(widget.enabledWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize dashboard'),
      ),
      body: ListView(
        children: DashboardWidgetType.values.map((type) {
          return SwitchListTile(
            title: Text(type.title),
            value: _state[type] ?? false,
            onChanged: (value) {
              setState(() {
                _state[type] = value;
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _state);
        },
      ),
    );
  }
}

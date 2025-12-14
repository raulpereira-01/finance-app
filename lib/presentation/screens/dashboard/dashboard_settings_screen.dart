import 'package:finance_app/data/models/dashboard_config_model.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/dashboard_widget_type.dart';

class DashboardSettingsScreen extends StatefulWidget {
  final List<DashboardConfigModel> configs;

  const DashboardSettingsScreen({
    super.key,
    required this.configs, required Map<dynamic, dynamic> enabledWidgets,
  });

  @override
  State<DashboardSettingsScreen> createState() =>
      _DashboardSettingsScreenState();
}

class _DashboardSettingsScreenState extends State<DashboardSettingsScreen> {
  late List<DashboardConfigModel> _configs;

  @override
  void initState() {
    super.initState();
    _configs = widget.configs
        .map((c) => DashboardConfigModel(
      type: c.type,
      enabled: c.enabled,
      order: c.order,
    ))
        .toList();
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

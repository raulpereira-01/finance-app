import 'package:finance_app/data/models/dashboard_config_model.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/dashboard_widget_type.dart';

class DashboardSettingsScreen extends StatefulWidget {
  final List<DashboardConfigModel> configs;

  const DashboardSettingsScreen({
    super.key,
    required this.configs,
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
          final index = _configs.indexWhere((c) => c.type == type);
          final config = _configs[index];

          return SwitchListTile(
            title: Text(type.title),
            value: config.enabled,
            onChanged: (value) {
              setState(() {
                _configs[index] = DashboardConfigModel(
                  type: config.type,
                  enabled: value,
                  order: config.order,
                );
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _configs);
        },
      ),
    );
  }
}

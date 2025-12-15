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
        .map(
          (c) => DashboardConfigModel(
            type: c.type,
            enabled: c.enabled,
            order: c.order,
          ),
        )
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  IconData _iconForType(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.balance:
        return Icons.account_balance_wallet_outlined;
      case DashboardWidgetType.expensesByCategory:
        return Icons.pie_chart_outline;
      case DashboardWidgetType.incomeVsExpenses:
        return Icons.stacked_line_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize dashboard'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _configs),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _configs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final config = _configs[index];

          return ListTile(
            leading: Icon(_iconForType(config.type)),
            title: Text(config.type.title),
            trailing: Switch(
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
            ),
          );
        },
      ),
    );
  }
}

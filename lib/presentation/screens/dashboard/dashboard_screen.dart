import 'package:flutter/material.dart';

import '../../../domain/entities/dashboard_widget_type.dart';
import 'balance_widget.dart';
import 'dashboard_settings_screen.dart';
import 'expenses_by_category_pie_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _widgets = [
    const BalanceWidget(),
    const ExpensesByCategoryPieWidget(),
  ];
  final Map<DashboardWidgetType, bool> _enabledWidgets = {
    DashboardWidgetType.balance: true,
    DashboardWidgetType.expensesByCategory: true,
    DashboardWidgetType.incomeVsExpenses: false,
  };

  List<Widget> _buildDashboardWidgets() {
    final widgets = <Widget>[];

    if (_enabledWidgets[DashboardWidgetType.balance] == true) {
      widgets.add(const BalanceWidget());
    }
    if (_enabledWidgets[DashboardWidgetType.expensesByCategory] == true) {
      widgets.add(const ExpensesByCategoryPieWidget());
    }
    if (_enabledWidgets[DashboardWidgetType.incomeVsExpenses] == true) {
      widgets.add(const Placeholder());
    }

    return widgets;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push<Map<DashboardWidgetType, bool>>(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardSettingsScreen(
                    enabledWidgets: _enabledWidgets,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  _enabledWidgets.clear();
                  _enabledWidgets.addAll(result);
                });
              }
            },
          ),
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(16),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _widgets.removeAt(oldIndex);
            _widgets.insert(newIndex, item);
          });
        },
        children: [
          for (int i = 0; i < _buildDashboardWidgets().length; i++)
            Container(
              key: ValueKey(i),
              margin: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  _buildDashboardWidgets()[i],
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(Icons.drag_handle),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

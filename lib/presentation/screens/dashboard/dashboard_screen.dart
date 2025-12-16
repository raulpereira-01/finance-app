// Pantalla principal del dashboard que organiza widgets reordenables con métricas clave.
import 'package:flutter/material.dart';

import '../../../data/models/dashboard_config_model.dart';
import '../../../domain/entities/category_expense.dart';
import '../../../domain/entities/dashboard_widget_type.dart';
import '../../../domain/entities/monthly_summary.dart';
import '../../../domain/entities/selected_period.dart';
import '../../../domain/services/dashboard_config_service.dart';
import '../../../domain/services/expenses_by_category_service.dart';
import '../../../domain/services/monthly_summary_service.dart';
import '../../../domain/services/selected_period_service.dart';
import '../../widgets/period_selector.dart';
import 'balance_widget.dart';
import 'dashboard_settings_screen.dart';
import 'expenses_by_category_pie_widget.dart';
import 'income_vs_expenses_bar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<DashboardConfigModel> _configs;
  final _configService = DashboardConfigService();
  final _selectedPeriodService = SelectedPeriodService();
  final _monthlySummaryService = MonthlySummaryService();
  final _expensesByCategoryService = ExpensesByCategoryService();
  late SelectedPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _configs = _configService.load();
    _selectedPeriod = _selectedPeriodService.loadCurrent();
  }

  /// Devuelve SOLO los configs visibles, ordenados
  List<DashboardConfigModel> _visibleConfigs() {
    return [..._configs]
      ..sort((a, b) => a.order.compareTo(b.order))
      ..removeWhere((c) => !c.enabled);
  }

  /// Construye el widget según el tipo
  Widget _buildWidgetFromType(
    DashboardWidgetType type,
    MonthlySummary monthlySummary,
    List<CategoryExpense> categoryExpenses,
  ) {
    switch (type) {
      case DashboardWidgetType.balance:
        return const BalanceWidget();

      case DashboardWidgetType.expensesByCategory:
        return ExpensesByCategoryPieWidget(data: categoryExpenses);

      case DashboardWidgetType.incomeVsExpenses:
        return IncomeVsExpensesBarWidget(summary: monthlySummary);
    }
  }

  void _updatePeriod(SelectedPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _selectedPeriodService.saveCurrent(_selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleConfigs = _visibleConfigs();
    final categoryExpenses = _expensesByCategoryService.calculateForPeriod(
      _selectedPeriod,
    );
    final monthlySummary = _monthlySummaryService.calculateForMonthYear(
      _selectedPeriod.month,
      _selectedPeriod.year,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push<List<DashboardConfigModel>>(
                context,
                MaterialPageRoute(
                  builder: (_) => DashboardSettingsScreen(configs: _configs),
                ),
              );

              if (result != null) {
                setState(() {
                  _configs = result;
                  _configService.save(_configs);
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _updatePeriod,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;

                    final movedItem = visibleConfigs.removeAt(oldIndex);
                    visibleConfigs.insert(newIndex, movedItem);

                    // Reaplicamos el orden a la lista completa
                    for (int i = 0; i < visibleConfigs.length; i++) {
                      final indexInConfigs = _configs.indexWhere(
                        (c) => c.type == visibleConfigs[i].type,
                      );

                      _configs[indexInConfigs] = DashboardConfigModel(
                        type: _configs[indexInConfigs].type,
                        enabled: _configs[indexInConfigs].enabled,
                        order: i,
                      );
                    }

                    _configService.save(_configs);
                  });
                },
                children: [
                  for (final config in visibleConfigs)
                    Container(
                      key: ValueKey(config.type),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          _buildWidgetFromType(
                            config.type,
                            monthlySummary,
                            categoryExpenses,
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/entities/selected_period.dart';
import '../../../domain/services/expenses_by_category_service.dart';
import '../../../domain/services/monthly_summary_service.dart';
import '../../../domain/services/selected_period_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/period_selector.dart';
import '../dashboard/expenses_by_category_pie_widget.dart';
import '../dashboard/income_vs_expenses_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _selectedPeriodService = SelectedPeriodService();
  final _monthlySummaryService = MonthlySummaryService();
  final _expensesByCategoryService = ExpensesByCategoryService();

  late SelectedPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = _selectedPeriodService.loadCurrent();
  }

  void _onPeriodChanged(SelectedPeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
      _selectedPeriodService.saveCurrent(newPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monthlySummary = _monthlySummaryService.calculateForMonthYear(
      _selectedPeriod.month,
      _selectedPeriod.year,
    );
    final categoryExpenses = _expensesByCategoryService.calculateForPeriod(
      _selectedPeriod,
    );

    final balance = monthlySummary.income - monthlySummary.expenses;
    final isPositive = balance >= 0;
    final balanceColor = isPositive ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.periodIncome,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(monthlySummary.income.toStringAsFixed(2)),
                        const SizedBox(height: 8),
                        Text(l10n.periodExpenses,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(monthlySummary.expenses.toStringAsFixed(2)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.balance,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          balance.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                        Text(
                          isPositive
                              ? l10n.positiveBalanceHint
                              : l10n.negativeBalanceHint,
                          style: TextStyle(color: balanceColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  IncomeVsExpensesBarWidget(summary: monthlySummary),
                  const SizedBox(height: 12),
                  ExpensesByCategoryPieWidget(data: categoryExpenses),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

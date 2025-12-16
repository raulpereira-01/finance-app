// Paso del onboarding para capturar los gastos fijos mensuales del usuario.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import 'onboarding_summary_screen.dart';

class OnboardingFixedExpensesScreen extends StatefulWidget {
  const OnboardingFixedExpensesScreen({super.key});

  @override
  State<OnboardingFixedExpensesScreen> createState() =>
      _OnboardingFixedExpensesScreenState();
}

class _OnboardingFixedExpensesScreenState
    extends State<OnboardingFixedExpensesScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _uuid = const Uuid();
  late Box<CategoryModel> _categoryBox;
  String? _selectedCategoryId;

  late Box<ExpenseModel> _expenseBox;

  @override
  void initState() {
    super.initState();
    _expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);
    _categoryBox = Hive.box<CategoryModel>(HiveBoxes.categories);
  }

  void _addExpense() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (name.isEmpty || amount == null || amount <= 0) {
      return;
    }

    if (_selectedCategoryId == null) return;

    final expense = ExpenseModel(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      date: DateTime.now(),
      isFixed: true,
      categoryId: _selectedCategoryId!,
      isRecurring: true,
      dayOfMonth: DateTime.now().day,
      startDate: DateTime.now(),
    );

    _expenseBox.put(expense.id, expense);

    _nameController.clear();
    _amountController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _expenseBox.values.where((e) => e.isFixed).toList();

    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Fixed expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Expense name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              hint: const Text('Select category'),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.emoji),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                child: const Text('Add expense'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ListTile(
                    title: Text(expense.name),
                    subtitle: Text(
                      categories
                          .firstWhere((c) => c.id == expense.categoryId)
                          .name,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: expenses.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingSummaryScreen(),
                  ),
                );
              },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

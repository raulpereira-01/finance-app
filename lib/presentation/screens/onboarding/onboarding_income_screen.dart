import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/income_model.dart';
import 'onboarding_fixed_expenses_screen.dart';

class OnboardingIncomeScreen extends StatefulWidget {
  const OnboardingIncomeScreen({super.key});

  @override
  State<OnboardingIncomeScreen> createState() => _OnboardingIncomeScreenState();
}

class _OnboardingIncomeScreenState extends State<OnboardingIncomeScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _uuid = const Uuid();
  int _selectedDay = DateTime.now().day;

  late Box<IncomeModel> _incomeBox;

  @override
  void initState() {
    super.initState();
    _incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
  }

  void _addIncome() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (name.isEmpty || amount == null || amount <= 0) {
      return;
    }

    final income = IncomeModel(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      startDate: DateTime.now(),
      dayOfMonth: _selectedDay,
    );

    _incomeBox.put(income.id, income);

    _nameController.clear();
    _amountController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final incomes = _incomeBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Income name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day of month',
              ),
              items: List.generate(31, (index) => index + 1)
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text('Day $day of every month'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDay = value);
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addIncome,
                child: const Text('Add income'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  return ListTile(
                    title: Text(income.name),
                    subtitle: Text('Every month on day ${income.dayOfMonth}'),
                    trailing: Text(income.amount.toStringAsFixed(2)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incomes.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingFixedExpensesScreen(),
                  ),
                );
              },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

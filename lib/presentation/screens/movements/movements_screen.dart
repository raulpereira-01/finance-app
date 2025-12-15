import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../categories/color_picker_dialog.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final _uuid = const Uuid();

  final _incomeNameController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  int _incomeDay = DateTime.now().day;

  final _categoryNameController = TextEditingController();
  String _selectedEmoji = '💸';
  Color _selectedColor = Colors.blue;

  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  DateTime _selectedExpenseDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isFixedExpense = false;
  bool _isRecurringExpense = false;
  int _expenseDay = DateTime.now().day;

  late Box<IncomeModel> _incomeBox;
  late Box<CategoryModel> _categoryBox;
  late Box<ExpenseModel> _expenseBox;

  @override
  void initState() {
    super.initState();
    _incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
    _categoryBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    _expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);
  }

  @override
  void dispose() {
    _incomeNameController.dispose();
    _incomeAmountController.dispose();
    _categoryNameController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _addIncome() {
    final name = _incomeNameController.text.trim();
    final amount = double.tryParse(_incomeAmountController.text);

    if (name.isEmpty || amount == null || amount <= 0) {
      return;
    }

    final income = IncomeModel(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      startDate: DateTime.now(),
      dayOfMonth: _incomeDay,
    );

    _incomeBox.put(income.id, income);

    _incomeNameController.clear();
    _incomeAmountController.clear();

    setState(() {});
  }

  void _addCategory() {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) return;

    final category = CategoryModel(
      id: _uuid.v4(),
      name: name,
      emoji: _selectedEmoji,
      colorValue: _selectedColor.value,
    );

    _categoryBox.put(category.id, category);
    _categoryNameController.clear();

    setState(() {});
  }

  Future<void> _pickExpenseDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedExpenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _selectedExpenseDate = result;
        _expenseDay = result.day;
      });
    }
  }

  Future<void> _showMissingCategoryDialog({required bool noCategories}) async {
    final message = noCategories
        ? 'Primero crea una categoría para poder registrar tus gastos.'
        : 'Selecciona una categoría antes de guardar el gasto.';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Categorías'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    final name = _expenseNameController.text.trim();
    final amount = double.tryParse(_expenseAmountController.text);

    if (name.isEmpty || amount == null || amount <= 0) return;
    if (_selectedCategoryId == null) {
      _showMissingCategoryDialog(noCategories: false);
      return;
    }

    final expense = ExpenseModel(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      date: _selectedExpenseDate,
      isFixed: _isFixedExpense,
      categoryId: _selectedCategoryId!,
      isRecurring: _isRecurringExpense,
      dayOfMonth: _isRecurringExpense ? _expenseDay : null,
      startDate: _isRecurringExpense ? _selectedExpenseDate : null,
    );

    _expenseBox.put(expense.id, expense);

    _expenseNameController.clear();
    _expenseAmountController.clear();
    _isFixedExpense = false;
    _isRecurringExpense = false;
    _expenseDay = DateTime.now().day;

    setState(() {});
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);

  Widget _buildIncomeTab() {
    final incomes = _incomeBox.values.toList()
      ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Planifica tus ingresos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _incomeNameController,
                  decoration: const InputDecoration(labelText: 'Nombre del ingreso'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _incomeAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Monto mensual'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _incomeDay,
                  decoration: const InputDecoration(
                    labelText: 'Día del mes',
                  ),
                  items: List.generate(31, (index) => index + 1)
                      .map(
                        (day) => DropdownMenuItem(
                          value: day,
                          child: Text('El día $day de cada mes'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _incomeDay = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addIncome,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Guardar ingreso'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ingresos recurrentes (${incomes.length})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (incomes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no has añadido ingresos.'),
            ),
          )
        else
          ...incomes.map(
            (income) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text('${income.dayOfMonth}'),
                ),
                title: Text(income.name),
                subtitle: Text('Se repite cada mes el día ${income.dayOfMonth}'),
                trailing: Text(_formatMoney(income.amount)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpensesTab() {
    final categories = _categoryBox.values.toList();
    final expenses = _expenseBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    void attemptAddExpense() {
      if (categories.isEmpty) {
        _showMissingCategoryDialog(noCategories: true);
        return;
      }

      _addExpense();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Registra tus gastos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _expenseNameController,
                  decoration: const InputDecoration(labelText: 'Concepto'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _expenseAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Monto'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${_selectedExpenseDate.day}/${_selectedExpenseDate.month}/${_selectedExpenseDate.year}',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickExpenseDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: const Text('Cambiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isRecurringExpense)
                  DropdownButtonFormField<int>(
                    value: _expenseDay,
                    decoration: const InputDecoration(
                      labelText: 'Se repite cada mes el día…',
                    ),
                    items: List.generate(31, (index) => index + 1)
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text('Día $day de cada mes'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _expenseDay = value);
                      }
                    },
                  ),
                if (_isRecurringExpense) const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  hint: const Text('Selecciona categoría'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(category.colorValue),
                                child: Text(category.emoji),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: categories.isEmpty
                      ? null
                      : (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('¿Es un gasto fijo?'),
                  value: _isFixedExpense,
                  onChanged: (value) => setState(() => _isFixedExpense = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repetir automáticamente cada mes'),
                  value: _isRecurringExpense,
                  onChanged: (value) => setState(() {
                    _isRecurringExpense = value;
                    if (value) {
                      _expenseDay = _selectedExpenseDate.day;
                    }
                  }),
                  subtitle: const Text('Ideal para alquileres, suscripciones, etc.'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: attemptAddExpense,
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Guardar gasto'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gastos recientes (${expenses.length})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (expenses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Todavía no has añadido gastos.'),
            ),
          )
        else
          ...expenses.map((expense) {
            final category = categories.firstWhere(
              (c) => c.id == expense.categoryId,
              orElse: () => CategoryModel(
                id: 'unknown',
                name: 'Sin categoría',
                emoji: '❓',
                colorValue: Colors.grey.value,
              ),
            );

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  child: Text(category.emoji),
                ),
                title: Text(expense.name),
                subtitle: Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}' +
                      (expense.isRecurring
                          ? ' · Recurrente día ${expense.dayOfMonth ?? expense.date.day}'
                          : '') +
                      (expense.isFixed ? ' · Fijo' : ''),
                ),
                trailing: Text(_formatMoney(expense.amount)),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    final categories = _categoryBox.values.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Crea categorías que puedas reutilizar para tus gastos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedEmoji,
                      items: const ['💸', '🏠', '🚗', '🍔', '📱', '🎮', '🎓']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: const TextStyle(fontSize: 20)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedEmoji = value);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (_) => ColorPickerDialog(selected: _selectedColor),
                        );
                        if (color != null) {
                          setState(() => _selectedColor = color);
                        }
                      },
                      child: CircleAvatar(backgroundColor: _selectedColor),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Categorías (${categories.length})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (categories.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Crea tu primera categoría para clasificar tus gastos.'),
            ),
          )
        else
          ...categories.map(
            (category) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  child: Text(category.emoji),
                ),
                title: Text(category.name),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plan mensual'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ingresos'),
              Tab(text: 'Gastos'),
              Tab(text: 'Categorías'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncomeTab(),
            _buildExpensesTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }
}

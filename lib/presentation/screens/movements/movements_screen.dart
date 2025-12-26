// Pantalla de movimientos para registrar ingresos, gastos y categorías desde formularios rápidos.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../core/voice_intent_parser.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../domain/services/voice_transaction_service.dart';
import '../categories/color_picker_dialog.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  static const _voskChannel = MethodChannel('com.finance_app/vosk');
  static const _voskResultsChannel = EventChannel('com.finance_app/vosk/results');

  final _uuid = const Uuid();
  final _voiceService = VoiceTransactionService(parser: VoiceIntentParser());

  final _incomeFormKey = GlobalKey<FormState>();
  final _expenseFormKey = GlobalKey<FormState>();

  final _incomeNameController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  int _incomeDay = DateTime.now().day;
  bool _showIncomeErrors = false;

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
  bool _showExpenseErrors = false;

  StreamSubscription<dynamic>? _voiceSubscription;
  bool _isListening = false;
  String? _lastTranscript;
  VoiceTransactionDraft? _voiceDraft;
  String? _voiceError;

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
    _voiceSubscription?.cancel();
    super.dispose();
  }

  void _addIncome() {
    final form = _incomeFormKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _showIncomeErrors = true);
      return;
    }

    final name = _incomeNameController.text.trim();
    final amount = _parseAmount(_incomeAmountController.text)!;

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
    FocusScope.of(context).unfocus();
    _showSnackBar('Ingreso guardado');

    setState(() {
      _showIncomeErrors = false;
    });
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
    _showSnackBar('Categoría creada');
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
    final form = _expenseFormKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() => _showExpenseErrors = true);
      return;
    }

    final name = _expenseNameController.text.trim();
    final amount = _parseAmount(_expenseAmountController.text)!;

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
    _selectedCategoryId = null;

    FocusScope.of(context).unfocus();
    _showSnackBar('Gasto guardado');

    setState(() {
      _showExpenseErrors = false;
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _voiceError = 'Permiso de micrófono denegado';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _voiceError = null;
      _lastTranscript = null;
    });

    try {
      await _voskChannel.invokeMethod('start', {
        'locale': 'es-ES',
      });
      _voiceSubscription ??=
          _voskResultsChannel.receiveBroadcastStream().listen((event) {
        if (event is String && event.isNotEmpty) {
          _handleTranscript(event);
        }
      });
    } catch (error) {
      setState(() {
        _voiceError = 'Error al iniciar el reconocimiento: $error';
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      await _voskChannel.invokeMethod('stop');
    } catch (_) {
      // Ignored: canal nativo puede no estar implementado en entornos de prueba.
    }

    await _voiceSubscription?.cancel();
    _voiceSubscription = null;

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _handleTranscript(String transcript) async {
    setState(() {
      _lastTranscript = transcript;
      _voiceError = null;
    });

    try {
      final draft = _voiceService.parseTranscript(transcript);

      setState(() {
        _voiceDraft = draft;
        _expenseNameController.text = draft.concept;
        _expenseAmountController.text = draft.amount.toStringAsFixed(2);
        _selectedCategoryId = draft.categoryId;
      });
    } on FormatException catch (error) {
      setState(() {
        _voiceError = error.message;
      });
    } catch (error) {
      setState(() {
        _voiceError = 'No se pudo procesar la transcripción: $error';
      });
    }
  }

  Future<void> _confirmVoiceDraft(List<CategoryModel> categories) async {
    final draft = _voiceDraft;
    if (draft == null) return;

    final parsedAmount = _parseAmount(_expenseAmountController.text);
    final amount = parsedAmount ?? draft.amount;
    if (amount <= 0) {
      setState(() {
        _voiceError = 'El monto debe ser mayor a cero';
      });
      return;
    }

    String? categoryId = draft.categoryId;
    String? categoryName = draft.categoryName;

    if (draft.intent == VoiceIntent.expense) {
      if (_selectedCategoryId != null) {
        categoryId = _selectedCategoryId;
        categoryName = categories
            .firstWhere((c) => c.id == _selectedCategoryId!)
            .name;
      }
    } else {
      categoryId = null;
    }

    final updatedDraft = draft.copyWith(
      concept: _expenseNameController.text.trim().isEmpty
          ? draft.concept
          : _expenseNameController.text.trim(),
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
    );

    await _voiceService.persistDraft(updatedDraft);

    setState(() {
      _voiceDraft = null;
      _lastTranscript = null;
      _selectedCategoryId = null;
    });

    _expenseNameController.clear();
    _expenseAmountController.clear();
    _showSnackBar('Transacción guardada desde voz');
  }

  Widget _buildVoiceAssistant(List<CategoryModel> categories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isListening ? Icons.hearing : Icons.mic,
                  color: _isListening
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isListening
                        ? 'Escuchando… habla cerca del micrófono'
                        : 'Dicta un gasto o ingreso. Ej: "gasto supermercado 35 euros"',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.stop_circle_outlined : Icons.mic_none,
                  ),
                  label:
                      Text(_isListening ? 'Detener' : 'Añadir con micrófono'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Cómo usar los comandos de voz:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('1. Pulsa "Añadir con micrófono" y acepta el permiso.'),
            const Text('2. Di claramente el tipo de movimiento y el monto en español.'),
            const Text(
              '   Ejemplos: "gasto supermercado 35 euros" o "ingreso nómina 1200".',
            ),
            const Text('3. Revisa el borrador y presiona "Guardar con voz".'),
            if (_lastTranscript != null) ...[
              const SizedBox(height: 8),
              Text(
                'Último dictado: "${_lastTranscript!}"',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (_voiceError != null) ...[
              const SizedBox(height: 8),
              Text(
                _voiceError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_voiceDraft != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      _voiceDraft!.intent == VoiceIntent.income
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                    ),
                    label: Text(
                      _voiceDraft!.intent == VoiceIntent.income
                          ? 'Ingreso'
                          : 'Gasto',
                    ),
                  ),
                  Chip(
                    label: Text('Categoría: ${_voiceDraft!.categoryName}'),
                  ),
                  Chip(
                    label: Text('Monto: ${_formatMoney(_voiceDraft!.amount)}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Corrige si es necesario antes de guardar:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expenseNameController,
                decoration: const InputDecoration(labelText: 'Concepto'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expenseAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
              if (_voiceDraft!.intent == VoiceIntent.expense) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId ?? _voiceDraft!.categoryId,
                  hint: const Text('Categoría detectada'),
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
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _confirmVoiceDraft(categories),
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar con voz'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _voiceDraft = null;
                        _lastTranscript = null;
                        _voiceError = null;
                        _selectedCategoryId = null;
                      });
                      _expenseNameController.clear();
                      _expenseAmountController.clear();
                    },
                    child: const Text('Descartar'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);

  double? _parseAmount(String rawValue) {
    final normalized = _normalizeAmount(rawValue);
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _normalizeAmount(String rawValue) {
    final cleaned = rawValue.trim().replaceAll(RegExp(r'\s+'), '').replaceAll(',', '.');
    if (cleaned.isEmpty) return '';

    final onlyAllowed = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = onlyAllowed.indexOf('.');

    if (firstDot == -1) {
      return onlyAllowed;
    }

    final before = onlyAllowed.substring(0, firstDot);
    final after = onlyAllowed.substring(firstDot + 1).replaceAll('.', '');
    final leading = before.isEmpty ? '0' : before;
    final trailing = after.isEmpty ? '0' : after;
    return '$leading.$trailing';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
            child: Form(
              key: _incomeFormKey,
              autovalidateMode: _showIncomeErrors
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _incomeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del ingreso',
                      hintText: 'Ej. Nómina, freelance...',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa un nombre para identificarlo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _incomeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Monto mensual',
                      helperText: 'Acepta comas o puntos; se guardará con dos decimales.',
                    ),
                    validator: (value) {
                      final amount = _parseAmount(value ?? '');
                      if (amount == null) return 'Introduce un número válido';
                      if (amount <= 0) return 'El monto debe ser mayor a cero';
                      return null;
                    },
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _incomeNameController.clear();
                        _incomeAmountController.clear();
                        setState(() => _showIncomeErrors = false);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpiar formulario'),
                    ),
                  ),
                ],
              ),
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
        _buildVoiceAssistant(categories),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Crea una categoría primero para poder clasificar tus gastos.'),
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _expenseFormKey,
              autovalidateMode: _showExpenseErrors
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _expenseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Concepto',
                      hintText: 'Ej. Supermercado, alquiler…',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Añade un concepto para el gasto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _expenseAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      helperText: 'Permite comas o puntos; se guardará con dos decimales.',
                    ),
                    validator: (value) {
                      final amount = _parseAmount(value ?? '');
                      if (amount == null) return 'Introduce un número válido';
                      if (amount <= 0) return 'El monto debe ser mayor a cero';
                      return null;
                    },
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
                    validator: (_) {
                      if (categories.isEmpty) return 'Crea una categoría para continuar';
                      if (_selectedCategoryId == null) {
                        return 'Selecciona una categoría';
                      }
                      return null;
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _expenseNameController.clear();
                        _expenseAmountController.clear();
                        _selectedCategoryId = null;
                        setState(() => _showExpenseErrors = false);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpiar formulario'),
                    ),
                  ),
                ],
              ),
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

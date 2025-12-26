import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_boxes.dart';
import '../../core/voice_intent_parser.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';

class VoiceTransactionDraft {
  final String transcript;
  final VoiceIntent intent;
  final double amount;
  final String concept;
  final String? categoryId;
  final String categoryName;

  const VoiceTransactionDraft({
    required this.transcript,
    required this.intent,
    required this.amount,
    required this.concept,
    required this.categoryId,
    required this.categoryName,
  });

  VoiceTransactionDraft copyWith({
    double? amount,
    String? concept,
    String? categoryId,
    String? categoryName,
  }) {
    return VoiceTransactionDraft(
      transcript: transcript,
      intent: intent,
      amount: amount ?? this.amount,
      concept: concept ?? this.concept,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

class VoiceTransactionService {
  final VoiceIntentParser parser;
  final _uuid = const Uuid();

  VoiceTransactionService({required this.parser});

  VoiceTransactionDraft parseTranscript(String transcript) {
    final parseResult = parser.parse(transcript);
    final amount = _extractAmount(parseResult.normalizedText);

    if (amount == null || amount <= 0) {
      throw const FormatException('No se pudo detectar un monto válido.');
    }

    final categoryName = parseResult.matchedCategory ?? 'General';
    final category = _ensureCategory(categoryName);

    return VoiceTransactionDraft(
      transcript: transcript,
      intent: parseResult.intent,
      amount: amount,
      concept: parseResult.suggestedConcept,
      categoryId: category?.id,
      categoryName: category?.name ?? categoryName,
    );
  }

  Future<void> persistDraft(VoiceTransactionDraft draft) async {
    final now = DateTime.now();

    if (draft.intent == VoiceIntent.expense) {
      final expenseBox = Hive.box<ExpenseModel>(HiveBoxes.expenses);

      final expense = ExpenseModel(
        id: _uuid.v4(),
        name: draft.concept,
        amount: draft.amount,
        date: now,
        isFixed: false,
        categoryId: draft.categoryId ?? _ensureCategory('General')!.id,
      );

      await expenseBox.put(expense.id, expense);
      return;
    }

    final incomeBox = Hive.box<IncomeModel>(HiveBoxes.incomes);
    final income = IncomeModel(
      id: _uuid.v4(),
      name: draft.concept,
      amount: draft.amount,
      startDate: now,
      dayOfMonth: now.day,
    );

    await incomeBox.put(income.id, income);
  }

  double? _extractAmount(String normalized) {
    final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(normalized);
    if (match == null) return null;

    final raw = match.group(0)!.replaceAll(',', '.');
    return double.tryParse(raw);
  }

  CategoryModel? _ensureCategory(String name) {
    final categoryBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    try {
      final existing = categoryBox.values.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
      return existing;
    } catch (_) {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: name,
        emoji: '🎙️',
        colorValue: pickCategoryColor(name).value,
      );
      categoryBox.put(category.id, category);
      return category;
    }
  }
}

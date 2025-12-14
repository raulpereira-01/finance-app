import 'package:finance_app/core/constants/hive_boxes.dart';
import 'package:finance_app/data/models/category_model.dart';
import 'package:finance_app/data/models/expense_model.dart';
import 'package:finance_app/data/models/income_model.dart';
import 'package:finance_app/presentation/screens/categories/categories_screen.dart';
import 'package:finance_app/presentation/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());

  await Hive.openBox<CategoryModel>(HiveBoxes.categories);
  await Hive.openBox<IncomeModel>(HiveBoxes.incomes);
  await Hive.openBox<ExpenseModel>(HiveBoxes.expenses);


  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const OnboardingWelcomeScreen(),
    );
  }
}

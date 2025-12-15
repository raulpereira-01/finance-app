import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('es')];

  static const _localizedValues = {
    'en': {
      'appTitle': 'Finance App',
      'homeTitle': 'Home',
      'planTitle': 'Plan',
      'settingsTitle': 'Settings',
      'periodIncome': 'Income',
      'periodExpenses': 'Expenses',
      'balance': 'Balance',
      'positiveBalanceHint': 'Good saving pace',
      'negativeBalanceHint': 'Review your fixed costs',
      'incomeVsExpensesTitle': 'Income vs expenses',
      'incomeVsExpensesEmpty': 'No income or expenses for this period',
      'chartIncomeLabel': 'Income',
      'chartExpensesLabel': 'Expenses',
      'pieChartTitle': 'Expenses by category',
      'noExpenses': 'No expenses for this period',
      'languageSetting': 'Language',
      'languageSettingSubtitle': 'Choose the language for the app',
      'languageSpanish': 'Spanish',
      'languageEnglish': 'English',
      'settingsDescription': 'App preferences',
      'authenticationTitle': 'Unlock required',
      'authenticationMessage':
          'Authenticate with biometrics or your device PIN to continue.',
      'authenticationRetry': 'Try again',
      'authenticationFailed':
          'We could not verify your identity. Please try again.',
      'authenticationChecking': 'Checking device security...',
      'authenticationNotSupported':
          'This device does not support biometrics or device credentials.',
      'authenticationNoBiometrics':
          'No biometric method is set up. Add a fingerprint or PIN in settings.',
      'authenticationLockedOut':
          'Too many attempts. Use your device PIN or try again later.',
    },
    'es': {
      'appTitle': 'Finance App',
      'homeTitle': 'Inicio',
      'planTitle': 'Plan',
      'settingsTitle': 'Ajustes',
      'periodIncome': 'Ingresos',
      'periodExpenses': 'Gastos',
      'balance': 'Balance',
      'positiveBalanceHint': 'Buen ritmo de ahorro',
      'negativeBalanceHint': 'Revisa tus gastos fijos',
      'incomeVsExpensesTitle': 'Ingresos vs gastos',
      'incomeVsExpensesEmpty': 'No hay ingresos ni gastos en este periodo',
      'chartIncomeLabel': 'Ingresos',
      'chartExpensesLabel': 'Gastos',
      'pieChartTitle': 'Gastos por categoría',
      'noExpenses': 'No hay gastos en este periodo',
      'languageSetting': 'Idioma',
      'languageSettingSubtitle': 'Elige el idioma de la aplicación',
      'languageSpanish': 'Español',
      'languageEnglish': 'Inglés',
      'settingsDescription': 'Preferencias de la aplicación',
      'authenticationTitle': 'Desbloqueo requerido',
      'authenticationMessage':
          'Autentícate con biometría o el PIN de tu dispositivo para continuar.',
      'authenticationRetry': 'Reintentar',
      'authenticationFailed':
          'No pudimos verificar tu identidad. Inténtalo nuevamente.',
      'authenticationChecking': 'Comprobando seguridad del dispositivo...',
      'authenticationNotSupported':
          'Este dispositivo no admite biometría ni credenciales del sistema.',
      'authenticationNoBiometrics':
          'No hay biometría configurada. Añade huella o PIN en ajustes.',
      'authenticationLockedOut':
          'Demasiados intentos. Usa el PIN del dispositivo o inténtalo luego.',
    },
  };

  String _text(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;

  String get appTitle => _text('appTitle');
  String get homeTitle => _text('homeTitle');
  String get planTitle => _text('planTitle');
  String get settingsTitle => _text('settingsTitle');
  String get periodIncome => _text('periodIncome');
  String get periodExpenses => _text('periodExpenses');
  String get balance => _text('balance');
  String get positiveBalanceHint => _text('positiveBalanceHint');
  String get negativeBalanceHint => _text('negativeBalanceHint');
  String get incomeVsExpensesTitle => _text('incomeVsExpensesTitle');
  String get incomeVsExpensesEmpty => _text('incomeVsExpensesEmpty');
  String get chartIncomeLabel => _text('chartIncomeLabel');
  String get chartExpensesLabel => _text('chartExpensesLabel');
  String get pieChartTitle => _text('pieChartTitle');
  String get noExpenses => _text('noExpenses');
  String get languageSetting => _text('languageSetting');
  String get languageSettingSubtitle => _text('languageSettingSubtitle');
  String get languageSpanish => _text('languageSpanish');
  String get languageEnglish => _text('languageEnglish');
  String get settingsDescription => _text('settingsDescription');
  String get authenticationTitle => _text('authenticationTitle');
  String get authenticationMessage => _text('authenticationMessage');
  String get authenticationRetry => _text('authenticationRetry');
  String get authenticationFailed => _text('authenticationFailed');
  String get authenticationChecking => _text('authenticationChecking');
  String get authenticationNotSupported => _text('authenticationNotSupported');
  String get authenticationNoBiometrics => _text('authenticationNoBiometrics');
  String get authenticationLockedOut => _text('authenticationLockedOut');

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((element) => element.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

// Controlador que gestiona el idioma y notifica a la app al cambiar la configuración.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettingsController extends ChangeNotifier {
  static const _localeKey = 'locale';
  final Box _box = Hive.box('app_settings');

  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  Future<void> load() async {
    final storedLocale = _box.get(_localeKey) as String?;
    if (storedLocale != null) {
      _locale = Locale(storedLocale);
    }
  }

  void updateLocale(Locale locale) {
    _locale = locale;
    _box.put(_localeKey, locale.languageCode);
    notifyListeners();
  }
}

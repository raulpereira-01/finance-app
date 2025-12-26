import 'package:flutter/material.dart';

enum VoiceIntent { income, expense }

class VoiceIntentParseResult {
  final String normalizedText;
  final VoiceIntent intent;
  final String? matchedCategory;
  final String suggestedConcept;

  const VoiceIntentParseResult({
    required this.normalizedText,
    required this.intent,
    required this.matchedCategory,
    required this.suggestedConcept,
  });
}

class VoiceIntentParser {
  static const _expenseKeywords = [
    'gasto',
    'gasté',
    'pagué',
    'pagando',
    'compré',
    'compra',
  ];

  static const _incomeKeywords = [
    'ingreso',
    'ingresé',
    'cobré',
    'cobro',
    'pagaron',
    'sueldo',
    'nómina',
    'nomina',
  ];

  static const Map<String, String> _categoryKeywords = {
    'super': 'Supermercado',
    'mercado': 'Supermercado',
    'comida': 'Restauración',
    'restaurante': 'Restauración',
    'cena': 'Restauración',
    'desayuno': 'Restauración',
    'alquiler': 'Alquiler',
    'renta': 'Alquiler',
    'hipoteca': 'Alquiler',
    'transporte': 'Transporte',
    'taxi': 'Transporte',
    'uber': 'Transporte',
    'gasolina': 'Transporte',
    'colegio': 'Educación',
    'universidad': 'Educación',
    'libro': 'Educación',
    'servicio': 'Servicios',
    'luz': 'Servicios',
    'agua': 'Servicios',
    'internet': 'Servicios',
    'telefono': 'Servicios',
    'teléfono': 'Servicios',
    'sueldo': 'Sueldo',
    'nomina': 'Sueldo',
  };

  String normalize(String input) {
    var text = input.toLowerCase().trim();
    text = _removeDiacritics(text);
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text;
  }

  VoiceIntentParseResult parse(String input) {
    final normalized = normalize(input);
    final intent = _detectIntent(normalized);
    final matchedCategory = detectCategory(normalized);
    final concept = _guessConcept(normalized, matchedCategory) ??
        (intent == VoiceIntent.income ? 'Ingreso por voz' : 'Gasto por voz');

    return VoiceIntentParseResult(
      normalizedText: normalized,
      intent: intent,
      matchedCategory: matchedCategory,
      suggestedConcept: concept,
    );
  }

  VoiceIntent _detectIntent(String normalized) {
    if (_incomeKeywords.any((word) => normalized.contains(word))) {
      return VoiceIntent.income;
    }

    if (_expenseKeywords.any((word) => normalized.contains(word))) {
      return VoiceIntent.expense;
    }

    return VoiceIntent.expense;
  }

  String? detectCategory(String normalized) {
    for (final entry in _categoryKeywords.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _guessConcept(String normalized, String? category) {
    if (category != null) return category;
    final tokens = normalized.split(' ');
    if (tokens.isEmpty) return null;
    return tokens.take(4).join(' ').trim();
  }

  String _removeDiacritics(String text) {
    const withDiacritics = 'áäâàãéëèêíïìîóöòôõúüùûñçÁÄÂÀÃÉËÈÊÍÏÌÎÓÖÒÔÕÚÜÙÛÑÇ';
    const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuuncAAAAAEEEEIIIIOOOOOUUUUNC';

    return text.replaceAllMapped(RegExp(r'[${withDiacritics}]'), (match) {
      final index = withDiacritics.indexOf(match.group(0)!);
      return withoutDiacritics[index];
    });
  }
}

Color pickCategoryColor(String categoryName) {
  final normalized = categoryName.toLowerCase();
  if (normalized.contains('sueldo') || normalized.contains('ingreso')) {
    return Colors.green;
  }
  if (normalized.contains('super')) return Colors.orange;
  if (normalized.contains('transporte')) return Colors.blueGrey;
  if (normalized.contains('servicio')) return Colors.blue;
  if (normalized.contains('alquiler')) return Colors.indigo;
  return Colors.teal;
}

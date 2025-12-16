// Modelo de dominio para representar una categoría con nombre, emoji y color.
class Category {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });
}

// Modelo persistente de Hive que almacena las categorías creadas en la aplicación.
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });
}

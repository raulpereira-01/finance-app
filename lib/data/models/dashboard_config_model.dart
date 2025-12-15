import 'package:hive/hive.dart';

import '../../domain/entities/dashboard_widget_type.dart';

part 'dashboard_config_model.g.dart';

@HiveType(typeId: 4)
class DashboardConfigModel extends HiveObject {
  @HiveField(0)
  final DashboardWidgetType type;

  @HiveField(1)
  final bool enabled;

  @HiveField(2)
  final int order;

  DashboardConfigModel({
    required this.type,
    required this.enabled,
    required this.order,
  });
}

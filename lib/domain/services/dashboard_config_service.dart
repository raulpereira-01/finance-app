import 'package:hive/hive.dart';

import '../../data/models/dashboard_config_model.dart';
import '../../domain/entities/dashboard_widget_type.dart';

class DashboardConfigService {
  final Box<DashboardConfigModel> _box = Hive.box<DashboardConfigModel>(
    'dashboard_config',
  );

  List<DashboardConfigModel> load() {
    if (_box.isEmpty) {
      return DashboardWidgetType.values.asMap().entries.map((entry) {
        return DashboardConfigModel(
          type: entry.value,
          enabled: true,
          order: entry.key,
        );
      }).toList();
    }
    return _box.values.toList();
  }

  void save(List<DashboardConfigModel> configs) {
    _box.clear();
    for (final config in configs) {
      _box.put(config.type.name, config);
    }
  }
}

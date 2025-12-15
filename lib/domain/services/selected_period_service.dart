import 'package:hive/hive.dart';

import '../../core/constants/hive_boxes.dart';
import '../entities/selected_period.dart';
import '../../data/models/selected_period_model.dart';

class SelectedPeriodService {
  final Box<SelectedPeriodModel> _box =
      Hive.box<SelectedPeriodModel>(HiveBoxes.selectedPeriod);

  SelectedPeriod loadCurrent() {
    if (_box.isEmpty || !_box.containsKey('current')) {
      final now = DateTime.now();
      final current = SelectedPeriod.fromMonthYear(now.month, now.year);
      saveCurrent(current);
      return current;
    }

    final stored = _box.get('current');
    if (stored == null) {
      final now = DateTime.now();
      return SelectedPeriod.fromMonthYear(now.month, now.year);
    }

    return stored.toEntity();
  }

  void saveCurrent(SelectedPeriod period) {
    _box.put('current', SelectedPeriodModel.fromEntity(period));
  }
}

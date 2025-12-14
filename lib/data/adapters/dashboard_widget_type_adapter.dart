import 'package:hive/hive.dart';
import '../../domain/entities/dashboard_widget_type.dart';

class DashboardWidgetTypeAdapter
    extends TypeAdapter<DashboardWidgetType> {
  @override
  final int typeId = 5;

  @override
  DashboardWidgetType read(BinaryReader reader) {
    return DashboardWidgetType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, DashboardWidgetType obj) {
    writer.writeInt(obj.index);
  }
}

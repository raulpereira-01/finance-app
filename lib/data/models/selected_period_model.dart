import 'package:hive/hive.dart';
import '../../domain/entities/selected_period.dart';

class SelectedPeriodModel extends HiveObject {
  final int month;
  final int year;
  final DateTime startDate;
  final DateTime endDate;

  SelectedPeriodModel({
    required this.month,
    required this.year,
    required this.startDate,
    required this.endDate,
  });

  SelectedPeriod toEntity() {
    return SelectedPeriod(
      month: month,
      year: year,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory SelectedPeriodModel.fromEntity(SelectedPeriod entity) {
    return SelectedPeriodModel(
      month: entity.month,
      year: entity.year,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}

class SelectedPeriodModelAdapter extends TypeAdapter<SelectedPeriodModel> {
  @override
  final int typeId = 6;

  @override
  SelectedPeriodModel read(BinaryReader reader) {
    final month = reader.readInt();
    final year = reader.readInt();
    final startDate = reader.readDateTime();
    final endDate = reader.readDateTime();

    return SelectedPeriodModel(
      month: month,
      year: year,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedPeriodModel obj) {
    writer.writeInt(obj.month);
    writer.writeInt(obj.year);
    writer.writeDateTime(obj.startDate);
    writer.writeDateTime(obj.endDate);
  }
}

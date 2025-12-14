// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardConfigModelAdapter extends TypeAdapter<DashboardConfigModel> {
  @override
  final int typeId = 4;

  @override
  DashboardConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardConfigModel(
      type: fields[0] as DashboardWidgetType,
      enabled: fields[1] as bool,
      order: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardConfigModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.enabled)
      ..writeByte(2)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

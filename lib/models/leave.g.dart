// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveAdapter extends TypeAdapter<Leave> {
  @override
  final int typeId = 2;

  @override
  Leave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leave(
      id: fields[0] as String,
      type: fields[1] as LeaveType,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      days: fields[4] as double,
      hours: fields[5] as double?,
      note: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Leave obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.hours)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

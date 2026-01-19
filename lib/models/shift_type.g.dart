// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftTypeAdapter extends TypeAdapter<ShiftType> {
  @override
  final int typeId = 4;

  @override
  ShiftType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShiftType.night;
      case 1:
        return ShiftType.morning;
      case 2:
        return ShiftType.evening;
      default:
        return ShiftType.night;
    }
  }

  @override
  void write(BinaryWriter writer, ShiftType obj) {
    switch (obj) {
      case ShiftType.night:
        writer.writeByte(0);
        break;
      case ShiftType.morning:
        writer.writeByte(1);
        break;
      case ShiftType.evening:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

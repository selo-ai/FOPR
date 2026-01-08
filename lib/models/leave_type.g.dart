// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveTypeAdapter extends TypeAdapter<LeaveType> {
  @override
  final int typeId = 3;

  @override
  LeaveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveType.annual;
      case 1:
        return LeaveType.unpaid;
      case 2:
        return LeaveType.administrative;
      case 3:
        return LeaveType.marriage;
      case 4:
        return LeaveType.bereavement;
      case 5:
        return LeaveType.ssk;
      default:
        return LeaveType.annual;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveType obj) {
    switch (obj) {
      case LeaveType.annual:
        writer.writeByte(0);
        break;
      case LeaveType.unpaid:
        writer.writeByte(1);
        break;
      case LeaveType.administrative:
        writer.writeByte(2);
        break;
      case LeaveType.marriage:
        writer.writeByte(3);
        break;
      case LeaveType.bereavement:
        writer.writeByte(4);
        break;
      case LeaveType.ssk:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

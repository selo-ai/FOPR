// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      fullName: fields[0] as String?,
      employeeId: fields[1] as String?,
      startDate: fields[2] as DateTime?,
      hourlyRate: fields[3] as double,
      monthlyQuota: fields[4] as double,
      yearlyQuota: fields[5] as double,
      themeModeIndex: fields[6] as int,
      overtimeTutorialShown: fields[7] == null ? false : fields[7] as bool,
      salarySettingsReminderShown:
          fields[9] == null ? false : fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.hourlyRate)
      ..writeByte(4)
      ..write(obj.monthlyQuota)
      ..writeByte(5)
      ..write(obj.yearlyQuota)
      ..writeByte(6)
      ..write(obj.themeModeIndex)
      ..writeByte(7)
      ..write(obj.overtimeTutorialShown)
      ..writeByte(9)
      ..write(obj.salarySettingsReminderShown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

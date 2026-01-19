// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalarySettingsAdapter extends TypeAdapter<SalarySettings> {
  @override
  final int typeId = 6;

  @override
  SalarySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalarySettings(
      hourlyGrossRate: fields[0] as double,
      weeklyWorkHours: fields[1] as double,
      childCount: fields[2] as int,
      childAllowancePerChild: fields[3] as double,
      hasUnion: fields[4] as bool,
      unionRate: fields[5] as double,
      hasBES: fields[6] as bool,
      besAmount: fields[7] as double,
      fuelAllowance: fields[8] as double,
      healthInsurance: fields[9] as double,
      educationFund: fields[10] as double,
      foundationDeduction: fields[11] as double,
      hasHealthInsurance: fields[12] == null ? false : fields[12] as bool,
      ossPersonCount: fields[13] == null ? 0 : fields[13] as int,
      ossCostPerPerson: fields[14] == null ? 0.0 : fields[14] as double,
      hasExecution: fields[15] == null ? false : fields[15] as bool,
      executionAmount: fields[16] == null ? 0.0 : fields[16] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SalarySettings obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.hourlyGrossRate)
      ..writeByte(1)
      ..write(obj.weeklyWorkHours)
      ..writeByte(2)
      ..write(obj.childCount)
      ..writeByte(3)
      ..write(obj.childAllowancePerChild)
      ..writeByte(4)
      ..write(obj.hasUnion)
      ..writeByte(5)
      ..write(obj.unionRate)
      ..writeByte(6)
      ..write(obj.hasBES)
      ..writeByte(7)
      ..write(obj.besAmount)
      ..writeByte(8)
      ..write(obj.fuelAllowance)
      ..writeByte(9)
      ..write(obj.healthInsurance)
      ..writeByte(10)
      ..write(obj.educationFund)
      ..writeByte(11)
      ..write(obj.foundationDeduction)
      ..writeByte(12)
      ..write(obj.hasHealthInsurance)
      ..writeByte(13)
      ..write(obj.ossPersonCount)
      ..writeByte(14)
      ..write(obj.ossCostPerPerson)
      ..writeByte(15)
      ..write(obj.hasExecution)
      ..writeByte(16)
      ..write(obj.executionAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalarySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

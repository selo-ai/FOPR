// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryRecordAdapter extends TypeAdapter<SalaryRecord> {
  @override
  final int typeId = 7;

  @override
  SalaryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryRecord(
      id: fields[0] as String,
      year: fields[1] as int,
      month: fields[2] as int,
      normalHours: fields[3] as double,
      nightShiftHours: fields[4] as double,
      overtimeHours: fields[5] as double,
      weekendHours: fields[6] as double,
      bonusAmount: fields[7] as double,
      advanceAmount: fields[8] as double,
      createdAt: fields[9] as DateTime,
      cachedHourlyRate: fields[10] as double,
      totalGrossPay: fields[11] as double,
      totalNetPay: fields[12] as double,
      totalSundayHours: fields[13] == null ? 0.0 : fields[13] as double,
      publicHolidayHours: fields[14] == null ? 0.0 : fields[14] as double,
      annualLeaveDays: fields[15] == null ? 0.0 : fields[15] as double,
      otosanAllowance: fields[16] == null ? 0.0 : fields[16] as double,
      holidayAllowance: fields[17] == null ? 0.0 : fields[17] as double,
      leaveAllowance: fields[18] == null ? 0.0 : fields[18] as double,
      tahsilAllowance: fields[19] == null ? 0.0 : fields[19] as double,
      shoeAllowance: fields[20] == null ? 0.0 : fields[20] as double,
      jobIndemnity: fields[21] == null ? 0.0 : fields[21] as double,
      tisAdvance: fields[22] == null ? 0.0 : fields[22] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryRecord obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.normalHours)
      ..writeByte(4)
      ..write(obj.nightShiftHours)
      ..writeByte(5)
      ..write(obj.overtimeHours)
      ..writeByte(6)
      ..write(obj.weekendHours)
      ..writeByte(7)
      ..write(obj.bonusAmount)
      ..writeByte(8)
      ..write(obj.advanceAmount)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.cachedHourlyRate)
      ..writeByte(11)
      ..write(obj.totalGrossPay)
      ..writeByte(12)
      ..write(obj.totalNetPay)
      ..writeByte(13)
      ..write(obj.totalSundayHours)
      ..writeByte(14)
      ..write(obj.publicHolidayHours)
      ..writeByte(15)
      ..write(obj.annualLeaveDays)
      ..writeByte(16)
      ..write(obj.otosanAllowance)
      ..writeByte(17)
      ..write(obj.holidayAllowance)
      ..writeByte(18)
      ..write(obj.leaveAllowance)
      ..writeByte(19)
      ..write(obj.tahsilAllowance)
      ..writeByte(20)
      ..write(obj.shoeAllowance)
      ..writeByte(21)
      ..write(obj.jobIndemnity)
      ..writeByte(22)
      ..write(obj.tisAdvance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

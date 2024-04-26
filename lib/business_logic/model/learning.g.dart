// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningAdapter extends TypeAdapter<Learning> {
  @override
  final int typeId = 2;

  @override
  Learning read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Learning(
      isLearning: fields[0] as bool,
      nextLearn: fields[1] as DateTime,
      level: fields[2] as int,
      interval: fields[3] as int,
      counter: fields[4] as int,
      wrong: fields[5] as int,
      index: fields[6] as int,
      stars: fields[7] as int,
      line: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Learning obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isLearning)
      ..writeByte(1)
      ..write(obj.nextLearn)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.interval)
      ..writeByte(4)
      ..write(obj.counter)
      ..writeByte(5)
      ..write(obj.wrong)
      ..writeByte(6)
      ..write(obj.index)
      ..writeByte(7)
      ..write(obj.stars)
      ..writeByte(8)
      ..write(obj.line);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

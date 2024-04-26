// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PoemAdapter extends TypeAdapter<Poem> {
  @override
  final int typeId = 1;

  @override
  Poem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Poem(
      author: fields[2] as String,
      title: fields[1] as String,
      isPoem: fields[0] as bool,
      lang: fields[4] as String,
      diff: fields[5] as double,
    )..learning = (fields[3] as HiveList).castHiveList();
  }

  @override
  void write(BinaryWriter writer, Poem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isPoem)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.learning)
      ..writeByte(4)
      ..write(obj.lang)
      ..writeByte(5)
      ..write(obj.diff);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

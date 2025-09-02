// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothingItemModelAdapter extends TypeAdapter<ClothingItemModel> {
  @override
  final int typeId = 0;

  @override
  ClothingItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothingItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      subcategory: fields[3] as String?,
      brand: fields[4] as String?,
      color: fields[5] as String?,
      materials: fields[6] as String?,
      season: fields[7] as String?,
      purchasePrice: fields[8] as double?,
      ownedSince: fields[9] as DateTime?,
      origin: fields[10] as String?,
      laundryImpact: fields[11] as String?,
      repairable: fields[12] as bool?,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      isActive: fields[16] as bool,
      cloudId: fields[17] as String?,
      lastSyncedAt: fields[18] as DateTime?,
      wearCount: fields[19] as int,
      imageData: fields[20] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItemModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.subcategory)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.materials)
      ..writeByte(7)
      ..write(obj.season)
      ..writeByte(8)
      ..write(obj.purchasePrice)
      ..writeByte(9)
      ..write(obj.ownedSince)
      ..writeByte(10)
      ..write(obj.origin)
      ..writeByte(11)
      ..write(obj.laundryImpact)
      ..writeByte(12)
      ..write(obj.repairable)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.cloudId)
      ..writeByte(18)
      ..write(obj.lastSyncedAt)
      ..writeByte(19)
      ..write(obj.wearCount)
      ..writeByte(20)
      ..write(obj.imageData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

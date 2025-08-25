import 'package:hive/hive.dart';
import '../../domain/entities/clothing_item.dart';

part 'clothing_item_model.g.dart';

/// Hive model for clothing items
/// This allows for easy local storage and future cloud sync
@HiveType(typeId: 0)
class ClothingItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? subcategory;

  @HiveField(4)
  String? brand;

  @HiveField(5)
  String? color;

  @HiveField(6)
  String? materials;

  @HiveField(7)
  String? season;

  @HiveField(8)
  double? purchasePrice;

  @HiveField(9)
  DateTime? ownedSince;

  @HiveField(10)
  String? origin;

  @HiveField(11)
  String? laundryImpact;

  @HiveField(12)
  bool? repairable;

  @HiveField(13)
  String? notes;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime updatedAt;

  @HiveField(16)
  bool isActive;

  @HiveField(17)
  String? cloudId; // For future cloud sync

  @HiveField(18)
  DateTime? lastSyncedAt; // For future cloud sync

  ClothingItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.brand,
    this.color,
    this.materials,
    this.season,
    this.purchasePrice,
    this.ownedSince,
    this.origin,
    this.laundryImpact,
    this.repairable,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.cloudId,
    this.lastSyncedAt,
  });

  /// Converts domain entity to Hive model
  factory ClothingItemModel.fromEntity(ClothingItem entity) {
    return ClothingItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      subcategory: entity.subcategory,
      brand: entity.brand,
      color: entity.color,
      materials: entity.materials,
      season: entity.season,
      purchasePrice: entity.purchasePrice,
      ownedSince: entity.ownedSince,
      origin: entity.origin,
      laundryImpact: entity.laundryImpact,
      repairable: entity.repairable,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      cloudId: null, // Will be set when cloud sync is implemented
      lastSyncedAt: null, // Will be set when cloud sync is implemented
    );
  }

  /// Converts Hive model to domain entity
  ClothingItem toEntity() {
    return ClothingItem(
      id: id,
      name: name,
      category: category,
      subcategory: subcategory,
      brand: brand,
      color: color,
      materials: materials,
      season: season,
      purchasePrice: purchasePrice,
      ownedSince: ownedSince,
      origin: origin,
      laundryImpact: laundryImpact,
      repairable: repairable,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  /// Creates a copy with updated fields
  ClothingItemModel copyWith({
    String? name,
    String? category,
    String? subcategory,
    String? brand,
    String? color,
    String? materials,
    String? season,
    double? purchasePrice,
    DateTime? ownedSince,
    String? origin,
    String? laundryImpact,
    bool? repairable,
    String? notes,
    bool? isActive,
    String? cloudId,
    DateTime? lastSyncedAt,
  }) {
    return ClothingItemModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      materials: materials ?? this.materials,
      season: season ?? this.season,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      ownedSince: ownedSince ?? this.ownedSince,
      origin: origin ?? this.origin,
      laundryImpact: laundryImpact ?? this.laundryImpact,
      repairable: repairable ?? this.repairable,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
      cloudId: cloudId ?? this.cloudId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Updates the sync information
  void updateSyncInfo(String cloudId) {
    this.cloudId = cloudId;
    lastSyncedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Checks if the item needs to be synced
  bool get needsSync => cloudId == null || lastSyncedAt == null;
}

import 'package:hive/hive.dart';
import '../../domain/entities/outfit.dart';

part 'outfit_model.g.dart';

/// Hive model for outfits
@HiveType(typeId: 1)
class OutfitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<String> clothingItemIds;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? cloudId; // For future cloud sync

  @HiveField(8)
  DateTime? lastSyncedAt; // For future cloud sync

  OutfitModel({
    required this.id,
    required this.date,
    required this.clothingItemIds,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.cloudId,
    this.lastSyncedAt,
  });

  /// Converts domain entity to Hive model
  factory OutfitModel.fromEntity(Outfit entity) {
    return OutfitModel(
      id: entity.id,
      date: entity.date,
      clothingItemIds: entity.clothingItemIds,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      cloudId: null, // Will be set when cloud sync is implemented
      lastSyncedAt: null, // Will be set when cloud sync is implemented
    );
  }

  /// Converts Hive model to domain entity
  Outfit toEntity() {
    return Outfit(
      id: id,
      date: date,
      clothingItemIds: clothingItemIds,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  /// Creates a copy with updated fields
  OutfitModel copyWith({
    String? name,
    DateTime? date,
    List<String>? clothingItemIds,
    String? notes,
    bool? isActive,
    String? cloudId,
    DateTime? lastSyncedAt,
  }) {
    return OutfitModel(
      id: id,
      date: date ?? this.date,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
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


import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a single piece of clothing
class ClothingItem extends Equatable {
  final String id;
  final String name;
  final String category; // e.g., 'shirt', 'pants', 'dress'
  final String? subcategory; // e.g., 't-shirt', 'jeans', 'casual'
  final String? brand;
  final String? color;
  final String? materials;
  final String? season; // e.g., 'summer', 'winter', 'all-season'
  final double? purchasePrice;
  final DateTime? ownedSince;
  final String? origin;
  final String? laundryImpact;
  final bool? repairable;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // for soft deletion
  final int wearCount; // total number of outfits containing this item

  const ClothingItem({
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
    this.wearCount = 0,
  });

  /// Creates a new ClothingItem with a generated ID
  factory ClothingItem.create({
    required String name,
    required String category,
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
  }) {
    final now = DateTime.now();
    return ClothingItem(
      id: const Uuid().v4(),
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
      createdAt: now,
      updatedAt: now,
      isActive: true,
      wearCount: 0,
    );
  }

  /// Creates a copy of this ClothingItem with updated fields
  ClothingItem copyWith({
    String? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? wearCount,
  }) {
    return ClothingItem(
      id: id ?? this.id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      wearCount: wearCount ?? this.wearCount,
    );
  }

  /// Creates a deactivated copy (soft delete)
  ClothingItem markAsInactive() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  ClothingItem updateLastModified() {
    return copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        subcategory,
        brand,
        color,
        materials,
        season,
        purchasePrice,
        ownedSince,
        origin,
        laundryImpact,
        repairable,
        notes,
        createdAt,
        updatedAt,
        isActive,
        wearCount,
      ];
}

import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents an outfit worn on a specific day
class Outfit extends Equatable {
  final String id;
  final DateTime date;
  final List<String> clothingItemIds; // References to ClothingItem IDs
  final String? notes;
  final Uint8List? imageData; // Binary image data (optimized)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Outfit({
    required this.id,
    required this.date,
    required this.clothingItemIds,
    this.notes,
    this.imageData,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Creates a new Outfit with a generated ID
  factory Outfit.create({
    required DateTime date,
    required List<String> clothingItemIds,
    String? notes,
    Uint8List? imageData,
  }) {
    final now = DateTime.now();
    return Outfit(
      id: const Uuid().v4(),
      date: date,
      clothingItemIds: clothingItemIds,
      notes: notes,
      imageData: imageData,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
  }

  /// Creates a copy of this Outfit with updated fields
  Outfit copyWith({
    String? id,
    DateTime? date,
    List<String>? clothingItemIds,
    String? notes,
    Uint8List? imageData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Outfit(
      id: id ?? this.id,
      date: date ?? this.date,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      notes: notes ?? this.notes,
      imageData: imageData ?? this.imageData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a deactivated copy (soft delete)
  Outfit markAsInactive() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the last modified timestamp
  Outfit updateLastModified() {
    return copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a clothing item to the outfit
  Outfit addClothingItem(String clothingItemId) {
    if (!clothingItemIds.contains(clothingItemId)) {
      return copyWith(
        clothingItemIds: [...clothingItemIds, clothingItemId],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  /// Removes a clothing item from the outfit
  Outfit removeClothingItem(String clothingItemId) {
    return copyWith(
      clothingItemIds: clothingItemIds.where((id) => id != clothingItemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        clothingItemIds,
        notes,
        imageData,
        createdAt,
        updatedAt,
        isActive,
      ];
}


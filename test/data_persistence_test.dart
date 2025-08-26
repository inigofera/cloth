import 'package:flutter_test/flutter_test.dart';
import 'package:cloth/domain/entities/clothing_item.dart';
import 'package:cloth/domain/entities/outfit.dart';

void main() {
  group('Data Persistence Tests', () {
    test('Clothing item should be created with proper data', () {
      // Create a test clothing item
      final clothingItem = ClothingItem.create(
        name: 'Test T-Shirt',
        category: 'shirt',
        color: 'blue',
        brand: 'Test Brand',
        season: 'summer',
      );
      
      // Verify the item was created correctly
      expect(clothingItem.name, 'Test T-Shirt');
      expect(clothingItem.category, 'shirt');
      expect(clothingItem.color, 'blue');
      expect(clothingItem.brand, 'Test Brand');
      expect(clothingItem.season, 'summer');
      expect(clothingItem.isActive, true);
      expect(clothingItem.wearCount, 0);
      expect(clothingItem.id, isNotEmpty);
      expect(clothingItem.createdAt, isNotNull);
      expect(clothingItem.updatedAt, isNotNull);
    });

    test('Outfit should be created with proper data', () {
      final now = DateTime.now();
      final outfit = Outfit.create(
        date: now,
        clothingItemIds: ['item1', 'item2'],
        notes: 'Test outfit',
      );
      
      // Verify the outfit was created correctly
      expect(outfit.date, now);
      expect(outfit.clothingItemIds, contains('item1'));
      expect(outfit.clothingItemIds, contains('item2'));
      expect(outfit.notes, 'Test outfit');
      expect(outfit.isActive, true);
      expect(outfit.id, isNotEmpty);
      expect(outfit.createdAt, isNotNull);
      expect(outfit.updatedAt, isNotNull);
    });

    test('Clothing item should support updates', () {
      final clothingItem = ClothingItem.create(
        name: 'Test T-Shirt',
        category: 'shirt',
        color: 'blue',
      );
      
      // Update the item
      final updatedItem = clothingItem.copyWith(
        color: 'red',
        brand: 'Updated Brand',
      );
      
      // Verify updates
      expect(updatedItem.name, 'Test T-Shirt'); // unchanged
      expect(updatedItem.color, 'red'); // changed
      expect(updatedItem.brand, 'Updated Brand'); // changed
      expect(updatedItem.category, 'shirt'); // unchanged
    });

    test('Outfit should support adding and removing clothing items', () {
      final outfit = Outfit.create(
        date: DateTime.now(),
        clothingItemIds: ['item1'],
        notes: 'Test outfit',
      );
      
      // Add an item
      final outfitWithNewItem = outfit.addClothingItem('item2');
      expect(outfitWithNewItem.clothingItemIds, contains('item1'));
      expect(outfitWithNewItem.clothingItemIds, contains('item2'));
      
      // Remove an item
      final outfitWithoutItem = outfitWithNewItem.removeClothingItem('item1');
      expect(outfitWithoutItem.clothingItemIds, isNot(contains('item1')));
      expect(outfitWithoutItem.clothingItemIds, contains('item2'));
    });

    test('Clothing item should support soft deletion', () async {
      final clothingItem = ClothingItem.create(
        name: 'Test T-Shirt',
        category: 'shirt',
      );
      
      // Add a small delay to ensure timestamps are different
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Mark as inactive (soft delete)
      final deactivatedItem = clothingItem.markAsInactive();
      expect(deactivatedItem.isActive, false);
      expect(deactivatedItem.updatedAt.isAfter(clothingItem.updatedAt), true);
    });
  });
}

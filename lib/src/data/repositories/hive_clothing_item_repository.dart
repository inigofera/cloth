import 'package:hive/hive.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../models/clothing_item_model.dart';
import '../../core/services/logger_service.dart';

/// Hive implementation of ClothingItemRepository
/// Provides local storage with future cloud sync capabilities
class HiveClothingItemRepository implements ClothingItemRepository {
  static const String _boxName = 'clothing_items';
  late Box<ClothingItemModel> _box;

  /// Constructor
  HiveClothingItemRepository();

  /// Initializes the Hive box
  Future<void> initialize() async {
    _box = await Hive.openBox<ClothingItemModel>(_boxName);
  }

  /// Closes the Hive box
  Future<void> close() async {
    await _box.close();
  }

  @override
  Future<void> addClothingItem(ClothingItem item) async {
    try {
      final model = ClothingItemModel.fromEntity(item);
      await _box.put(item.id, model);
      await _ensureDataPersistence();
      LoggerService.info('Clothing item added successfully: ${item.name}');
    } catch (e) {
      LoggerService.error('Failed to add clothing item: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      final model = ClothingItemModel.fromEntity(item);
      await _box.put(item.id, model);
      await _ensureDataPersistence();
      LoggerService.info('Clothing item updated successfully: ${item.name}');
    } catch (e) {
      LoggerService.error('Failed to update clothing item: $e');
      rethrow;
    }
  }

  /// Ensures data is persisted to disk
  Future<void> _ensureDataPersistence() async {
    try {
      await _box.flush();
    } catch (e) {
      LoggerService.error('Failed to flush data to disk: $e');
    }
  }

  @override
  Future<void> flush() async {
    await _ensureDataPersistence();
  }

  /// Normalizes all category names to lowercase to fix case inconsistencies
  Future<void> normalizeCategories() async {
    try {
      final allItems = _box.values.toList();
      bool hasChanges = false;

      for (final model in allItems) {
        final originalCategory = model.category;
        final normalizedCategory = originalCategory.toLowerCase();

        if (originalCategory != normalizedCategory) {
          model.category = normalizedCategory;
          model.updatedAt = DateTime.now();
          await _box.put(model.id, model);
          hasChanges = true;
          LoggerService.info(
            'Normalized category: "$originalCategory" -> "$normalizedCategory"',
          );
        }
      }

      if (hasChanges) {
        await _ensureDataPersistence();
        LoggerService.info('Category normalization completed');
      } else {
        LoggerService.info('No category normalization needed');
      }
    } catch (e) {
      LoggerService.error('Failed to normalize categories: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteClothingItem(String id) async {
    final item = await getClothingItemById(id);
    if (item != null) {
      final deactivatedItem = item.markAsInactive();
      await updateClothingItem(deactivatedItem);
    }
  }

  @override
  Future<ClothingItem?> getClothingItemById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<List<ClothingItem>> getAllClothingItems() async {
    try {
      final allItems = _box.values.map((model) => model.toEntity()).toList();
      return allItems;
    } catch (e) {
      LoggerService.error('Repository: Error getting all items: $e');
      return [];
    }
  }

  @override
  Future<List<ClothingItem>> getActiveClothingItems() async {
    try {
      final activeItems = _box.values
          .where((model) => model.isActive)
          .map((model) => model.toEntity())
          .toList();

      return activeItems;
    } catch (e) {
      LoggerService.error('Repository: Error getting active items: $e');
      return [];
    }
  }

  @override
  Future<List<ClothingItem>> searchClothingItems(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              (model.name.toLowerCase().contains(lowercaseQuery) ||
                  model.category.toLowerCase().contains(lowercaseQuery) ||
                  (model.subcategory?.toLowerCase().contains(lowercaseQuery) ??
                      false) ||
                  (model.brand?.toLowerCase().contains(lowercaseQuery) ??
                      false) ||
                  (model.color?.toLowerCase().contains(lowercaseQuery) ??
                      false) ||
                  (model.materials?.toLowerCase().contains(lowercaseQuery) ??
                      false) ||
                  (model.origin?.toLowerCase().contains(lowercaseQuery) ??
                      false)),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByCategory(String category) async {
    final lowercaseCategory = category.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.category.toLowerCase() == lowercaseCategory,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsBySeason(String season) async {
    final lowercaseSeason = season.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              (model.season?.toLowerCase() == lowercaseSeason ||
                  model.season?.toLowerCase() == 'all-season'),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByBrand(String brand) async {
    final lowercaseBrand = brand.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive && model.brand?.toLowerCase() == lowercaseBrand,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByColor(String color) async {
    final lowercaseColor = color.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive && model.color?.toLowerCase() == lowercaseColor,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    return _box.values
        .where((model) => model.isActive)
        .map((model) => model.category)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getBrands() async {
    return _box.values
        .where((model) => model.isActive && model.brand != null)
        .map((model) => model.brand!)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getColors() async {
    return _box.values
        .where((model) => model.isActive && model.color != null)
        .map((model) => model.color!)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getSeasons() async {
    return _box.values
        .where((model) => model.isActive && model.season != null)
        .map((model) => model.season!)
        .toSet()
        .toList();
  }

  @override
  Future<List<ClothingItem>> getUnwornClothingItems(DateTime since) async {
    // This would need to be implemented with outfit data
    // For now, return all active items
    return getActiveClothingItems();
  }

  @override
  Future<List<ClothingItem>> getMostWornClothingItems({int limit = 10}) async {
    try {
      final items = await getActiveClothingItems();
      // Sort by wear count (highest first), then by name for tiebreakers
      items.sort((a, b) {
        final wearCountComparison = b.wearCount.compareTo(a.wearCount);
        if (wearCountComparison != 0) return wearCountComparison;
        return a.name.compareTo(b.name);
      });
      return items.take(limit).toList();
    } catch (e) {
      LoggerService.error('Failed to get most worn clothing items: $e');
      return [];
    }
  }

  @override
  Future<double> getTotalClothingValue() async {
    double total = 0.0;
    for (final model in _box.values) {
      if (model.isActive && model.purchasePrice != null) {
        total += model.purchasePrice!;
      }
    }
    return total;
  }

  @override
  Future<void> updateWearCounts(Map<String, int> wearCountMap) async {
    // Update wear count for all clothing items
    for (final model in _box.values) {
      if (model.isActive) {
        final newWearCount = wearCountMap[model.id] ?? 0;
        if (model.wearCount != newWearCount) {
          model.wearCount = newWearCount;
          await _box.put(model.id, model);
        }
      }
    }
  }

  @override
  Future<int> getClothingItemCount() async {
    return _box.values.where((model) => model.isActive).length;
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByOwnedDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.ownedSince != null &&
              model.ownedSince!.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              model.ownedSince!.isBefore(endDate.add(const Duration(days: 1))),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.purchasePrice != null &&
              model.purchasePrice! >= minPrice &&
              model.purchasePrice! <= maxPrice,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsBySubcategory(
    String subcategory,
  ) async {
    final lowercaseSubcategory = subcategory.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.subcategory?.toLowerCase() == lowercaseSubcategory,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByMaterials(
    String materials,
  ) async {
    final lowercaseMaterials = materials.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.materials?.toLowerCase().contains(lowercaseMaterials) ==
                  true,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByOrigin(String origin) async {
    final lowercaseOrigin = origin.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive && model.origin?.toLowerCase() == lowercaseOrigin,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getClothingItemsByLaundryImpact(
    String laundryImpact,
  ) async {
    final lowercaseLaundryImpact = laundryImpact.toLowerCase();
    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.laundryImpact?.toLowerCase() == lowercaseLaundryImpact,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ClothingItem>> getRepairableClothingItems() async {
    return _box.values
        .where((model) => model.isActive && model.repairable == true)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<String>> getSubcategories() async {
    return _box.values
        .where((model) => model.isActive && model.subcategory != null)
        .map((model) => model.subcategory!)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getMaterials() async {
    return _box.values
        .where((model) => model.isActive && model.materials != null)
        .map((model) => model.materials!)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getOrigins() async {
    return _box.values
        .where((model) => model.isActive && model.origin != null)
        .map((model) => model.origin!)
        .toSet()
        .toList();
  }

  @override
  Future<List<String>> getLaundryImpactLevels() async {
    return _box.values
        .where((model) => model.isActive && model.laundryImpact != null)
        .map((model) => model.laundryImpact!)
        .toSet()
        .toList();
  }

  @override
  Future<void> deleteAllClothingItems() async {
    try {
      LoggerService.info('Hard deleting all clothing items...');
      await _box.clear();
      await _ensureDataPersistence();
      LoggerService.info('All clothing items hard deleted successfully');
    } catch (e) {
      LoggerService.error('Failed to hard delete all clothing items: $e');
      rethrow;
    }
  }
}

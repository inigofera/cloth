import '../entities/clothing_item.dart';

/// Abstract repository interface for clothing items
/// This allows us to easily swap implementations (local storage, cloud, etc.)
abstract class ClothingItemRepository {
  /// Adds a new clothing item
  Future<void> addClothingItem(ClothingItem item);

  /// Updates an existing clothing item
  Future<void> updateClothingItem(ClothingItem item);

  /// Deletes a clothing item (soft delete)
  Future<void> deleteClothingItem(String id);

  /// Retrieves a clothing item by ID
  Future<ClothingItem?> getClothingItemById(String id);

  /// Retrieves all clothing items
  Future<List<ClothingItem>> getAllClothingItems();

  /// Retrieves active clothing items only
  Future<List<ClothingItem>> getActiveClothingItems();

  /// Searches clothing items by name or category
  Future<List<ClothingItem>> searchClothingItems(String query);

  /// Retrieves clothing items by category
  Future<List<ClothingItem>> getClothingItemsByCategory(String category);

  /// Retrieves clothing items by subcategory
  Future<List<ClothingItem>> getClothingItemsBySubcategory(String subcategory);

  /// Retrieves clothing items by season
  Future<List<ClothingItem>> getClothingItemsBySeason(String season);

  /// Retrieves clothing items by brand
  Future<List<ClothingItem>> getClothingItemsByBrand(String brand);

  /// Retrieves clothing items by color
  Future<List<ClothingItem>> getClothingItemsByColor(String color);

  /// Retrieves clothing items by materials
  Future<List<ClothingItem>> getClothingItemsByMaterials(String materials);

  /// Retrieves clothing items by origin
  Future<List<ClothingItem>> getClothingItemsByOrigin(String origin);

  /// Retrieves clothing items by laundry impact
  Future<List<ClothingItem>> getClothingItemsByLaundryImpact(
    String laundryImpact,
  );

  /// Retrieves repairable clothing items
  Future<List<ClothingItem>> getRepairableClothingItems();

  /// Normalizes all category names to lowercase to fix case inconsistencies
  Future<void> normalizeCategories();

  /// Gets all available categories
  Future<List<String>> getCategories();

  /// Gets all available subcategories
  Future<List<String>> getSubcategories();

  /// Gets all available brands
  Future<List<String>> getBrands();

  /// Gets all available colors
  Future<List<String>> getColors();

  /// Gets all available materials
  Future<List<String>> getMaterials();

  /// Gets all available seasons
  Future<List<String>> getSeasons();

  /// Gets all available origins
  Future<List<String>> getOrigins();

  /// Gets all available laundry impact levels
  Future<List<String>> getLaundryImpactLevels();

  /// Gets clothing items that haven't been worn recently
  Future<List<ClothingItem>> getUnwornClothingItems(DateTime since);

  /// Gets the most frequently worn clothing items
  Future<List<ClothingItem>> getMostWornClothingItems({int limit = 10});

  /// Gets clothing items by owned date range
  Future<List<ClothingItem>> getClothingItemsByOwnedDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets clothing items by price range
  Future<List<ClothingItem>> getClothingItemsByPriceRange(
    double minPrice,
    double maxPrice,
  );

  /// Gets total count of clothing items
  Future<int> getClothingItemCount();

  /// Gets total value of all clothing items
  Future<double> getTotalClothingValue();

  /// Updates the wear count for clothing items based on outfit data
  /// This method should be called when outfits are added, updated, or deleted
  Future<void> updateWearCounts(Map<String, int> wearCountMap);

  /// Ensures all pending data is flushed to disk
  Future<void> flush();

  /// Hard deletes all clothing items (for complete data deletion)
  Future<void> deleteAllClothingItems();
}

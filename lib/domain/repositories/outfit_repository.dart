import '../entities/outfit.dart';

/// Abstract repository interface for outfits
/// This allows us to easily swap implementations (local storage, cloud, etc.)
abstract class OutfitRepository {
  /// Adds a new outfit
  Future<void> addOutfit(Outfit outfit);
  
  /// Updates an existing outfit
  Future<void> updateOutfit(Outfit outfit);
  
  /// Deletes an outfit (soft delete)
  Future<void> deleteOutfit(String id);
  
  /// Retrieves an outfit by ID
  Future<Outfit?> getOutfitById(String id);
  
  /// Retrieves all outfits
  Future<List<Outfit>> getAllOutfits();
  
  /// Retrieves active outfits only
  Future<List<Outfit>> getActiveOutfits();
  
  /// Retrieves outfits for a specific date
  Future<List<Outfit>> getOutfitsByDate(DateTime date);
  
  /// Retrieves outfits within a date range
  Future<List<Outfit>> getOutfitsByDateRange(DateTime startDate, DateTime endDate);
  
  /// Retrieves outfits that contain a specific clothing item
  Future<List<Outfit>> getOutfitsByClothingItem(String clothingItemId);
  
  /// Retrieves recent outfits (last N days)
  Future<List<Outfit>> getRecentOutfits(int days);
  
  /// Gets total count of outfits
  Future<int> getOutfitCount();
  
  /// Gets the most frequently worn clothing items
  Future<Map<String, int>> getClothingItemWearCount();
  
  /// Gets outfits by month and year
  Future<List<Outfit>> getOutfitsByMonth(int year, int month);
}


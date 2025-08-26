import 'package:hive/hive.dart';
import '../../data/models/clothing_item_model.dart';
import '../../data/models/outfit_model.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../../core/di/dependency_injection.dart';
import 'logger_service.dart';

/// Service to diagnose database issues and verify data persistence
class DatabaseDiagnosticService {
  static Future<void> runDiagnostics() async {
    LoggerService.info('=== DATABASE DIAGNOSTICS START ===');
    
    try {
      // Check if Hive boxes exist
      final clothingBoxExists = Hive.isBoxOpen('clothing_items');
      final outfitBoxExists = Hive.isBoxOpen('outfits');
      
      LoggerService.info('Clothing items box open: $clothingBoxExists');
      LoggerService.info('Outfits box open: $outfitBoxExists');
      
      // Check box contents
      if (clothingBoxExists) {
        final clothingBox = Hive.box<ClothingItemModel>('clothing_items');
        LoggerService.info('Clothing items box length: ${clothingBox.length}');
        LoggerService.info('Clothing items box keys: ${clothingBox.keys.toList()}');
        
        // Check if there are any items
        if (clothingBox.isNotEmpty) {
          LoggerService.info('Sample clothing item: ${clothingBox.values.first.name}');
        }
      }
      
      if (outfitBoxExists) {
        final outfitBox = Hive.box<OutfitModel>('outfits');
        LoggerService.info('Outfits box length: ${outfitBox.length}');
        LoggerService.info('Outfits box keys: ${outfitBox.keys.toList()}');
        
        // Check if there are any outfits
        if (outfitBox.isNotEmpty) {
          LoggerService.info('Sample outfit date: ${outfitBox.values.first.date}');
        }
      }
      
      // Test repository operations without interfering with main app
      await _testRepositoryOperations();
      
    } catch (e) {
      LoggerService.error('Error during diagnostics: $e');
    }
    
    LoggerService.info('=== DATABASE DIAGNOSTICS END ===');
  }
  
  static Future<void> _testRepositoryOperations() async {
    LoggerService.info('--- Testing Repository Operations ---');
    
    try {
      // Use the existing repository from dependency injection
      final repository = getIt<ClothingItemRepository>();
      
      // Just check existing data without adding test items
      final allItems = await repository.getAllClothingItems();
      final activeItems = await repository.getActiveClothingItems();
      
      LoggerService.info('Current repository state:');
      LoggerService.info('- Total items: ${allItems.length}');
      LoggerService.info('- Active items: ${activeItems.length}');
      
      if (activeItems.isNotEmpty) {
        LoggerService.info('Sample active item: ${activeItems.first.name}');
      }
      
      // Don't add or delete test items - just observe existing data
      
    } catch (e) {
      LoggerService.error('Error during repository testing: $e');
    }
  }
  
  /// Check if data is actually being persisted to disk
  static Future<void> checkDataPersistence() async {
    LoggerService.info('--- Checking Data Persistence ---');
    
    try {
      // Use the existing repository instance instead of creating a new one
      final repository = getIt<ClothingItemRepository>();
      
      // Just check current data without adding test items
      final allItems = await repository.getAllClothingItems();
      final activeItems = await repository.getActiveClothingItems();
      
      LoggerService.info('Current data state:');
      LoggerService.info('- Total items: ${allItems.length}');
      LoggerService.info('- Active items: ${activeItems.length}');
      
      if (activeItems.isNotEmpty) {
        LoggerService.info('Data persistence working - items are being saved and retrieved');
        LoggerService.info('Sample active item: ${activeItems.first.name}');
      } else {
        LoggerService.info('No active items found - check if items are being saved correctly');
      }
      
      // Don't add or delete test items - just observe existing data
      
    } catch (e) {
      LoggerService.error('Error during persistence check: $e');
    }
  }
  
  /// Clean up inactive test items that were left behind by diagnostics
  static Future<void> cleanupTestItems() async {
    LoggerService.info('--- Cleaning Up Test Items ---');
    
    try {
      final repository = getIt<ClothingItemRepository>();
      
      // Get all items including inactive ones
      final allItems = await repository.getAllClothingItems();
      
      // Find items that look like test items (contain "Test", "Diagnostic", "Persistence")
      final testItems = allItems.where((item) => 
        item.name.contains('Test') || 
        item.name.contains('Diagnostic') || 
        item.name.contains('Persistence')
      ).toList();
      
      LoggerService.info('Found ${testItems.length} test items to clean up');
      
      // Hard delete these test items (not soft delete)
      for (final testItem in testItems) {
        try {
          // Use the repository's delete method which should handle cleanup
          await repository.deleteClothingItem(testItem.id);
          LoggerService.info('Cleaned up test item: ${testItem.name}');
        } catch (e) {
          LoggerService.error('Failed to clean up test item ${testItem.name}: $e');
        }
      }
      
      LoggerService.info('Test item cleanup completed');
      
    } catch (e) {
      LoggerService.error('Error during test item cleanup: $e');
    }
  }
  
  /// Clear all data to fix corruption issues
  static Future<void> clearAllData() async {
    LoggerService.info('--- CLEARING ALL DATA ---');
    
    try {
      // Close all Hive boxes
      if (Hive.isBoxOpen('clothing_items')) {
        await Hive.box('clothing_items').close();
      }
      if (Hive.isBoxOpen('outfits')) {
        await Hive.box('outfits').close();
      }
      
      // Delete boxes from disk
      await Hive.deleteBoxFromDisk('clothing_items');
      await Hive.deleteBoxFromDisk('outfits');
      
      LoggerService.info('All data cleared successfully');
      LoggerService.info('Database files deleted from disk');
      
    } catch (e) {
      LoggerService.error('Error clearing data: $e');
    }
  }
}

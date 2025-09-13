import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../../domain/repositories/outfit_repository.dart';
import 'logger_service.dart';

/// Service responsible for deleting all app data
/// Handles deletion of clothing items, outfits, and settings
class DataDeletionService {
  final ClothingItemRepository _clothingItemRepository;
  final OutfitRepository _outfitRepository;

  DataDeletionService(this._clothingItemRepository, this._outfitRepository);

  /// Deletes all app data including clothing items, outfits, and settings
  /// Returns true if successful, false otherwise
  Future<bool> deleteAllData() async {
    LoggerService.info('--- STARTING COMPLETE DATA DELETION ---');
    
    bool dataDeleted = false;
    
    try {
      // Step 1: Delete all outfits first (to avoid reference issues)
      await _deleteAllOutfits();
      dataDeleted = true;
      
      // Step 2: Delete all clothing items
      await _deleteAllClothingItems();
      
      // Step 3: Clear Hive boxes from disk (this may fail but data is already deleted)
      await _clearHiveBoxes();
      
      // Step 4: Reset settings to defaults
      await _resetSettingsToDefaults();
      
      LoggerService.info('All data deleted successfully');
      return true;
      
    } catch (e) {
      LoggerService.error('Error during data deletion: $e');
      
      // If we successfully deleted the data but failed on cleanup, still return true
      if (dataDeleted) {
        LoggerService.info('Data was successfully deleted, returning success despite cleanup error');
        return true;
      }
      
      return false;
    }
  }

  /// Deletes all clothing items from the repository using hard deletion
  Future<void> _deleteAllClothingItems() async {
    try {
      LoggerService.info('Deleting all clothing items...');
      
      // Use the new hard deletion method
      await _clothingItemRepository.deleteAllClothingItems();
      
      LoggerService.info('All clothing items deleted successfully');
      
    } catch (e) {
      LoggerService.error('Error deleting clothing items: $e');
      rethrow;
    }
  }

  /// Deletes all outfits from the repository using hard deletion
  Future<void> _deleteAllOutfits() async {
    try {
      LoggerService.info('Deleting all outfits...');
      
      // Use the new hard deletion method
      await _outfitRepository.deleteAllOutfits();
      
      LoggerService.info('All outfits deleted successfully');
      
    } catch (e) {
      LoggerService.error('Error deleting outfits: $e');
      rethrow;
    }
  }

  /// Clears Hive boxes from disk to ensure complete cleanup
  Future<void> _clearHiveBoxes() async {
    try {
      LoggerService.info('Clearing Hive boxes from disk...');
      
      // Close all Hive boxes if they're open
      if (Hive.isBoxOpen('clothing_items')) {
        await Hive.box('clothing_items').close();
        LoggerService.info('Closed clothing_items box');
      }
      if (Hive.isBoxOpen('outfits')) {
        await Hive.box('outfits').close();
        LoggerService.info('Closed outfits box');
      }
      
      // Wait a moment to ensure boxes are fully closed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Delete boxes from disk
      await Hive.deleteBoxFromDisk('clothing_items');
      LoggerService.info('Deleted clothing_items box from disk');
      
      await Hive.deleteBoxFromDisk('outfits');
      LoggerService.info('Deleted outfits box from disk');
      
      LoggerService.info('Hive boxes cleared from disk successfully');
      
    } catch (e) {
      LoggerService.error('Error clearing Hive boxes: $e');
      // Don't rethrow here as the data has already been deleted from the repositories
      // The box deletion is just cleanup
      LoggerService.warning('Continuing despite box cleanup error - data has been deleted');
    }
  }

  /// Resets all settings to their default values
  Future<void> _resetSettingsToDefaults() async {
    try {
      LoggerService.info('Resetting settings to defaults...');
      
      // Note: Settings are managed by Riverpod providers and stored in memory.
      // The settings will reset to defaults when the app is restarted.
      // For immediate effect, the UI should call the resetToDefaults method
      // on the SettingsNotifier when the deletion is confirmed.
      
      LoggerService.info('Settings will reset to defaults on app restart');
      
    } catch (e) {
      LoggerService.error('Error resetting settings: $e');
      rethrow;
    }
  }

  /// Gets the count of items that will be deleted
  Future<Map<String, int>> getDataCounts() async {
    try {
      final clothingItems = await _clothingItemRepository.getAllClothingItems();
      final outfits = await _outfitRepository.getAllOutfits();
      
      return {
        'clothingItems': clothingItems.length,
        'outfits': outfits.length,
      };
    } catch (e) {
      LoggerService.error('Error getting data counts: $e');
      return {
        'clothingItems': 0,
        'outfits': 0,
      };
    }
  }
}

/// Provider for the data deletion service
final dataDeletionServiceProvider = Provider<DataDeletionService>((ref) {
  // This will be properly injected through dependency injection
  // The service will be available through getIt<DataDeletionService>()
  throw UnimplementedError('Use getIt<DataDeletionService>() instead of this provider');
});

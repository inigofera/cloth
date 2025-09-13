import 'package:hive/hive.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../models/outfit_model.dart';
import '../../core/services/logger_service.dart';

/// Hive implementation of OutfitRepository
/// Provides local storage with future cloud sync capabilities
class HiveOutfitRepository implements OutfitRepository {
  static const String _boxName = 'outfits';
  late Box<OutfitModel> _box;

  /// Constructor
  HiveOutfitRepository();

  /// Initializes the Hive box
  Future<void> initialize() async {
    _box = await Hive.openBox<OutfitModel>(_boxName);
  }

  /// Closes the Hive box
  Future<void> close() async {
    await _box.close();
  }

  @override
  Future<void> addOutfit(Outfit outfit) async {
    try {
      final model = OutfitModel.fromEntity(outfit);
      await _box.put(outfit.id, model);
      await _ensureDataPersistence();
      LoggerService.info('Outfit added successfully for date: ${outfit.date}');
    } catch (e) {
      LoggerService.error('Failed to add outfit: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOutfit(Outfit outfit) async {
    try {
      final model = OutfitModel.fromEntity(outfit);
      await _box.put(outfit.id, model);
      await _ensureDataPersistence();
      LoggerService.info(
        'Outfit updated successfully for date: ${outfit.date}',
      );
    } catch (e) {
      LoggerService.error('Failed to update outfit: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOutfit(String id) async {
    final outfit = await getOutfitById(id);
    if (outfit != null) {
      final deactivatedOutfit = outfit.markAsInactive();
      await updateOutfit(deactivatedOutfit);
    }
  }

  @override
  Future<Outfit?> getOutfitById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<List<Outfit>> getAllOutfits() async {
    return _box.values
        .where((model) => model.isActive)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Outfit>> getActiveOutfits() async {
    return _box.values
        .where((model) => model.isActive)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Outfit>> getOutfitsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.date.isAfter(
                startOfDay.subtract(const Duration(milliseconds: 1)),
              ) &&
              model.date.isBefore(endOfDay),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Outfit>> getOutfitsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startOfStartDay = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final endOfEndDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.date.isAfter(
                startOfStartDay.subtract(const Duration(milliseconds: 1)),
              ) &&
              model.date.isBefore(endOfEndDay),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Outfit>> getOutfitsByClothingItem(String clothingItemId) async {
    return _box.values
        .where(
          (model) =>
              model.isActive && model.clothingItemIds.contains(clothingItemId),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Outfit>> getRecentOutfits(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _box.values
        .where((model) => model.isActive && model.date.isAfter(cutoffDate))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<int> getOutfitCount() async {
    return _box.values.where((model) => model.isActive).length;
  }

  @override
  Future<Map<String, int>> getClothingItemWearCount() async {
    final Map<String, int> wearCount = {};

    for (final model in _box.values) {
      if (model.isActive) {
        for (final clothingItemId in model.clothingItemIds) {
          wearCount[clothingItemId] = (wearCount[clothingItemId] ?? 0) + 1;
        }
      }
    }

    return wearCount;
  }

  @override
  Future<List<Outfit>> getOutfitsByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return _box.values
        .where(
          (model) =>
              model.isActive &&
              model.date.isAfter(
                startOfMonth.subtract(const Duration(milliseconds: 1)),
              ) &&
              model.date.isBefore(endOfMonth),
        )
        .map((model) => model.toEntity())
        .toList();
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

  @override
  Future<void> deleteAllOutfits() async {
    try {
      LoggerService.info('Hard deleting all outfits...');
      await _box.clear();
      await _ensureDataPersistence();
      LoggerService.info('All outfits hard deleted successfully');
    } catch (e) {
      LoggerService.error('Failed to hard delete all outfits: $e');
      rethrow;
    }
  }
}

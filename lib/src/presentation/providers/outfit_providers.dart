import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../../data/repositories/hive_outfit_repository.dart';
import '../../data/repositories/hive_clothing_item_repository.dart';
import 'clothing_item_providers.dart';

/// Provider for the outfit repository
final outfitRepositoryProvider = Provider<HiveOutfitRepository>((ref) {
  return HiveOutfitRepository();
});

/// Provider for the clothing item repository
final clothingItemRepositoryProvider = Provider<HiveClothingItemRepository>((
  ref,
) {
  return HiveClothingItemRepository();
});

/// Provider that ensures repositories are initialized before use
final repositoriesReadyProvider = FutureProvider<void>((ref) async {
  final outfitRepo = ref.read(outfitRepositoryProvider);
  final clothingRepo = ref.read(clothingItemRepositoryProvider);

  await outfitRepo.initialize();
  await clothingRepo.initialize();
});

/// Notifier provider for managing outfit state
final outfitNotifierProvider =
    AsyncNotifierProvider<OutfitNotifier, List<Outfit>>(OutfitNotifier.new);

/// Provider for all outfits (no date filtering)
final allOutfitsProvider = Provider<AsyncValue<List<Outfit>>>((ref) {
  final outfitsAsync = ref.watch(outfitNotifierProvider);

  return outfitsAsync.when(
    data: (outfits) {
      // Show all outfits, sorted by date (newest first)
      final sortedOutfits = List<Outfit>.from(outfits)
        ..sort((a, b) => b.date.compareTo(a.date));

      return AsyncValue.data(sortedOutfits);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for active outfits (filtered by date range)
final activeOutfitsProvider = Provider<AsyncValue<List<Outfit>>>((ref) {
  final outfitsAsync = ref.watch(outfitNotifierProvider);

  return outfitsAsync.when(
    data: (outfits) {
      // Filter to show only recent outfits (last 30 days)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final activeOutfits = outfits
          .where((outfit) => outfit.date.isAfter(thirtyDaysAgo))
          .toList();

      return AsyncValue.data(activeOutfits);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for all clothing items (for outfit creation)
final allClothingItemsProvider = FutureProvider<List<ClothingItem>>((
  ref,
) async {
  // Wait for repositories to be ready
  await ref.read(repositoriesReadyProvider.future);

  final repository = ref.read(clothingItemRepositoryProvider);
  return await repository.getAllClothingItems();
});

/// Notifier class for managing outfit operations
class OutfitNotifier extends AsyncNotifier<List<Outfit>> {
  @override
  Future<List<Outfit>> build() async {
    // Wait for repositories to be ready
    await ref.read(repositoriesReadyProvider.future);
    
    try {
      final outfits = await _repository.getAllOutfits();
      // Always ensure we have a valid list
      return outfits;
    } catch (error, _) {
      // If there's an error, return empty list instead of error state
      return <Outfit>[];
    }
  }

  HiveOutfitRepository get _repository => ref.read(outfitRepositoryProvider);

  Future<void> addOutfit(Outfit outfit) async {
    try {
      await _repository.addOutfit(outfit);
      // Refresh the current provider to reload data
      ref.invalidateSelf();
      // Invalidate insights providers since outfit changes affect wear counts
      ref.invalidate(mostWornClothingItemsProvider);
      ref.invalidate(costPerWearRankingProvider);
    } catch (error, _) {
      // Re-throw the error so it can be handled by the UI
      rethrow;
    }
  }

  Future<void> updateOutfit(Outfit outfit) async {
    try {
      await _repository.updateOutfit(outfit);
      // Refresh the current provider to reload data
      ref.invalidateSelf();
      // Invalidate insights providers since outfit changes affect wear counts
      ref.invalidate(mostWornClothingItemsProvider);
      ref.invalidate(costPerWearRankingProvider);
    } catch (error, _) {
      // Re-throw the error so it can be handled by the UI
      rethrow;
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _repository.deleteOutfit(id);
      // Refresh the current provider to reload data
      ref.invalidateSelf();
      // Invalidate insights providers since outfit changes affect wear counts
      ref.invalidate(mostWornClothingItemsProvider);
      ref.invalidate(costPerWearRankingProvider);
    } catch (error, _) {
      // Re-throw the error so it can be handled by the UI
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

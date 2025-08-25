import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../../data/repositories/hive_outfit_repository.dart';
import '../../data/repositories/hive_clothing_item_repository.dart';

/// Provider for the outfit repository
final outfitRepositoryProvider = Provider<HiveOutfitRepository>((ref) {
  return HiveOutfitRepository();
});

/// Provider for the clothing item repository
final clothingItemRepositoryProvider = Provider<HiveClothingItemRepository>((ref) {
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
final outfitNotifierProvider = StateNotifierProvider<OutfitNotifier, AsyncValue<List<Outfit>>>((ref) {
  // Wait for repositories to be ready before creating the notifier
  ref.watch(repositoriesReadyProvider);
  
  final repository = ref.watch(outfitRepositoryProvider);
  return OutfitNotifier(repository);
});

/// Provider for active outfits (filtered by date range)
final activeOutfitsProvider = Provider<AsyncValue<List<Outfit>>>((ref) {
  // Wait for repositories to be ready
  ref.watch(repositoriesReadyProvider);
  
  final outfitsAsync = ref.watch(outfitNotifierProvider);
  
  return outfitsAsync.when(
    data: (outfits) {
      // Ensure outfits is always a valid list
      final validOutfits = outfits ?? <Outfit>[];
      
      // Filter to show only recent outfits (last 30 days)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final activeOutfits = validOutfits.where((outfit) => 
        outfit.date.isAfter(thirtyDaysAgo)
      ).toList();
      
      return AsyncValue.data(activeOutfits);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for all clothing items (for outfit creation)
final allClothingItemsProvider = FutureProvider<List<ClothingItem>>((ref) async {
  // Wait for repositories to be ready
  await ref.read(repositoriesReadyProvider.future);
  
  final repository = ref.read(clothingItemRepositoryProvider);
  return await repository.getAllClothingItems();
});

/// Notifier class for managing outfit operations
class OutfitNotifier extends StateNotifier<AsyncValue<List<Outfit>>> {
  final HiveOutfitRepository _repository;

  OutfitNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    try {
      state = const AsyncValue.loading();
      final outfits = await _repository.getAllOutfits();
      // Always ensure we have a valid list
      state = AsyncValue.data(outfits ?? <Outfit>[]);
    } catch (error, stack) {
      // If there's an error, return empty list instead of error state
      state = AsyncValue.data(<Outfit>[]);
    }
  }

  Future<void> addOutfit(Outfit outfit) async {
    try {
      state = const AsyncValue.loading();
      await _repository.addOutfit(outfit);
      await _loadOutfits();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateOutfit(Outfit outfit) async {
    try {
      state = const AsyncValue.loading();
      await _repository.updateOutfit(outfit);
      await _loadOutfits();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      state = const AsyncValue.loading();
      await _repository.deleteOutfit(id);
      await _loadOutfits();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> refresh() async {
    await _loadOutfits();
  }
}

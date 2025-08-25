import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/usecases/clothing_item_usecases.dart';
import '../../domain/repositories/clothing_item_repository.dart';

/// Provider for clothing item use cases
final clothingItemUseCasesProvider = Provider<ClothingItemUseCases>((ref) {
  return ClothingItemUseCases(
    addClothingItem: getIt<AddClothingItemUseCase>(),
    updateClothingItem: getIt<UpdateClothingItemUseCase>(),
    deleteClothingItem: getIt<DeleteClothingItemUseCase>(),
    searchClothingItems: getIt<SearchClothingItemsUseCase>(),
    getClothingItemsByCategory: getIt<GetClothingItemsByCategoryUseCase>(),
    getClothingItemsBySeason: getIt<GetClothingItemsBySeasonUseCase>(),
    getUnwornClothingItems: getIt<GetUnwornClothingItemsUseCase>(),
    getMostWornClothingItems: getIt<GetMostWornClothingItemsUseCase>(),
    getClothingItemStatistics: getIt<GetClothingItemStatisticsUseCase>(),
  );
});

/// Provider for all active clothing items
final activeClothingItemsProvider = FutureProvider<List<ClothingItem>>((ref) async {
  try {
    final useCases = ref.read(clothingItemUseCasesProvider);
    // Use a more direct method to get active items
    final repository = getIt<ClothingItemRepository>();
    final items = await repository.getActiveClothingItems();
    // Always return a valid list
    return items ?? <ClothingItem>[];
  } catch (e) {
    // If there's an error, return empty list instead of throwing
    return <ClothingItem>[];
  }
});

/// Provider for clothing items by category
final clothingItemsByCategoryProvider = FutureProvider.family<List<ClothingItem>, String>((ref, category) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return await useCases.getClothingItemsByCategory.execute(category);
});

/// Provider for clothing items by season
final clothingItemsBySeasonProvider = FutureProvider.family<List<ClothingItem>, String>((ref, season) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return await useCases.getClothingItemsBySeason.execute(season);
});

/// Provider for clothing item statistics
final clothingItemStatisticsProvider = FutureProvider<ClothingItemStatistics>((ref) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return await useCases.getClothingItemStatistics.execute();
});

/// Provider for unworn clothing items
final unwornClothingItemsProvider = FutureProvider<List<ClothingItem>>((ref) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  return await useCases.getUnwornClothingItems.execute(thirtyDaysAgo);
});

/// Provider for most worn clothing items
final mostWornClothingItemsProvider = FutureProvider<List<ClothingItem>>((ref) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return await useCases.getMostWornClothingItems.execute(limit: 10);
});

/// Provider for clothing item search
final clothingItemSearchProvider = StateProvider<String>((ref) => '');

/// Provider for filtered clothing items based on search
final filteredClothingItemsProvider = FutureProvider.family<List<ClothingItem>, String>((ref, query) async {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return await useCases.searchClothingItems.execute(query);
});

/// Provider for clothing item categories
final clothingItemCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.categories;
});

/// Provider for clothing item brands
final clothingItemBrandsProvider = FutureProvider<List<String>>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.brands;
});

/// Provider for clothing item colors
final clothingItemColorsProvider = FutureProvider<List<String>>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.colors;
});

/// Provider for clothing item seasons
final clothingItemSeasonsProvider = FutureProvider<List<String>>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.seasons;
});

/// Provider for clothing item count
final clothingItemCountProvider = FutureProvider<int>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.totalCount;
});

/// Provider for total clothing value
final totalClothingValueProvider = FutureProvider<double>((ref) async {
  final statistics = await ref.read(clothingItemStatisticsProvider.future);
  return statistics.totalValue;
});

/// Notifier for managing clothing item operations
class ClothingItemNotifier extends StateNotifier<AsyncValue<void>> {
  final ClothingItemUseCases _useCases;
  final Ref _ref;

  ClothingItemNotifier(this._useCases, this._ref) : super(const AsyncValue.data(null));

  /// Adds a new clothing item
  Future<void> addClothingItem(ClothingItem item) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.addClothingItem.execute(item);
      state = const AsyncValue.data(null);
      // Invalidate the activeClothingItemsProvider to refresh the UI
      _ref.invalidate(activeClothingItemsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Updates an existing clothing item
  Future<void> updateClothingItem(ClothingItem item) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.updateClothingItem.execute(item);
      state = const AsyncValue.data(null);
      // Invalidate the activeClothingItemsProvider to refresh the UI
      _ref.invalidate(activeClothingItemsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletes a clothing item
  Future<void> deleteClothingItem(String id) async {
    state = const AsyncValue.loading();
    try {
      await _useCases.deleteClothingItem.execute(id);
      state = const AsyncValue.data(null);
      // Invalidate the activeClothingItemsProvider to refresh the UI
      _ref.invalidate(activeClothingItemsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for clothing item notifier
final clothingItemNotifierProvider = StateNotifierProvider<ClothingItemNotifier, AsyncValue<void>>((ref) {
  final useCases = ref.read(clothingItemUseCasesProvider);
  return ClothingItemNotifier(useCases, ref);
});

/// Convenience class that provides access to all clothing item use cases
class ClothingItemUseCases {
  final AddClothingItemUseCase addClothingItem;
  final UpdateClothingItemUseCase updateClothingItem;
  final DeleteClothingItemUseCase deleteClothingItem;
  final SearchClothingItemsUseCase searchClothingItems;
  final GetClothingItemsByCategoryUseCase getClothingItemsByCategory;
  final GetClothingItemsBySeasonUseCase getClothingItemsBySeason;
  final GetUnwornClothingItemsUseCase getUnwornClothingItems;
  final GetMostWornClothingItemsUseCase getMostWornClothingItems;
  final GetClothingItemStatisticsUseCase getClothingItemStatistics;

  const ClothingItemUseCases({
    required this.addClothingItem,
    required this.updateClothingItem,
    required this.deleteClothingItem,
    required this.searchClothingItems,
    required this.getClothingItemsByCategory,
    required this.getClothingItemsBySeason,
    required this.getUnwornClothingItems,
    required this.getMostWornClothingItems,
    required this.getClothingItemStatistics,
  });
}

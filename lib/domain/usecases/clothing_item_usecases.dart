import '../entities/clothing_item.dart';
import '../repositories/clothing_item_repository.dart';
import '../repositories/outfit_repository.dart';

/// Use case for adding a new clothing item
class AddClothingItemUseCase {
  final ClothingItemRepository _repository;

  const AddClothingItemUseCase(this._repository);

  Future<void> execute(ClothingItem item) async {
    // Business logic validation
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Clothing item name cannot be empty');
    }
    
    if (item.category.trim().isEmpty) {
      throw ArgumentError('Clothing item category cannot be empty');
    }
    
    // Check if item with same name and category already exists
    final existingItems = await _repository.searchClothingItems(item.name);
    final duplicateExists = existingItems.any((existing) => 
      existing.name.toLowerCase() == item.name.toLowerCase() && 
      existing.category.toLowerCase() == item.category.toLowerCase() &&
      existing.isActive
    );
    
    if (duplicateExists) {
      throw ArgumentError('A clothing item with this name and category already exists');
    }
    
    await _repository.addClothingItem(item);
  }
}

/// Use case for updating a clothing item
class UpdateClothingItemUseCase {
  final ClothingItemRepository _repository;

  const UpdateClothingItemUseCase(this._repository);

  Future<void> execute(ClothingItem item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Clothing item name cannot be empty');
    }
    
    if (item.category.trim().isEmpty) {
      throw ArgumentError('Clothing item category cannot be empty');
    }
    
    await _repository.updateClothingItem(item);
  }
}

/// Use case for deleting a clothing item
class DeleteClothingItemUseCase {
  final ClothingItemRepository _repository;

  const DeleteClothingItemUseCase(this._repository);

  Future<void> execute(String id) async {
    await _repository.deleteClothingItem(id);
  }
}

/// Use case for searching clothing items
class SearchClothingItemsUseCase {
  final ClothingItemRepository _repository;

  const SearchClothingItemsUseCase(this._repository);

  Future<List<ClothingItem>> execute(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getActiveClothingItems();
    }
    
    return await _repository.searchClothingItems(query.trim());
  }
}

/// Use case for getting clothing items by category
class GetClothingItemsByCategoryUseCase {
  final ClothingItemRepository _repository;

  const GetClothingItemsByCategoryUseCase(this._repository);

  Future<List<ClothingItem>> execute(String category) async {
    return await _repository.getClothingItemsByCategory(category);
  }
}

/// Use case for getting clothing items by season
class GetClothingItemsBySeasonUseCase {
  final ClothingItemRepository _repository;

  const GetClothingItemsBySeasonUseCase(this._repository);

  Future<List<ClothingItem>> execute(String season) async {
    return await _repository.getClothingItemsBySeason(season);
  }
}

/// Use case for getting unworn clothing items
class GetUnwornClothingItemsUseCase {
  final ClothingItemRepository _repository;

  const GetUnwornClothingItemsUseCase(this._repository);

  Future<List<ClothingItem>> execute(DateTime since) async {
    return await _repository.getUnwornClothingItems(since);
  }
}

/// Use case for getting most worn clothing items
class GetMostWornClothingItemsUseCase {
  final ClothingItemRepository _repository;

  const GetMostWornClothingItemsUseCase(this._repository);

  Future<List<ClothingItem>> execute({int limit = 10}) async {
    return await _repository.getMostWornClothingItems(limit: limit);
  }
}

/// Use case for getting clothing item statistics
class GetClothingItemStatisticsUseCase {
  final ClothingItemRepository _repository;

  const GetClothingItemStatisticsUseCase(this._repository);

  Future<ClothingItemStatistics> execute() async {
    final totalCount = await _repository.getClothingItemCount();
    final totalValue = await _repository.getTotalClothingValue();
    final categories = await _repository.getCategories();
    final brands = await _repository.getBrands();
    final colors = await _repository.getColors();
    final seasons = await _repository.getSeasons();
    
    return ClothingItemStatistics(
      totalCount: totalCount,
      totalValue: totalValue,
      categories: categories,
      brands: brands,
      colors: colors,
      seasons: seasons,
    );
  }
}

/// Statistics about clothing items
class ClothingItemStatistics {
  final int totalCount;
  final double totalValue;
  final List<String> categories;
  final List<String> brands;
  final List<String> colors;
  final List<String> seasons;

  const ClothingItemStatistics({
    required this.totalCount,
    required this.totalValue,
    required this.categories,
    required this.brands,
    required this.colors,
    required this.seasons,
  });
}

/// Use case for getting clothing items with wear count
class GetClothingItemsWithWearCountUseCase {
  final ClothingItemRepository _clothingItemRepository;
  final OutfitRepository _outfitRepository;

  const GetClothingItemsWithWearCountUseCase(
    this._clothingItemRepository,
    this._outfitRepository,
  );

  Future<List<ClothingItem>> execute() async {
    // Get all active clothing items
    final clothingItems = await _clothingItemRepository.getActiveClothingItems();
    
    // Get wear count for all clothing items
    final wearCountMap = await _outfitRepository.getClothingItemWearCount();
    
    // Update clothing items with their wear count
    return clothingItems.map((item) {
      final wearCount = wearCountMap[item.id] ?? 0;
      return item.copyWith(wearCount: wearCount);
    }).toList();
  }
}

/// Use case for getting clothing items by category with wear count
class GetClothingItemsByCategoryWithWearCountUseCase {
  final ClothingItemRepository _clothingItemRepository;
  final OutfitRepository _outfitRepository;

  const GetClothingItemsByCategoryWithWearCountUseCase(
    this._clothingItemRepository,
    this._outfitRepository,
  );

  Future<List<ClothingItem>> execute(String category) async {
    // Get clothing items by category
    final clothingItems = await _clothingItemRepository.getClothingItemsByCategory(category);
    
    // Get wear count for all clothing items
    final wearCountMap = await _outfitRepository.getClothingItemWearCount();
    
    // Update clothing items with their wear count
    return clothingItems.map((item) {
      final wearCount = wearCountMap[item.id] ?? 0;
      return item.copyWith(wearCount: wearCount);
    }).toList();
  }
}

/// Use case for getting most worn clothing items with actual wear count
class GetMostWornClothingItemsWithWearCountUseCase {
  final ClothingItemRepository _clothingItemRepository;
  final OutfitRepository _outfitRepository;

  const GetMostWornClothingItemsWithWearCountUseCase(
    this._clothingItemRepository,
    this._outfitRepository,
  );

  Future<List<ClothingItem>> execute({int limit = 10}) async {
    // Get all active clothing items
    final clothingItems = await _clothingItemRepository.getActiveClothingItems();
    
    // Get wear count for all clothing items
    final wearCountMap = await _outfitRepository.getClothingItemWearCount();
    
    // Update clothing items with their wear count and sort by wear count
    final itemsWithWearCount = clothingItems.map((item) {
      final wearCount = wearCountMap[item.id] ?? 0;
      return item.copyWith(wearCount: wearCount);
    }).toList();
    
    // Sort by wear count (descending) and take the limit
    itemsWithWearCount.sort((a, b) => b.wearCount.compareTo(a.wearCount));
    return itemsWithWearCount.take(limit).toList();
  }
}

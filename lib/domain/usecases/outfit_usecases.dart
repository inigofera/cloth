import '../entities/outfit.dart';
import '../repositories/outfit_repository.dart';

/// Use case for adding a new outfit
class AddOutfitUseCase {
  final OutfitRepository _repository;

  AddOutfitUseCase(this._repository);

  Future<void> execute(Outfit outfit) async {
    await _repository.addOutfit(outfit);
  }
}

/// Use case for updating an existing outfit
class UpdateOutfitUseCase {
  final OutfitRepository _repository;

  UpdateOutfitUseCase(this._repository);

  Future<void> execute(Outfit outfit) async {
    await _repository.updateOutfit(outfit);
  }
}

/// Use case for deleting an outfit
class DeleteOutfitUseCase {
  final OutfitRepository _repository;

  DeleteOutfitUseCase(this._repository);

  Future<void> execute(String id) async {
    await _repository.deleteOutfit(id);
  }
}

/// Use case for getting outfits by date
class GetOutfitsByDateUseCase {
  final OutfitRepository _repository;

  GetOutfitsByDateUseCase(this._repository);

  Future<List<Outfit>> execute(DateTime date) async {
    return await _repository.getOutfitsByDate(date);
  }
}

/// Use case for getting outfits by date range
class GetOutfitsByDateRangeUseCase {
  final OutfitRepository _repository;

  GetOutfitsByDateRangeUseCase(this._repository);

  Future<List<Outfit>> execute(DateTime startDate, DateTime endDate) async {
    return await _repository.getOutfitsByDateRange(startDate, endDate);
  }
}

/// Use case for getting recent outfits
class GetRecentOutfitsUseCase {
  final OutfitRepository _repository;

  GetRecentOutfitsUseCase(this._repository);

  Future<List<Outfit>> execute(int days) async {
    return await _repository.getRecentOutfits(days);
  }
}

/// Use case for getting outfit statistics
class GetOutfitStatisticsUseCase {
  final OutfitRepository _repository;

  GetOutfitStatisticsUseCase(this._repository);

  Future<OutfitStatistics> execute() async {
    final totalOutfits = await _repository.getOutfitCount();
    final recentOutfits = await _repository.getRecentOutfits(7);
    final clothingItemWearCount = await _repository.getClothingItemWearCount();
    
    return OutfitStatistics(
      totalOutfits: totalOutfits,
      outfitsThisWeek: recentOutfits.length,
      clothingItemWearCount: clothingItemWearCount,
    );
  }
}

/// Use case for getting outfits by month
class GetOutfitsByMonthUseCase {
  final OutfitRepository _repository;

  GetOutfitsByMonthUseCase(this._repository);

  Future<List<Outfit>> execute(int year, int month) async {
    return await _repository.getOutfitsByMonth(year, month);
  }
}

/// Data class for outfit statistics
class OutfitStatistics {
  final int totalOutfits;
  final int outfitsThisWeek;
  final Map<String, int> clothingItemWearCount;

  const OutfitStatistics({
    required this.totalOutfits,
    required this.outfitsThisWeek,
    required this.clothingItemWearCount,
  });
}


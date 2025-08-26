import 'package:get_it/get_it.dart';
import '../../data/repositories/hive_clothing_item_repository.dart';
import '../../data/repositories/hive_outfit_repository.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../../domain/usecases/clothing_item_usecases.dart';
import '../../domain/usecases/outfit_usecases.dart';
import '../../core/services/data_persistence_service.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Sets up dependency injection for the application
/// This allows for easy swapping of implementations and future scalability
class DependencyInjection {
  static Future<void> setup() async {
    // Register repositories
    _registerRepositories();
    
    // Register services
    _registerServices();
    
    // Register use cases
    _registerUseCases();
    
    // Initialize repositories that need async setup
    await initializeRepositories();
    
    // Initialize services that need setup
    await initializeServices();
  }

  /// Registers repository implementations
  static void _registerRepositories() {
    // Register clothing item repository
    getIt.registerLazySingleton<ClothingItemRepository>(
      () => HiveClothingItemRepository(),
    );
    
    // Register outfit repository
    getIt.registerLazySingleton<OutfitRepository>(
      () => HiveOutfitRepository(),
    );
  }

  /// Registers services
  static void _registerServices() {
    getIt.registerLazySingleton<DataPersistenceService>(
      () => DataPersistenceService(
        getIt<ClothingItemRepository>(),
        getIt<OutfitRepository>(),
      ),
    );
  }

  /// Initializes all repositories that need async initialization
  static Future<void> initializeRepositories() async {
    // Initialize Hive repositories
    final clothingItemRepo = getIt<ClothingItemRepository>() as HiveClothingItemRepository;
    await clothingItemRepo.initialize();
    
    final outfitRepo = getIt<OutfitRepository>() as HiveOutfitRepository;
    await outfitRepo.initialize();
  }

  /// Initializes all services that need setup
  static Future<void> initializeServices() async {
    final dataPersistenceService = getIt<DataPersistenceService>();
    await dataPersistenceService.initialize();
  }


  /// Registers use cases
  static void _registerUseCases() {
    getIt.registerLazySingleton<AddClothingItemUseCase>(() => AddClothingItemUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<UpdateClothingItemUseCase>(() => UpdateClothingItemUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<DeleteClothingItemUseCase>(() => DeleteClothingItemUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<SearchClothingItemsUseCase>(() => SearchClothingItemsUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetClothingItemsByCategoryUseCase>(() => GetClothingItemsByCategoryUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetClothingItemsBySeasonUseCase>(() => GetClothingItemsBySeasonUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetUnwornClothingItemsUseCase>(() => GetUnwornClothingItemsUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetMostWornClothingItemsUseCase>(() => GetMostWornClothingItemsUseCase(getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetClothingItemStatisticsUseCase>(() => GetClothingItemStatisticsUseCase(getIt<ClothingItemRepository>()));
    
    // New use cases for wear count
    getIt.registerLazySingleton<GetClothingItemsWithWearCountUseCase>(() => GetClothingItemsWithWearCountUseCase(getIt<ClothingItemRepository>(), getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetClothingItemsByCategoryWithWearCountUseCase>(() => GetClothingItemsByCategoryWithWearCountUseCase(getIt<ClothingItemRepository>(), getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetMostWornClothingItemsWithWearCountUseCase>(() => GetMostWornClothingItemsWithWearCountUseCase(getIt<ClothingItemRepository>(), getIt<OutfitRepository>()));

    // Register outfit use cases
    getIt.registerLazySingleton<AddOutfitUseCase>(() => AddOutfitUseCase(getIt<OutfitRepository>(), getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<UpdateOutfitUseCase>(() => UpdateOutfitUseCase(getIt<OutfitRepository>(), getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<DeleteOutfitUseCase>(() => DeleteOutfitUseCase(getIt<OutfitRepository>(), getIt<ClothingItemRepository>()));
    getIt.registerLazySingleton<GetOutfitsByDateUseCase>(() => GetOutfitsByDateUseCase(getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetOutfitsByDateRangeUseCase>(() => GetOutfitsByDateRangeUseCase(getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetRecentOutfitsUseCase>(() => GetRecentOutfitsUseCase(getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetOutfitStatisticsUseCase>(() => GetOutfitStatisticsUseCase(getIt<OutfitRepository>()));
    getIt.registerLazySingleton<GetOutfitsByMonthUseCase>(() => GetOutfitsByMonthUseCase(getIt<OutfitRepository>()));
  }

  /// Registers a custom repository implementation
  /// This allows for easy swapping of implementations (e.g., cloud vs local)
  static void registerCustomClothingItemRepository(ClothingItemRepository repository) {
    getIt.registerSingleton<ClothingItemRepository>(repository);
  }

  /// Resets all registrations (useful for testing)
  static void reset() {
    getIt.reset();
  }
}

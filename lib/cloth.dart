/// Cloth - An open source tool for sustainable fashion
/// 
/// This library provides a comprehensive API for managing clothing items,
/// outfits, and sustainable fashion tracking.
library cloth;

// Domain Entities - Core business objects
export 'src/domain/entities/clothing_item.dart';
export 'src/domain/entities/outfit.dart';

// Repository Interfaces - Data access contracts
export 'src/domain/repositories/clothing_item_repository.dart';
export 'src/domain/repositories/outfit_repository.dart';

// Use Cases - Business logic operations
export 'src/domain/usecases/clothing_item_usecases.dart';
export 'src/domain/usecases/outfit_usecases.dart';

// Core Services - Essential functionality
export 'src/core/services/data_persistence_service.dart';
export 'src/core/services/data_export_service.dart';
export 'src/core/services/logger_service.dart';

// Constants - Public constants and enums
export 'src/core/constants/app_constants.dart';

// Utilities - Public utility functions
export 'src/core/utils/currency_formatter.dart';

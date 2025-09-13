# Cloth API Documentation

## Overview

The Cloth library provides a comprehensive API for managing clothing items, outfits, and sustainable fashion tracking. This document outlines the public API that is available for external consumption.

## Public API Structure

The public API is defined in `lib/cloth.dart` and follows a clean architecture pattern with clear separation between public interfaces and private implementation details.

### Library Entry Point

```dart
import 'package:cloth/cloth.dart';
```

## Domain Entities

### ClothingItem

The core entity representing a single piece of clothing.

```dart
class ClothingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String? brand;
  final String? color;
  final String? materials;
  final String? season;
  final double? purchasePrice;
  final DateTime? ownedSince;
  final String? origin;
  final String? laundryImpact;
  final bool? repairable;
  final String? notes;
  final Uint8List? imageData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int wearCount;
}
```

**Key Methods:**
- `ClothingItem.create()` - Factory constructor for creating new items
- `copyWith()` - Creates a copy with updated fields
- `markAsInactive()` - Soft delete functionality
- `updateLastModified()` - Updates the last modified timestamp

### Outfit

Represents an outfit worn on a specific day.

```dart
class Outfit extends Equatable {
  final String id;
  final DateTime date;
  final List<String> clothingItemIds;
  final String? notes;
  final Uint8List? imageData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}
```

**Key Methods:**
- `Outfit.create()` - Factory constructor for creating new outfits
- `copyWith()` - Creates a copy with updated fields
- `addClothingItem(String id)` - Adds a clothing item to the outfit
- `removeClothingItem(String id)` - Removes a clothing item from the outfit
- `markAsInactive()` - Soft delete functionality

## Repository Interfaces

### ClothingItemRepository

Abstract interface for clothing item data operations.

```dart
abstract class ClothingItemRepository {
  // CRUD Operations
  Future<void> addClothingItem(ClothingItem item);
  Future<void> updateClothingItem(ClothingItem item);
  Future<void> deleteClothingItem(String id);
  Future<ClothingItem?> getClothingItemById(String id);
  Future<List<ClothingItem>> getAllClothingItems();
  Future<List<ClothingItem>> getActiveClothingItems();
  
  // Search and Filter Operations
  Future<List<ClothingItem>> searchClothingItems(String query);
  Future<List<ClothingItem>> getClothingItemsByCategory(String category);
  Future<List<ClothingItem>> getClothingItemsBySeason(String season);
  Future<List<ClothingItem>> getClothingItemsByBrand(String brand);
  Future<List<ClothingItem>> getClothingItemsByColor(String color);
  
  // Analytics Operations
  Future<List<ClothingItem>> getUnwornClothingItems(DateTime since);
  Future<List<ClothingItem>> getMostWornClothingItems({int limit = 10});
  Future<Map<String, int>> getClothingItemWearCount();
  
  // Statistics
  Future<int> getClothingItemCount();
  Future<double> getTotalClothingValue();
  Future<List<String>> getCategories();
  Future<List<String>> getBrands();
  Future<List<String>> getColors();
}
```

### OutfitRepository

Abstract interface for outfit data operations.

```dart
abstract class OutfitRepository {
  // CRUD Operations
  Future<void> addOutfit(Outfit outfit);
  Future<void> updateOutfit(Outfit outfit);
  Future<void> deleteOutfit(String id);
  Future<Outfit?> getOutfitById(String id);
  Future<List<Outfit>> getAllOutfits();
  Future<List<Outfit>> getActiveOutfits();
  
  // Query Operations
  Future<List<Outfit>> getOutfitsByDate(DateTime date);
  Future<List<Outfit>> getOutfitsByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Outfit>> getOutfitsByClothingItem(String clothingItemId);
  Future<List<Outfit>> getRecentOutfits(int days);
  Future<List<Outfit>> getOutfitsByMonth(int year, int month);
  
  // Analytics
  Future<Map<String, int>> getClothingItemWearCount();
  Future<int> getOutfitCount();
}
```

## Use Cases

### Clothing Item Use Cases

Business logic operations for clothing items.

```dart
// Individual Use Cases
class AddClothingItemUseCase
class UpdateClothingItemUseCase
class DeleteClothingItemUseCase
class SearchClothingItemsUseCase
class GetClothingItemsByCategoryUseCase
class GetClothingItemsBySeasonUseCase
class GetUnwornClothingItemsUseCase
class GetMostWornClothingItemsUseCase
class GetClothingItemStatisticsUseCase
class GetClothingItemsWithWearCountUseCase
class GetClothingItemsByCostPerWearUseCase

// Statistics Data Class
class ClothingItemStatistics {
  final int totalCount;
  final double totalValue;
  final List<String> categories;
  final List<String> brands;
  final List<String> colors;
  final List<String> seasons;
}
```

### Outfit Use Cases

Business logic operations for outfits.

```dart
// Individual Use Cases
class AddOutfitUseCase
class UpdateOutfitUseCase
class DeleteOutfitUseCase
class GetOutfitsByDateUseCase
class GetOutfitsByDateRangeUseCase
class GetRecentOutfitsUseCase
class GetOutfitStatisticsUseCase
class GetOutfitsByMonthUseCase

// Statistics Data Class
class OutfitStatistics {
  final int totalOutfits;
  final int outfitsThisWeek;
  final Map<String, int> clothingItemWearCount;
}
```

## Core Services

### DataPersistenceService

Handles data persistence and app lifecycle events.

```dart
class DataPersistenceService {
  DataPersistenceService(ClothingItemRepository clothingItemRepository, OutfitRepository outfitRepository);
  
  void initialize();
  void dispose();
}
```

### DataExportService

Handles data export and import functionality.

```dart
class DataExportService {
  static Future<void> exportData();
  static Future<void> importData(String filePath);
  static Future<String> generateExportData();
}
```

### LoggerService

Centralized logging service.

```dart
class LoggerService {
  static void info(String message);
  static void warning(String message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]);
}
```

## Constants

### AppConstants

Application-wide constants.

```dart
class AppConstants {
  static const String appName = 'Cloth';
  static const String appVersion = '1.0.0';
  // ... other constants
}
```

## Utilities

### CurrencyFormatter

Utility for formatting currency values.

```dart
class CurrencyFormatter {
  static String format(double amount, {String? currencyCode});
  static String formatWithSymbol(double amount, String symbol);
}
```

## Usage Examples

### Basic Clothing Item Management

```dart
import 'package:cloth/cloth.dart';

// Create a new clothing item
final clothingItem = ClothingItem.create(
  name: 'Blue Jeans',
  category: 'pants',
  subcategory: 'jeans',
  brand: 'Levi\'s',
  color: 'blue',
  purchasePrice: 89.99,
);

// Add to repository
await clothingItemRepository.addClothingItem(clothingItem);

// Search for items
final searchResults = await clothingItemRepository.searchClothingItems('jeans');
```

### Outfit Management

```dart
// Create a new outfit
final outfit = Outfit.create(
  date: DateTime.now(),
  clothingItemIds: ['item1', 'item2', 'item3'],
  notes: 'Casual Friday outfit',
);

// Add to repository
await outfitRepository.addOutfit(outfit);

// Get outfits for a specific date
final todaysOutfits = await outfitRepository.getOutfitsByDate(DateTime.now());
```

### Analytics and Insights

```dart
// Get most worn items
final mostWorn = await clothingItemRepository.getMostWornClothingItems(limit: 5);

// Get unworn items
final unwornItems = await clothingItemRepository.getUnwornClothingItems(
  DateTime.now().subtract(Duration(days: 30))
);

// Get cost per wear analysis
final costPerWearUseCase = GetClothingItemsByCostPerWearUseCase(
  clothingItemRepository, 
  outfitRepository
);
final costAnalysis = await costPerWearUseCase.execute(
  categories: ['shirts', 'pants'],
  ascending: true,
  limit: 10,
);
```

## Versioning Strategy

The public API follows semantic versioning:

- **Major version (X.0.0)**: Breaking changes to the public API
- **Minor version (0.X.0)**: New features added to the public API
- **Patch version (0.0.X)**: Bug fixes and internal improvements

### Breaking Changes

Breaking changes include:
- Removing public classes, methods, or properties
- Changing method signatures
- Changing the behavior of existing methods
- Removing or changing constants

### Non-Breaking Changes

Non-breaking changes include:
- Adding new public classes, methods, or properties
- Adding optional parameters to existing methods
- Adding new constants
- Internal implementation changes (as long as they don't affect the public API)

## Implementation Notes

- All public classes are immutable by default
- Use cases handle business logic validation
- Repository interfaces allow for easy testing and implementation swapping
- The API is designed to be extensible and maintainable
- Error handling is consistent across all operations
- All async operations return `Future` types

## Dependencies

The public API has minimal external dependencies:
- `equatable` - For value equality
- `uuid` - For unique ID generation
- `dart:typed_data` - For image data handling

Internal implementation may use additional dependencies (Hive, Riverpod, etc.) but these are not exposed through the public API.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/outfit.dart';

/// Service for exporting and importing app data
class DataExportService {
  static const String _exportVersion = '1.0.0';
  
  /// Exports all data to JSON format
  static Future<String> exportToJson({
    required List<ClothingItem> clothingItems,
    required List<Outfit> outfits,
  }) async {
    final exportData = {
      'version': _exportVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'clothingItems': clothingItems.map((item) => _clothingItemToJson(item)).toList(),
      'outfits': outfits.map((outfit) => _outfitToJson(outfit)).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }
  
  /// Exports data to CSV format (clothing items only, no images)
  static String exportToCsv({
    required List<ClothingItem> clothingItems,
    required List<Outfit> outfits,
  }) {
    final buffer = StringBuffer();
    
    // Clothing items CSV
    buffer.writeln('=== CLOTHING ITEMS ===');
    buffer.writeln('ID,Name,Category,Subcategory,Brand,Color,Materials,Season,Purchase Price,Owned Since,Origin,Laundry Impact,Repairable,Notes,Wear Count,Created At,Updated At,Is Active');
    
    for (final item in clothingItems) {
      buffer.writeln([
        item.id,
        _escapeCsvField(item.name),
        _escapeCsvField(item.category),
        _escapeCsvField(item.subcategory ?? ''),
        _escapeCsvField(item.brand ?? ''),
        _escapeCsvField(item.color ?? ''),
        _escapeCsvField(item.materials ?? ''),
        _escapeCsvField(item.season ?? ''),
        item.purchasePrice?.toString() ?? '',
        item.ownedSince?.toIso8601String() ?? '',
        _escapeCsvField(item.origin ?? ''),
        _escapeCsvField(item.laundryImpact ?? ''),
        item.repairable?.toString() ?? '',
        _escapeCsvField(item.notes ?? ''),
        item.wearCount.toString(),
        item.createdAt.toIso8601String(),
        item.updatedAt.toIso8601String(),
        item.isActive.toString(),
      ].join(','));
    }
    
    // Outfits CSV
    buffer.writeln('\n=== OUTFITS ===');
    buffer.writeln('ID,Date,Clothing Item IDs,Notes,Created At,Updated At,Is Active');
    
    for (final outfit in outfits) {
      buffer.writeln([
        outfit.id,
        outfit.date.toIso8601String(),
        _escapeCsvField(outfit.clothingItemIds.join(';')),
        _escapeCsvField(outfit.notes ?? ''),
        outfit.createdAt.toIso8601String(),
        outfit.updatedAt.toIso8601String(),
        outfit.isActive.toString(),
      ].join(','));
    }
    
    return buffer.toString();
  }
  
  /// Saves export data to a file and shares it
  static Future<void> shareExportFile({
    required String data,
    required String filename,
    required String mimeType,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(data);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Cloth app data export',
    );
  }
  
  /// Imports data from JSON format
  static Future<ImportResult> importFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate version compatibility
      final version = data['version'] as String?;
      if (version != _exportVersion) {
        return ImportResult(
          success: false,
          error: 'Unsupported export version: $version. Expected: $_exportVersion',
        );
      }
      
      final clothingItems = <ClothingItem>[];
      final outfits = <Outfit>[];
      
      // Import clothing items
      final clothingItemsData = data['clothingItems'] as List<dynamic>? ?? [];
      for (final itemData in clothingItemsData) {
        try {
          clothingItems.add(_clothingItemFromJson(itemData as Map<String, dynamic>));
        } catch (e) {
          // Log error but continue with other items
          print('Error importing clothing item: $e');
        }
      }
      
      // Import outfits
      final outfitsData = data['outfits'] as List<dynamic>? ?? [];
      for (final outfitData in outfitsData) {
        try {
          outfits.add(_outfitFromJson(outfitData as Map<String, dynamic>));
        } catch (e) {
          // Log error but continue with other outfits
          print('Error importing outfit: $e');
        }
      }
      
      return ImportResult(
        success: true,
        clothingItems: clothingItems,
        outfits: outfits,
        importedAt: DateTime.now(),
      );
      
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to parse JSON: $e',
      );
    }
  }
  
  /// Converts ClothingItem to JSON
  static Map<String, dynamic> _clothingItemToJson(ClothingItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'subcategory': item.subcategory,
      'brand': item.brand,
      'color': item.color,
      'materials': item.materials,
      'season': item.season,
      'purchasePrice': item.purchasePrice,
      'ownedSince': item.ownedSince?.toIso8601String(),
      'origin': item.origin,
      'laundryImpact': item.laundryImpact,
      'repairable': item.repairable,
      'notes': item.notes,
      'imageData': item.imageData != null ? base64Encode(item.imageData!) : null,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'isActive': item.isActive,
      'wearCount': item.wearCount,
    };
  }
  
  /// Converts JSON to ClothingItem
  static ClothingItem _clothingItemFromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      materials: json['materials'] as String?,
      season: json['season'] as String?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      ownedSince: json['ownedSince'] != null 
          ? DateTime.parse(json['ownedSince'] as String) 
          : null,
      origin: json['origin'] as String?,
      laundryImpact: json['laundryImpact'] as String?,
      repairable: json['repairable'] as bool?,
      notes: json['notes'] as String?,
      imageData: json['imageData'] != null 
          ? base64Decode(json['imageData'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      wearCount: json['wearCount'] as int? ?? 0,
    );
  }
  
  /// Converts Outfit to JSON
  static Map<String, dynamic> _outfitToJson(Outfit outfit) {
    return {
      'id': outfit.id,
      'date': outfit.date.toIso8601String(),
      'clothingItemIds': outfit.clothingItemIds,
      'notes': outfit.notes,
      'imageData': outfit.imageData != null ? base64Encode(outfit.imageData!) : null,
      'createdAt': outfit.createdAt.toIso8601String(),
      'updatedAt': outfit.updatedAt.toIso8601String(),
      'isActive': outfit.isActive,
    };
  }
  
  /// Converts JSON to Outfit
  static Outfit _outfitFromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      clothingItemIds: List<String>.from(json['clothingItemIds'] as List),
      notes: json['notes'] as String?,
      imageData: json['imageData'] != null 
          ? base64Decode(json['imageData'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  /// Escapes CSV field values
  static String _escapeCsvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String? error;
  final List<ClothingItem> clothingItems;
  final List<Outfit> outfits;
  final DateTime? importedAt;
  
  const ImportResult({
    required this.success,
    this.error,
    this.clothingItems = const [],
    this.outfits = const [],
    this.importedAt,
  });
}

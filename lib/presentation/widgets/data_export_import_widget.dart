import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/data_export_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/outfit.dart';

/// Widget for exporting and importing app data
class DataExportImportWidget extends ConsumerStatefulWidget {
  final List<ClothingItem> clothingItems;
  final List<Outfit> outfits;
  
  const DataExportImportWidget({
    super.key,
    required this.clothingItems,
    required this.outfits,
  });

  @override
  ConsumerState<DataExportImportWidget> createState() => _DataExportImportWidgetState();
}

class _DataExportImportWidgetState extends ConsumerState<DataExportImportWidget> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Export & Import',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Export your clothing items and outfits to backup or share your data.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Export section
            _buildExportSection(),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Import section
            _buildImportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a format to export your data:',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                label: 'JSON (Complete)',
                description: 'Includes all data and images',
                icon: Icons.code,
                onPressed: _isExporting ? null : () => _exportData('json'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportButton(
                label: 'CSV (Spreadsheet)',
                description: 'For Excel/Google Sheets',
                icon: Icons.table_chart,
                onPressed: _isExporting ? null : () => _exportData('csv'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Import Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Import data from a previously exported file:',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isImporting ? null : _importData,
            icon: _isImporting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_isImporting ? 'Importing...' : 'Import JSON File'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton({
    required String label,
    required String description,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String format) async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      String data;
      String filename;
      String mimeType;

      if (format == 'json') {
        data = await DataExportService.exportToJson(
          clothingItems: widget.clothingItems,
          outfits: widget.outfits,
        );
        filename = 'cloth_export_${DateTime.now().millisecondsSinceEpoch}.json';
        mimeType = 'application/json';
      } else {
        data = DataExportService.exportToCsv(
          clothingItems: widget.clothingItems,
          outfits: widget.outfits,
        );
        filename = 'cloth_export_${DateTime.now().millisecondsSinceEpoch}.csv';
        mimeType = 'text/csv';
      }

      await DataExportService.shareExportFile(
        data: data,
        filename: filename,
        mimeType: mimeType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importData() async {
    if (_isImporting) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        
        if (filePath != null) {
          final file = File(filePath);
          final jsonData = await file.readAsString();
          
          final importResult = await DataExportService.importFromJson(jsonData);
          
          if (mounted) {
            if (importResult.success) {
              // Actually save the imported data to the database
              await _saveImportedData(importResult);
              _showImportSuccessDialog(importResult);
            } else {
              _showImportErrorDialog(importResult.error ?? 'Unknown error');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showImportErrorDialog('Import failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  /// Saves imported data to the database
  Future<void> _saveImportedData(ImportResult result) async {
    try {
      // Get repositories
      final clothingItemRepo = getIt<ClothingItemRepository>();
      final outfitRepo = getIt<OutfitRepository>();
      
      // Save clothing items
      for (final item in result.clothingItems) {
        try {
          await clothingItemRepo.addClothingItem(item);
        } catch (e) {
          LoggerService.error('Error saving clothing item ${item.name}: $e');
          // Continue with other items even if one fails
        }
      }
      
      // Save outfits
      for (final outfit in result.outfits) {
        try {
          await outfitRepo.addOutfit(outfit);
        } catch (e) {
          LoggerService.error('Error saving outfit ${outfit.id}: $e');
          // Continue with other outfits even if one fails
        }
      }
      
      LoggerService.info('Successfully saved ${result.clothingItems.length} clothing items and ${result.outfits.length} outfits');
    } catch (e) {
      LoggerService.error('Error saving imported data: $e');
      rethrow;
    }
  }

  void _showImportSuccessDialog(ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully imported:'),
            const SizedBox(height: 8),
            Text('• ${result.clothingItems.length} clothing items'),
            Text('• ${result.outfits.length} outfits'),
            const SizedBox(height: 8),
            const Text(
              'Note: You may need to refresh the app to see the imported data.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

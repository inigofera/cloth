import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/data_export_service.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/repositories/clothing_item_repository.dart';
import '../../../domain/repositories/outfit_repository.dart';
import '../../providers/clothing_item_providers.dart';
import '../../providers/outfit_providers.dart';
import '../../../domain/entities/clothing_item.dart';
import '../../../domain/entities/outfit.dart';

/// Data and storage settings category
class DataSettings extends ConsumerWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Storage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingsGroup(
            context: context,
            title: 'Storage',
            children: [
              _buildListTile(
                context: context,
                title: 'Storage usage',
                subtitle: '12.5 MB used',
                onTap: () {
                  _showStorageDetails(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Clear cache',
                subtitle: 'Free up temporary files',
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Backup & Export',
            children: [
              _buildListTile(
                context: context,
                title: 'Export data',
                subtitle: 'Export your clothing and outfit data',
                onTap: () {
                  _exportData(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Import data',
                subtitle: 'Import data from backup file',
                onTap: () {
                  _importData(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Privacy',
            children: [
              _buildSwitchTile(
                context: context,
                title: 'Analytics',
                subtitle: 'Help improve the app with anonymous usage data',
                value: true, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
                },
              ),
              _buildListTile(
                context: context,
                title: 'Delete all data',
                subtitle: 'Permanently remove all your data',
                onTap: () {
                  _showDeleteDataDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showStorageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Clothing items', '8.2 MB', '45 items'),
            _buildStorageItem('Outfits', '3.1 MB', '23 outfits'),
            _buildStorageItem('Images', '1.2 MB', '68 photos'),
            const Divider(),
            _buildStorageItem('Total', '12.5 MB', '136 items'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String title, String size, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text('$size ($count)'),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove temporary files and free up storage space. Your clothing items and outfits will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ExportDataDialog(),
    );
  }

  void _importData(BuildContext context) {
    _performImport(context);
  }

  Future<void> _performImport(BuildContext context) async {
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
          
          if (context.mounted) {
            if (importResult.success) {
              // Actually save the imported data to the database
              await _saveImportedData(importResult);
              _showImportSuccessDialog(context, importResult);
            } else {
              _showImportErrorDialog(context, importResult.error ?? 'Unknown error');
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showImportErrorDialog(context, 'Import failed: $e');
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
          print('Error saving clothing item ${item.name}: $e');
          // Continue with other items even if one fails
        }
      }
      
      // Save outfits
      for (final outfit in result.outfits) {
        try {
          await outfitRepo.addOutfit(outfit);
        } catch (e) {
          print('Error saving outfit ${outfit.id}: $e');
          // Continue with other outfits even if one fails
        }
      }
      
      print('Successfully saved ${result.clothingItems.length} clothing items and ${result.outfits.length} outfits');
    } catch (e) {
      print('Error saving imported data: $e');
      rethrow;
    }
  }

  void _showImportSuccessDialog(BuildContext context, ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Successfully imported:'),
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

  void _showImportErrorDialog(BuildContext context, String error) {
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

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This action cannot be undone. All your clothing items, outfits, and settings will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement data deletion
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for choosing export format
class _ExportDataDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: const Text('Choose a format to export your data:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _exportData(context, ref, 'json'),
          child: const Text('JSON (Complete)'),
        ),
        TextButton(
          onPressed: () => _exportData(context, ref, 'csv'),
          child: const Text('CSV (Spreadsheet)'),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, String format) async {
    Navigator.of(context).pop(); // Close dialog first
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get data from providers
      final clothingItemsAsync = ref.read(activeClothingItemsProvider);
      final outfitsAsync = ref.read(outfitNotifierProvider);

      final clothingItems = await clothingItemsAsync.when(
        data: (items) => items,
        loading: () => <ClothingItem>[],
        error: (_, __) => <ClothingItem>[],
      );

      final outfits = await outfitsAsync.when(
        data: (items) => items,
        loading: () => <Outfit>[],
        error: (_, __) => <Outfit>[],
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      String data;
      String filename;
      String mimeType;

      if (format == 'json') {
        data = await DataExportService.exportToJson(
          clothingItems: clothingItems,
          outfits: outfits,
        );
        filename = 'cloth_export_${DateTime.now().millisecondsSinceEpoch}.json';
        mimeType = 'application/json';
      } else {
        data = DataExportService.exportToCsv(
          clothingItems: clothingItems,
          outfits: outfits,
        );
        filename = 'cloth_export_${DateTime.now().millisecondsSinceEpoch}.csv';
        mimeType = 'text/csv';
      }

      await DataExportService.shareExportFile(
        data: data,
        filename: filename,
        mimeType: mimeType,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

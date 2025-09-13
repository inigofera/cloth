import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/clothing_item_providers.dart';
import '../providers/settings_providers.dart';
import '../../core/utils/currency_formatter.dart';
import 'edit_clothing_item_form.dart';

/// Detail page for displaying comprehensive information about a clothing item
class ClothingItemDetailPage extends ConsumerWidget {
  final ClothingItem item;

  const ClothingItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes to clothing items to get the most up-to-date data
    final clothingItemsAsync = ref.watch(activeClothingItemsProvider);

    return clothingItemsAsync.when(
      data: (clothingItems) {
        // Find the current item data (in case it was updated)
        final currentItem = clothingItems.firstWhere(
          (clothingItem) => clothingItem.id == item.id,
          orElse: () => item, // Fallback to original item if not found
        );

        return _buildDetailPage(context, ref, currentItem);
      },
      loading: () => _buildDetailPage(context, ref, item),
      error: (error, stack) => _buildDetailPage(context, ref, item),
    );
  }

  Widget _buildDetailPage(
    BuildContext context,
    WidgetRef ref,
    ClothingItem currentItem,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context, currentItem),
            tooltip: 'Edit Item',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, ref, currentItem),
            tooltip: 'Delete Item',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            _buildImageSection(context, currentItem),
            const SizedBox(height: 24),

            // Basic information
            _buildBasicInfoSection(context, currentItem),
            const SizedBox(height: 24),

            // Detailed information
            _buildDetailedInfoSection(context, currentItem),
            const SizedBox(height: 24),

            // Purchase information
            _buildPurchaseInfoSection(context, currentItem),
            const SizedBox(height: 24),

            // Usage statistics
            _buildUsageStatsSection(context, currentItem),
            const SizedBox(height: 24),

            // Notes section
            if (currentItem.notes != null && currentItem.notes!.isNotEmpty) ...[
              _buildNotesSection(context, currentItem),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ClothingItem currentItem) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: currentItem.imageData != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(currentItem.imageData!, fit: BoxFit.cover),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checkroom,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image available',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    ClothingItem currentItem,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', currentItem.name),
            _buildInfoRow('Category', currentItem.category),
            if (currentItem.subcategory != null)
              _buildInfoRow('Type', currentItem.subcategory!),
            if (currentItem.brand != null)
              _buildInfoRow('Brand', currentItem.brand!),
            if (currentItem.color != null)
              _buildInfoRow('Color', currentItem.color!),
            if (currentItem.materials != null)
              _buildInfoRow('Materials', currentItem.materials!),
            if (currentItem.season != null)
              _buildInfoRow('Season', currentItem.season!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfoSection(
    BuildContext context,
    ClothingItem currentItem,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (currentItem.origin != null)
              _buildInfoRow('Origin', currentItem.origin!),
            if (currentItem.laundryImpact != null)
              _buildInfoRow('Laundry Impact', currentItem.laundryImpact!),
            _buildInfoRow(
              'Repairable',
              currentItem.repairable == true ? 'Yes' : 'No',
            ),
            _buildInfoRow(
              'Owned Since',
              currentItem.ownedSince != null
                  ? '${currentItem.ownedSince!.day}/${currentItem.ownedSince!.month}/${currentItem.ownedSince!.year}'
                  : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseInfoSection(
    BuildContext context,
    ClothingItem currentItem,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (currentItem.purchasePrice != null)
              Consumer(
                builder: (context, ref, child) {
                  final currency = ref.watch(currencyProvider);
                  return _buildInfoRow(
                    'Purchase Price',
                    CurrencyFormatter.formatPrice(
                      currentItem.purchasePrice!,
                      currency,
                    ),
                  );
                },
              ),
            if (currentItem.purchasePrice != null && currentItem.wearCount > 0)
              Consumer(
                builder: (context, ref, child) {
                  final currency = ref.watch(currencyProvider);
                  final costPerWear =
                      currentItem.purchasePrice! / currentItem.wearCount;
                  return _buildInfoRow(
                    'Cost Per Wear',
                    CurrencyFormatter.formatPrice(costPerWear, currency),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsSection(
    BuildContext context,
    ClothingItem currentItem,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Times Worn', currentItem.wearCount.toString()),
            _buildInfoRow(
              'Last Updated',
              '${currentItem.updatedAt.day}/${currentItem.updatedAt.month}/${currentItem.updatedAt.year}',
            ),
            _buildInfoRow(
              'Created',
              '${currentItem.createdAt.day}/${currentItem.createdAt.month}/${currentItem.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ClothingItem currentItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                currentItem.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, ClothingItem currentItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClothingItemForm(clothingItem: currentItem),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ClothingItem currentItem,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${currentItem.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(clothingItemNotifierProvider.notifier)
                  .deleteClothingItem(currentItem.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to items list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

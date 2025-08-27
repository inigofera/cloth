import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/clothing_item.dart';
import 'add_clothing_item_form.dart';

/// Main view for displaying and managing clothing items
class ClothingItemsView extends ConsumerWidget {
  const ClothingItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothingItemsAsync = ref.watch(activeClothingItemsProvider);
    final currentSortOption = ref.watch(clothingItemsSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Items'),
        actions: [
          // Sorting dropdown
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort items',
            onSelected: (SortOption option) {
              // Update the provider instead of local state
              ref.read(clothingItemsSortOptionProvider.notifier).state = option;
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<SortOption>(
                value: SortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Sort Alphabetically'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.wearCountAscending,
                child: Row(
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 8),
                    Text('Sort by Wears (Low to High)'),
                  ],
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.wearCountDescending,
                child: Row(
                  children: [
                    Icon(Icons.trending_down),
                    SizedBox(width: 8),
                    Text('Sort by Wears (High to Low)'),
                  ],
                ),
              ),
            ],
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Trigger a refresh by invalidating the provider
              ref.invalidate(activeClothingItemsProvider);
            },
            tooltip: 'Refresh wear counts',
          ),
        ],
      ),
      body: clothingItemsAsync.when(
        data: (items) => _buildContent(context, ref, items, currentSortOption),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddClothingItemForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<ClothingItem> items, SortOption currentSortOption) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No clothing items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add your first item',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort items based on current sort option
    final sortedItems = _sortItems(items, currentSortOption);

    // Group items by category
    final groupedItems = <String, List<ClothingItem>>{};
    for (final item in sortedItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;
        
        return _buildCategorySection(context, ref, category, categoryItems);
      },
    );
  }

  /// Sort items based on the current sort option
  List<ClothingItem> _sortItems(List<ClothingItem> items, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.alphabetical:
        return List.from(items)..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.wearCountAscending:
        return List.from(items)..sort((a, b) => a.wearCount.compareTo(b.wearCount));
      case SortOption.wearCountDescending:
        return List.from(items)..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    }
  }

  Widget _buildCategorySection(BuildContext context, WidgetRef ref, String category, List<ClothingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...items.map((item) => _buildClothingItemCard(context, ref, item)),
      ],
    );
  }

  Widget _buildClothingItemCard(BuildContext context, WidgetRef ref, ClothingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(item.category),
          child: Icon(
            _getCategoryIcon(item.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.brand != null) Text('Brand: ${item.brand}'),
            if (item.color != null) Text('Color: ${item.color}'),
            if (item.subcategory != null) Text('Type: ${item.subcategory}'),
            // Add wear count display
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Worn ${item.wearCount} time${item.wearCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              // TODO: Implement edit functionality
            } else if (value == 'delete') {
              _showDeleteDialog(context, ref, item);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shirt':
        return Colors.blue;
      case 'pants':
        return Colors.green;
      case 'dress':
        return Colors.purple;
      case 'shoes':
        return Colors.brown;
      case 'accessories':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shirt':
        return Icons.checkroom;
      case 'pants':
        return Icons.accessibility;
      case 'dress':
        return Icons.style;
      case 'shoes':
        return Icons.sports_soccer;
      case 'accessories':
        return Icons.watch;
      default:
        return Icons.checkroom;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ClothingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(clothingItemNotifierProvider.notifier).deleteClothingItem(item.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

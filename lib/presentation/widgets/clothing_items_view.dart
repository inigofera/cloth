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

    return Scaffold(
      body: clothingItemsAsync.when(
        data: (items) => _buildContent(context, ref, items),
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

  Widget _buildContent(BuildContext context, WidgetRef ref, List<ClothingItem> items) {
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

    // Group items by category
    final groupedItems = <String, List<ClothingItem>>{};
    for (final item in items) {
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

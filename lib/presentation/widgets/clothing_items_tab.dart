import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/clothing_item.dart';
import 'add_clothing_item_form.dart';
import 'edit_clothing_item_form.dart';

/// Main view for displaying and managing clothing items
class ClothingItemsView extends ConsumerWidget {
  const ClothingItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothingItemsAsync = ref.watch(activeClothingItemsProvider);
    
    return Scaffold(
      body: clothingItemsAsync.when(
        data: (clothingItems) => _buildContent(context, ref, clothingItems),
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

  Widget _buildContent(BuildContext context, WidgetRef ref, List<ClothingItem> clothingItems) {
    if (clothingItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No clothing items yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: clothingItems.length,
      itemBuilder: (context, index) {
        final item = clothingItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}'),
                if (item.brand != null) Text('Brand: ${item.brand}'),
                if (item.color != null) Text('Color: ${item.color}'),
                if (item.materials != null) Text('Materials: ${item.materials}'),
                if (item.purchasePrice != null) Text('Price: \$${item.purchasePrice!.toStringAsFixed(2)}'),
                if (item.origin != null) Text('Origin: ${item.origin}'),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditClothingItemForm(clothingItem: item),
                    ),
                  );
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
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'base layer':
        return Icons.checkroom;
      case 'outerwear':
        return Icons.ac_unit;
      case 'bottoms':
        return Icons.accessibility;
      case 'accessories':
        return Icons.watch;
      case 'footwear':
        return Icons.sports_soccer;
      case 'formal wear':
        return Icons.business;
      case 'sportswear':
        return Icons.fitness_center;
      default:
        return Icons.checkroom;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'base layer':
        return Colors.blue;
      case 'outerwear':
        return Colors.grey;
      case 'bottoms':
        return Colors.green;
      case 'accessories':
        return Colors.orange;
      case 'footwear':
        return Colors.brown;
      case 'formal wear':
        return Colors.purple;
      case 'sportswear':
        return Colors.red;
      default:
        return Colors.blueGrey;
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/clothing_item_providers.dart';
import '../../providers/settings_providers.dart';
import '../../domain/entities/clothing_item.dart';
import '../../core/utils/currency_formatter.dart';
import 'add_clothing_item_form.dart';
import 'clothing_item_thumbnail.dart';
import 'clothing_item_detail_page.dart';

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
            leading: ClothingItemThumbnail(
              item: item,
              size: 40,
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
                if (item.purchasePrice != null) 
                  Consumer(
                    builder: (context, ref, child) {
                      final currency = ref.watch(currencyProvider);
                      return Text('Price: ${CurrencyFormatter.formatPrice(item.purchasePrice!, currency)}');
                    },
                  ),
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClothingItemDetailPage(item: item),
                ),
              );
            },
            isThreeLine: true,
          ),
        );
      },
    );
  }




}

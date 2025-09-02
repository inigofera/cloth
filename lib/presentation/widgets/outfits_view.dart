import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/outfit_providers.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import 'add_outfit_form.dart';
import 'edit_outfit_form.dart';
import 'outfit_calendar_view.dart';
import 'clothing_item_thumbnail.dart';

/// Main view for displaying and managing outfits
class OutfitsView extends ConsumerStatefulWidget {
  const OutfitsView({super.key});

  @override
  ConsumerState<OutfitsView> createState() => _OutfitsViewState();
}

class _OutfitsViewState extends ConsumerState<OutfitsView> {
  bool _isCalendarView = false;

  @override
  Widget build(BuildContext context) {
    final outfitsAsync = ref.watch(activeOutfitsProvider);

    return Scaffold(
      body: outfitsAsync.when(
        data: (outfits) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outfits',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
                    onPressed: () {
                      setState(() {
                        _isCalendarView = !_isCalendarView;
                      });
                    },
                    tooltip: _isCalendarView ? 'Switch to List View' : 'Switch to Calendar View',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isCalendarView 
                  ? OutfitCalendarView(outfits: outfits)
                  : _buildListView(context, ref, outfits),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(outfitNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddOutfitForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, List<Outfit> outfits) {
    // outfits is guaranteed to be a valid list (never null)
    if (outfits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No outfits logged yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to log your first outfit',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort outfits by date (most recent first)
    outfits.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        return _buildOutfitCard(context, ref, outfit);
      },
    );
  }

  Widget _buildOutfitCard(BuildContext context, WidgetRef ref, Outfit outfit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(outfit.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editOutfit(context, outfit);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, ref, outfit);
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
              ],
            ),
            const SizedBox(height: 12),

            // Clothing items
            FutureBuilder<List<ClothingItem>>(
              future: _getClothingItemsForOutfit(ref, outfit),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error loading items: ${snapshot.error}');
                }

                final clothingItems = snapshot.data ?? [];
                if (clothingItems.isEmpty) {
                  return const Text(
                    'No clothing items found',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  );
                }

                return Column(
                  children: clothingItems.map((item) => _buildClothingItemTile(item)).toList(),
                );
              },
            ),

            // Notes
            if (outfit.notes != null && outfit.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  outfit.notes!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemTile(ClothingItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClothingItemThumbnail(
        item: item,
        size: 32,
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Future<List<ClothingItem>> _getClothingItemsForOutfit(WidgetRef ref, Outfit outfit) async {
    final clothingItemsAsync = ref.read(activeClothingItemsProvider.future);
    final clothingItems = await clothingItemsAsync;
    
    return clothingItems
        .where((item) => outfit.clothingItemIds.contains(item.id))
        .toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final outfitDate = DateTime(date.year, date.month, date.day);

    if (outfitDate == today) {
      return 'Today';
    } else if (outfitDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Outfit outfit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Outfit'),
          content: Text('Are you sure you want to delete the outfit from ${_formatDate(outfit.date)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(outfitNotifierProvider.notifier).deleteOutfit(outfit.id);
                
                // Trigger a refresh of the clothing items by invalidating the provider
                ref.invalidate(activeClothingItemsProvider);
                
                // Check if the widget is still mounted before using context
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _editOutfit(BuildContext context, Outfit outfit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditOutfitForm(outfit: outfit),
      ),
    );
  }
}

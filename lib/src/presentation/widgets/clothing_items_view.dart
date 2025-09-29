import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/clothing_item.dart';
import 'add_clothing_item_form.dart';
import 'clothing_item_thumbnail.dart';
import 'clothing_item_detail_page.dart';

/// Main view for displaying and managing clothing items
class ClothingItemsView extends ConsumerStatefulWidget {
  const ClothingItemsView({super.key});

  @override
  ConsumerState<ClothingItemsView> createState() => _ClothingItemsViewState();
}

class _ClothingItemsViewState extends ConsumerState<ClothingItemsView> {
  // Track which categories are expanded
  final Set<String> _expandedCategories = <String>{};

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync search controller with provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchQuery = ref.read(clothingItemSearchProvider);
      if (_searchController.text != searchQuery) {
        _searchController.text = searchQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clothingItemsAsync = ref.watch(activeClothingItemsProvider);
    final currentSortOption = ref.watch(clothingItemsSortOptionProvider);
    final searchQuery = ref.watch(clothingItemSearchProvider);

    return Scaffold(
      body: clothingItemsAsync.when(
        data: (items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Clothing Items',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items by name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(clothingItemSearchProvider.notifier)
                                .updateSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(clothingItemSearchProvider.notifier)
                      .updateSearch(value);
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: _buildContent(
                context,
                ref,
                items,
                currentSortOption,
                searchQuery,
              ),
            ),
          ],
        ),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ClothingItem> items,
    SortOption currentSortOption,
    String searchQuery,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, size: 64, color: Colors.grey),
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

    // Filter items based on search query
    List<ClothingItem> filteredItems = items;
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filteredItems = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(lowercaseQuery) ||
                item.category.toLowerCase().contains(lowercaseQuery) ||
                (item.subcategory?.toLowerCase().contains(lowercaseQuery) ??
                    false) ||
                (item.brand?.toLowerCase().contains(lowercaseQuery) ?? false) ||
                (item.color?.toLowerCase().contains(lowercaseQuery) ?? false) ||
                (item.materials?.toLowerCase().contains(lowercaseQuery) ??
                    false) ||
                (item.origin?.toLowerCase().contains(lowercaseQuery) ?? false),
          )
          .toList();
    }

    // Show no results message if search returns empty
    if (searchQuery.isNotEmpty && filteredItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort items based on current sort option
    final sortedItems = _sortItems(filteredItems, currentSortOption);

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
  List<ClothingItem> _sortItems(
    List<ClothingItem> items,
    SortOption sortOption,
  ) {
    switch (sortOption) {
      case SortOption.alphabetical:
        return List.from(items)..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.wearCountAscending:
        return List.from(items)
          ..sort((a, b) => a.wearCount.compareTo(b.wearCount));
      case SortOption.wearCountDescending:
        return List.from(items)
          ..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    }
  }

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<ClothingItem> items,
  ) {
    final isExpanded = _expandedCategories.contains(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          // Category header that's always clickable
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(category);
                } else {
                  _expandedCategories.add(category);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(category),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${items.length} item${items.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: items
                    .map((item) => _buildClothingItemCard(context, ref, item))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClothingItemCard(
    BuildContext context,
    WidgetRef ref,
    ClothingItem item,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: ClothingItemThumbnail(item: item, size: 40),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.brand != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.branding_watermark,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Brand: ${item.brand}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (item.color != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  children: [
                    Icon(Icons.palette, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Color: ${item.color}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            if (item.subcategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  children: [
                    Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Type: ${item.subcategory}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            // Add wear count display
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 14, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Worn ${item.wearCount} time${item.wearCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
}

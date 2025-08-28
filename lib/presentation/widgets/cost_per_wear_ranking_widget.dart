import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/clothing_item.dart';

/// Widget for displaying clothing items ranked by cost per wear
class CostPerWearRankingWidget extends ConsumerStatefulWidget {
  const CostPerWearRankingWidget({super.key});

  @override
  ConsumerState<CostPerWearRankingWidget> createState() => _CostPerWearRankingWidgetState();
}

class _CostPerWearRankingWidgetState extends ConsumerState<CostPerWearRankingWidget> {
  final List<String> _selectedCategories = [];
  bool _isAscending = false;
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(clothingItemCategoriesProvider.future);
      setState(() {
        _availableCategories = categories;
      });
    } catch (e) {
      // Handle error silently, will show empty list
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = CostPerWearParams(
      categories: _selectedCategories,
      ascending: _isAscending,
    );
    

    
    final costPerWearItemsAsync = ref.watch(costPerWearRankingProvider(params));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and sort toggle
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cost per Wear Ranking',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Sort order toggle
                IconButton(
                  onPressed: _toggleSortOrder,
                  icon: Icon(
                    _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: _isAscending ? 'Lowest to Highest' : 'Highest to Lowest',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category filter chips
            if (_availableCategories.isNotEmpty) ...[
              Text(
                'Filter by Category:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _toggleCategory(category),
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Cost per wear leaderboard
            costPerWearItemsAsync.when(
              data: (items) => _buildCostPerWearLeaderboard(context, items),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading data: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostPerWearLeaderboard(BuildContext context, List<ClothingItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or add more clothing items with prices and wear history.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

            ],
          ),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final costPerWear = item.purchasePrice! / item.wearCount;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getRankingColor(context, index),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getRankingBorderColor(context, index),
              width: index == 0 ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Ranking badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankingBadgeColor(context, index),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _getRankingTextColor(context, index),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getRankingTextColor(context, index),
                      ),
                    ),
                    if (item.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.brand!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getRankingTextColor(context, index).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRankingTextColor(context, index).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cost per wear and details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRankingTextColor(context, index).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\$${costPerWear.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getRankingTextColor(context, index),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                                     Text(
                     '${item.wearCount}x worn',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: _getRankingTextColor(context, index).withValues(alpha: 0.7),
                     ),
                   ),
                  Text(
                    'Price: \$${item.purchasePrice!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getRankingTextColor(context, index).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getRankingColor(BuildContext context, int index) {
    switch (index) {
      case 0: // Gold
        return const Color(0xFFFFF8E1);
      case 1: // Silver
        return const Color(0xFFF5F5F5);
      case 2: // Bronze
        return const Color(0xFFFFF3E0);
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Color _getRankingBorderColor(BuildContext context, int index) {
    switch (index) {
      case 0: // Gold
        return const Color(0xFFFFD700);
      case 1: // Silver
        return const Color(0xFFC0C0C0);
      case 2: // Bronze
        return const Color(0xFFCD7F32);
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  Color _getRankingBadgeColor(BuildContext context, int index) {
    switch (index) {
      case 0: // Gold
        return const Color(0xFFFFD700);
      case 1: // Silver
        return const Color(0xFFC0C0C0);
      case 2: // Bronze
        return const Color(0xFFCD7F32);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getRankingTextColor(BuildContext context, int index) {
    switch (index) {
      case 0: // Gold
        return const Color(0xFFB8860B);
      case 1: // Silver
        return const Color(0xFF696969);
      case 2: // Bronze
        return const Color(0xFF8B4513);
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}

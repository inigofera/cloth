import 'package:flutter/material.dart';
import '../../domain/entities/clothing_item.dart';

class SelectedClothingItemBadge extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onRemove;
  final bool isCompact;

  const SelectedClothingItemBadge({
    super.key,
    required this.item,
    required this.onRemove,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(
          item.name,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        avatar: Icon(
          _getCategoryIcon(item.category),
          size: isCompact ? 16 : 18,
        ),
        deleteIcon: Icon(
          Icons.close,
          size: isCompact ? 16 : 18,
        ),
        onDeleted: onRemove,
        backgroundColor: theme.colorScheme.primaryContainer,
        deleteIconColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
        ),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
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
}

class SelectedClothingItemsDisplay extends StatelessWidget {
  final List<ClothingItem> selectedItems;
  final Function(ClothingItem) onRemoveItem;
  final bool isCompact;

  const SelectedClothingItemsDisplay({
    super.key,
    required this.selectedItems,
    required this.onRemoveItem,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Items (${selectedItems.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            children: selectedItems.map((item) {
              return SelectedClothingItemBadge(
                item: item,
                onRemove: () => onRemoveItem(item),
                isCompact: isCompact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

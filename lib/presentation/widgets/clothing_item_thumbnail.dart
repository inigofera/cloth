import 'package:flutter/material.dart';
import '../../domain/entities/clothing_item.dart';

class ClothingItemThumbnail extends StatelessWidget {
  final ClothingItem item;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ClothingItemThumbnail({
    super.key,
    required this.item,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? _getCategoryColor(item.category);
    final defaultIconColor = iconColor ?? Colors.white;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: defaultBackgroundColor,
      child: item.imageData != null
          ? ClipOval(
              child: Image.memory(
                item.imageData!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return Icon(
                    _getCategoryIcon(item.category),
                    color: defaultIconColor,
                    size: size * 0.6,
                  );
                },
              ),
            )
          : Icon(
              _getCategoryIcon(item.category),
              color: defaultIconColor,
              size: size * 0.6,
            ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'base layer':
        return Colors.blue.shade600;
      case 'outerwear':
        return Colors.grey.shade600;
      case 'bottoms':
        return Colors.brown.shade600;
      case 'accessories':
        return Colors.purple.shade600;
      case 'footwear':
        return Colors.orange.shade600;
      case 'formal wear':
        return Colors.indigo.shade600;
      case 'sportswear':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
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

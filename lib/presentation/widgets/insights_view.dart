import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/clothing_item_providers.dart';
import '../../domain/entities/clothing_item.dart';
import 'cost_per_wear_ranking_widget.dart';

/// Insights view showing analytics and metrics about clothing items and outfits
class InsightsView extends ConsumerWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostWornItemsAsync = ref.watch(mostWornClothingItemsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Most Worn Items Leaderboard Card
            _buildMostWornLeaderboardCard(context, ref, mostWornItemsAsync),
            
            const SizedBox(height: 16),
            
            // Cost per Wear Ranking Card
            const CostPerWearRankingWidget(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMostWornLeaderboardCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ClothingItem>> mostWornItemsAsync,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Most Worn Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            mostWornItemsAsync.when(
              data: (items) => _buildLeaderboard(context, items),
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

  Widget _buildLeaderboard(BuildContext context, List<ClothingItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No clothing items found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Sort by wear count and take top 3 (including items with 0 wear count)
    final topItems = items.toList()
      ..sort((a, b) => b.wearCount.compareTo(a.wearCount));

    final displayItems = topItems.take(3).toList();

    return Column(
      children: displayItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isFirst = index == 0;
        final isSecond = index == 1;
        final isThird = index == 2;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getRankingColor(context, index),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getRankingBorderColor(context, index),
              width: isFirst ? 2 : 1,
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
                          color: _getRankingTextColor(context, index).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Wear count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRankingTextColor(context, index).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${item.wearCount}x',
                  style: TextStyle(
                    color: _getRankingTextColor(context, index),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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

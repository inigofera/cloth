import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/clothing_items_view.dart';
import '../widgets/outfits_view.dart';
import '../widgets/insights_view.dart';

/// Main home screen for clothing items and outfits management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClothingItemsView(),
    const OutfitsView(),
    const InsightsView(),
  ];

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Clothing Items';
      case 1:
        return 'Outfits';
      case 2:
        return 'Insights';
      default:
        return 'Cloth';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1 ? null : AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Clothing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Outfits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}

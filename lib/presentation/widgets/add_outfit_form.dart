import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/outfit_providers.dart';
import '../providers/clothing_item_providers.dart';
import 'clothing_item_thumbnail.dart';

class AddOutfitForm extends ConsumerStatefulWidget {
  const AddOutfitForm({super.key});

  @override
  ConsumerState<AddOutfitForm> createState() => _AddOutfitFormState();
}

class _AddOutfitFormState extends ConsumerState<AddOutfitForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedClothingItemIds = [];
  String _searchQuery = '';
  final Set<String> _selectedCategories = <String>{};

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)), // Allow today
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleClothingItem(String clothingItemId) {
    setState(() {
      final newList = List<String>.from(_selectedClothingItemIds);
      if (newList.contains(clothingItemId)) {
        newList.remove(clothingItemId);
      } else {
        newList.add(clothingItemId);
      }
      _selectedClothingItemIds = newList;
    });
  }

  List<ClothingItem> _filterClothingItems(List<ClothingItem> items) {
    List<ClothingItem> filteredItems = items;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.subcategory?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Filter by selected categories
    if (_selectedCategories.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          _selectedCategories.contains(item.category)
      ).toList();
    }
    
    return filteredItems;
  }

  Set<String> _getAvailableCategories(List<ClothingItem> items) {
    return items.map((item) => item.category).toSet();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClothingItemIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one clothing item')),
        );
        return;
      }

      try {
        final outfit = Outfit.create(
          date: _selectedDate,
          clothingItemIds: _selectedClothingItemIds,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );

        await ref.read(outfitNotifierProvider.notifier).addOutfit(outfit);
        
        // Trigger a refresh of the clothing items by invalidating the provider
        ref.invalidate(activeClothingItemsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Outfit logged successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clothingItemsAsync = ref.watch(activeClothingItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Outfit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Date selection
            ListTile(
              title: const Text('Date'),
              subtitle: Text(_selectedDate.toString().split(' ')[0]),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for clothing items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Category filter chips
            clothingItemsAsync.when(
              data: (clothingItems) {
                final availableCategories = _getAvailableCategories(clothingItems);
                if (availableCategories.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableCategories.map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) => _toggleCategory(category),
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.outline,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedCategories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategories.clear();
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear all filters'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Clothing items selection
            const Text(
              'Select Clothing Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            clothingItemsAsync.when(
              data: (clothingItems) {
                final filteredItems = _filterClothingItems(clothingItems);
                return _buildClothingItemsList(filteredItems);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Special occasion, weather, etc.',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _selectedClothingItemIds.isNotEmpty ? _submitForm : null,
              child: const Text('Log Outfit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemsList(List<ClothingItem> clothingItems) {
    if (clothingItems.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No clothing items available. Please add some clothing items first.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      children: clothingItems.map((item) {
        final isSelected = _selectedClothingItemIds.contains(item.id);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
          child: ListTile(
            leading: ClothingItemThumbnail(
              item: item,
              size: 32,
              backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : null,
              iconColor: isSelected 
                  ? Colors.white
                  : null,
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}',
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            onTap: () => _toggleClothingItem(item.id),
          ),
        );
      }).toList(),
    );
  }
}

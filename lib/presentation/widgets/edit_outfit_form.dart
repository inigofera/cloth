import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';

import '../providers/outfit_providers.dart';
import '../providers/clothing_item_providers.dart';
import 'clothing_item_thumbnail.dart';
import 'image_picker_widget.dart';
import 'selected_clothing_item_badge.dart';

class EditOutfitForm extends ConsumerStatefulWidget {
  final Outfit outfit;

  const EditOutfitForm({super.key, required this.outfit});

  @override
  ConsumerState<EditOutfitForm> createState() => _EditOutfitFormState();
}

class _EditOutfitFormState extends ConsumerState<EditOutfitForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  
  late DateTime _selectedDate;
  late List<String> _selectedClothingItemIds;
  Uint8List? _imageData;
  String _searchQuery = '';
  final Set<String> _selectedCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.outfit.date;
    _selectedClothingItemIds = List<String>.from(widget.outfit.clothingItemIds);
    _notesController.text = widget.outfit.notes ?? '';
    _imageData = widget.outfit.imageData;
  }

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

  List<ClothingItem> _getSelectedClothingItems(List<ClothingItem> allItems) {
    return allItems.where((item) => _selectedClothingItemIds.contains(item.id)).toList();
  }

  void _removeSelectedItem(ClothingItem item) {
    setState(() {
      _selectedClothingItemIds.remove(item.id);
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
        final updatedOutfit = widget.outfit.copyWith(
          date: _selectedDate,
          clothingItemIds: _selectedClothingItemIds,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          imageData: _imageData,
          clearImageData: _imageData == null && widget.outfit.imageData != null,
          updatedAt: DateTime.now(),
        );

        await ref.read(outfitNotifierProvider.notifier).updateOutfit(updatedOutfit);
        
        // Trigger a refresh of the clothing items by invalidating the provider
        ref.invalidate(activeClothingItemsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Outfit updated successfully!')),
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
        title: const Text('Edit Outfit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Save Changes',
          ),
        ],
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

            // Selected items display
            clothingItemsAsync.when(
              data: (clothingItems) {
                final selectedItems = _getSelectedClothingItems(clothingItems);
                return SelectedClothingItemsDisplay(
                  selectedItems: selectedItems,
                  onRemoveItem: _removeSelectedItem,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
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
                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No clothing items match your search criteria',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filteredItems.map((item) {
                    final isSelected = _selectedClothingItemIds.contains(item.id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleClothingItem(item.id);
                        },
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}',
                          style: TextStyle(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade600,
                          ),
                        ),
                        secondary: ClothingItemThumbnail(
                          item: item,
                          size: 32,
                          backgroundColor: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          iconColor: isSelected 
                              ? Colors.white
                              : null,
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Colors.white,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading clothing items: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Image picker
            ImagePickerWidget(
              label: 'Outfit Photo (Optional)',
              initialImageData: _imageData,
              onImageChanged: (imageData) {
                setState(() {
                  _imageData = imageData;
                });
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any notes about this outfit...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Outfit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';

import '../providers/outfit_providers.dart';
import '../providers/clothing_item_providers.dart';
import 'clothing_item_thumbnail.dart';

class EditOutfitForm extends ConsumerStatefulWidget {
  final Outfit outfit;

  const EditOutfitForm({super.key, required this.outfit});

  @override
  ConsumerState<EditOutfitForm> createState() => _EditOutfitFormState();
}

class _EditOutfitFormState extends ConsumerState<EditOutfitForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  late DateTime _selectedDate;
  late List<String> _selectedClothingItemIds;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.outfit.date;
    _selectedClothingItemIds = List<String>.from(widget.outfit.clothingItemIds);
    _notesController.text = widget.outfit.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
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

            // Clothing items selection
            Text(
              'Clothing Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            clothingItemsAsync.when(
              data: (clothingItems) {
                if (clothingItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No clothing items available',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return Column(
                  children: clothingItems.map((item) {
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

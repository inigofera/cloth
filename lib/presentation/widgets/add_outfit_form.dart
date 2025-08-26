import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/outfit_providers.dart';
import '../providers/clothing_item_providers.dart';

class AddOutfitForm extends ConsumerStatefulWidget {
  const AddOutfitForm({super.key});

  @override
  ConsumerState<AddOutfitForm> createState() => _AddOutfitFormState();
}

class _AddOutfitFormState extends ConsumerState<AddOutfitForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedClothingItemIds = [];

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
        final outfit = Outfit.create(
          date: _selectedDate,
          clothingItemIds: _selectedClothingItemIds,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );

        await ref.read(outfitNotifierProvider.notifier).addOutfit(outfit);
        
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
        title: const Text('Log Outfit'),
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
            const Text(
              'Select Clothing Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            clothingItemsAsync.when(
              data: (clothingItems) => _buildClothingItemsList(clothingItems),
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
            leading: Icon(
              _getCategoryIcon(item.category),
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
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



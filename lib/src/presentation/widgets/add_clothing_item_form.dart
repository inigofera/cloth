import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/clothing_item_providers.dart';
import '../providers/settings_providers.dart';
import '../../core/utils/currency_formatter.dart';
import 'image_picker_widget.dart';

class AddClothingItemForm extends ConsumerStatefulWidget {
  const AddClothingItemForm({super.key});

  @override
  ConsumerState<AddClothingItemForm> createState() =>
      _AddClothingItemFormState();
}

class _AddClothingItemFormState extends ConsumerState<AddClothingItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _materialsController = TextEditingController();
  final _seasonController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _originController = TextEditingController();
  final _laundryImpactController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _ownedSince;
  bool? _repairable;
  Uint8List? _imageData;

  final List<String> _categories = [
    'Base Layer',
    'Outerwear',
    'Bottoms',
    'Accessories',
    'Footwear',
    'Formal Wear',
    'Sportswear',
    'Other',
  ];

  final List<String> _subcategories = [
    'T-Shirt',
    'Polo',
    'Shirt',
    'Sweater',
    'Hoodie',
    'Jacket',
    'Coat',
    'Jeans',
    'Pants',
    'Shorts',
    'Skirt',
    'Dress',
    'Belt',
    'Watch',
    'Jewelry',
    'Scarf',
    'Hat',
    'Gloves',
    'Sneakers',
    'Boots',
    'Shoes',
    'Sandals',
  ];

  final List<String> _seasons = [
    'Spring',
    'Summer',
    'Fall',
    'Winter',
    'All-Season',
  ];

  final List<String> _origins = [
    'Bought New',
    '2nd Hand',
    'Gift',
    'Handmade',
    'Other',
  ];

  final List<String> _laundryImpacts = ['Nothing', 'Low', 'Medium', 'High'];

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _materialsController.dispose();
    _seasonController.dispose();
    _purchasePriceController.dispose();
    _originController.dispose();
    _laundryImpactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _ownedSince = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final item = ClothingItem.create(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          subcategory: _subcategoryController.text.trim().isEmpty
              ? null
              : _subcategoryController.text.trim(),
          brand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          materials: _materialsController.text.trim().isEmpty
              ? null
              : _materialsController.text.trim(),
          season: _seasonController.text.trim().isEmpty
              ? null
              : _seasonController.text.trim(),
          purchasePrice: _purchasePriceController.text.trim().isEmpty
              ? null
              : double.tryParse(_purchasePriceController.text.trim()),
          ownedSince: _ownedSince,
          origin: _originController.text.trim().isEmpty
              ? null
              : _originController.text.trim(),
          laundryImpact: _laundryImpactController.text.trim().isEmpty
              ? null
              : _laundryImpactController.text.trim(),
          repairable: _repairable,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          imageData: _imageData,
        );

        await ref
            .read(clothingItemNotifierProvider.notifier)
            .addClothingItem(item);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clothing item added successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('cloth')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Required fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g., Blue T-Shirt',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Item name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category *',
                hintText: 'Select category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoryController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Image picker
            ImagePickerWidget(
              label: 'Item Photo (Optional)',
              onImageChanged: (imageData) {
                setState(() {
                  _imageData = imageData;
                });
              },
            ),
            const SizedBox(height: 16),

            // Optional fields
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Subcategory',
                hintText: 'Select subcategory',
              ),
              items: _subcategories.map((subcategory) {
                return DropdownMenuItem(
                  value: subcategory,
                  child: Text(subcategory),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _subcategoryController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                hintText: 'e.g., Nike, Levi\'s',
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: 'e.g., Blue, Red, Black',
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _materialsController,
              decoration: const InputDecoration(
                labelText: 'Materials',
                hintText: 'e.g., Cotton, Leather, Cotton/Polyester',
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Season',
                hintText: 'Select season',
              ),
              items: _seasons.map((season) {
                return DropdownMenuItem(value: season, child: Text(season));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _seasonController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final currency = ref.watch(currencyProvider);
                      final currencySymbol =
                          CurrencyFormatter.getCurrencySymbol(currency);
                      return TextFormField(
                        controller: _purchasePriceController,
                        decoration: InputDecoration(
                          labelText: 'Purchase Price',
                          hintText: '0.00',
                          prefixText: currencySymbol,
                        ),
                        keyboardType: TextInputType.number,
                      );
                    },
                  ),
                ),
                // const SizedBox(width: 16), // Removed
                // Expanded( // Removed
                //   child: TextFormField( // Removed
                //     controller: _initialPriceController, // Removed
                //     decoration: const InputDecoration( // Removed
                //       labelText: 'Initial Price', // Removed
                //       hintText: '0.00', // Removed
                //       prefixText: '\$', // Removed
                //     ), // Removed
                //     keyboardType: TextInputType.number, // Removed
                //   ), // Removed
                // ), // Removed
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Expanded( // Removed
                //   child: ListTile( // Removed
                //     title: const Text('Purchase Date'), // Removed
                //     subtitle: Text(_purchaseDate?.toString().split(' ')[0] ?? 'Not set'), // Removed
                //     trailing: IconButton( // Removed
                //       icon: const Icon(Icons.calendar_today), // Removed
                //       onPressed: () => _selectDate(context, true), // Removed
                //     ), // Removed
                //   ), // Removed
                // ), // Removed
                Expanded(
                  child: ListTile(
                    title: const Text('Owned Since'),
                    subtitle: Text(
                      _ownedSince?.toString().split(' ')[0] ?? 'Not set',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Origin',
                hintText: 'How did you get this item?',
              ),
              items: _origins.map((origin) {
                return DropdownMenuItem(value: origin, child: Text(origin));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _originController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Laundry Impact',
                hintText: 'Environmental impact of washing',
              ),
              items: _laundryImpacts.map((impact) {
                return DropdownMenuItem(value: impact, child: Text(impact));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _laundryImpactController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Repairable'),
              subtitle: Text(
                _repairable == null
                    ? 'Not specified'
                    : (_repairable! ? 'Yes' : 'No'),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: _repairable == true ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => setState(() => _repairable = true),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: _repairable == false ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => setState(() => _repairable = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional notes about this item',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Clothing Item'),
            ),
          ],
        ),
      ),
    );
  }
}

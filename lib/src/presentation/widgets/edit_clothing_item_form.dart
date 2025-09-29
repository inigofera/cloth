import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/clothing_item_providers.dart';
import '../providers/settings_providers.dart';
import '../../core/utils/currency_formatter.dart';
import 'image_picker_widget.dart';

class EditClothingItemForm extends ConsumerStatefulWidget {
  final ClothingItem clothingItem;

  const EditClothingItemForm({super.key, required this.clothingItem});

  @override
  ConsumerState<EditClothingItemForm> createState() =>
      _EditClothingItemFormState();
}

class _EditClothingItemFormState extends ConsumerState<EditClothingItemForm> {
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

  late DateTime? _ownedSince;
  late bool _repairable;
  Uint8List? _imageData;

  final List<String> _baseCategories = [
    'Base Layer',
    'Outerwear',
    'Bottoms',
    'Accessories',
    'Footwear',
    'Shoes',
    'Formal Wear',
    'Sportswear',
    'Other',
  ];

  /// Get the list of categories, including any imported categories
  List<String> get _categories {
    final importedCategory = widget.clothingItem.category;
    if (importedCategory.isNotEmpty) {
      final normalizedImported = importedCategory.toLowerCase();
      final normalizedBase = _baseCategories
          .map((cat) => cat.toLowerCase())
          .toList();

      if (!normalizedBase.contains(normalizedImported)) {
        // Add the imported category if it's not already in the list
        return [..._baseCategories, _capitalizeFirst(importedCategory)];
      }
    }
    return _baseCategories;
  }

  /// Capitalize the first letter of each word in a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  final List<String> _baseSubcategories = [
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

  /// Get the list of subcategories, including any imported subcategories
  List<String> get _subcategories {
    final importedSubcategory = widget.clothingItem.subcategory;
    if (importedSubcategory != null &&
        importedSubcategory.isNotEmpty &&
        !_baseSubcategories.contains(importedSubcategory)) {
      // Add the imported subcategory if it's not already in the list
      return [..._baseSubcategories, _capitalizeFirst(importedSubcategory)];
    }
    return _baseSubcategories;
  }

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
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    _nameController.text = widget.clothingItem.name;
    // Display capitalized version of category for better UX
    _categoryController.text = _capitalizeFirst(widget.clothingItem.category);
    _subcategoryController.text = widget.clothingItem.subcategory != null
        ? _capitalizeFirst(widget.clothingItem.subcategory!)
        : '';
    _brandController.text = widget.clothingItem.brand ?? '';
    _colorController.text = widget.clothingItem.color ?? '';
    _materialsController.text = widget.clothingItem.materials ?? '';
    _seasonController.text = widget.clothingItem.season ?? '';
    _purchasePriceController.text =
        widget.clothingItem.purchasePrice?.toString() ?? '';
    _originController.text = widget.clothingItem.origin ?? '';
    _laundryImpactController.text = widget.clothingItem.laundryImpact ?? '';
    _notesController.text = widget.clothingItem.notes ?? '';

    _ownedSince = widget.clothingItem.ownedSince;
    _repairable = widget.clothingItem.repairable ?? true;
    _imageData = widget.clothingItem.imageData;
  }

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

  /// Helper method to get a valid initial value for dropdowns
  /// Handles case sensitivity and ensures the value exists in the options list
  String? _getValidInitialValue(String? currentValue, List<String> options) {
    if (currentValue == null || currentValue.isEmpty) {
      return null;
    }

    // First try exact match
    if (options.contains(currentValue)) {
      return currentValue;
    }

    // Try case-insensitive match and return the properly capitalized version
    for (String option in options) {
      if (option.toLowerCase() == currentValue.toLowerCase()) {
        return option;
      }
    }

    // If no match found, return null to avoid dropdown error
    return null;
  }

  Future<void> _selectOwnedSinceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ownedSince ?? DateTime.now(),
      firstDate: DateTime(1900),
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
        final updatedItem = widget.clothingItem.copyWith(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim().toLowerCase(),
          subcategory: _subcategoryController.text.trim().isEmpty
              ? null
              : _capitalizeFirst(_subcategoryController.text.trim()),
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
          updatedAt: DateTime.now(),
        );

        await ref
            .read(clothingItemNotifierProvider.notifier)
            .updateClothingItem(updatedItem);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clothing item updated successfully!'),
            ),
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
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
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
              initialValue: _getValidInitialValue(
                _categoryController.text,
                _categories,
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
              initialImageData: _imageData,
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
                hintText: 'Select subcategory (optional)',
              ),
              initialValue: _getValidInitialValue(
                _subcategoryController.text,
                _subcategories,
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
                hintText: 'e.g., Nike, Adidas',
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
                hintText: 'e.g., Cotton, Polyester, Wool',
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Season',
                hintText: 'Select season (optional)',
              ),
              initialValue: _getValidInitialValue(
                _seasonController.text,
                _seasons,
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

            Consumer(
              builder: (context, ref, child) {
                final currency = ref.watch(currencyProvider);
                final currencySymbol = CurrencyFormatter.getCurrencySymbol(
                  currency,
                );
                return TextFormField(
                  controller: _purchasePriceController,
                  decoration: InputDecoration(
                    labelText: 'Purchase Price',
                    hintText: 'e.g., 29.99',
                    prefixText: currencySymbol,
                  ),
                  keyboardType: TextInputType.number,
                );
              },
            ),
            const SizedBox(height: 16),

            // Owned Since Date
            ListTile(
              title: const Text('Owned Since'),
              subtitle: Text(
                _ownedSince != null
                    ? '${_ownedSince!.day}/${_ownedSince!.month}/${_ownedSince!.year}'
                    : 'Not specified',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectOwnedSinceDate(context),
                  ),
                  if (_ownedSince != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _ownedSince = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Origin',
                hintText: 'Select origin (optional)',
              ),
              initialValue: _getValidInitialValue(
                _originController.text,
                _origins,
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
                hintText: 'Select laundry impact (optional)',
              ),
              initialValue: _getValidInitialValue(
                _laundryImpactController.text,
                _laundryImpacts,
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

            // Repairable checkbox
            CheckboxListTile(
              title: const Text('Repairable'),
              subtitle: const Text('Can this item be repaired?'),
              value: _repairable,
              onChanged: (bool? value) {
                setState(() {
                  _repairable = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add any additional notes about this item...',
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
                  'Update Item',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../utils/colors.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product; // null = add new, not null = edit existing
  final Function(Product) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _lowStockController;
  late TextEditingController _taxRateController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _codeController = TextEditingController(text: widget.product?.code ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _costPriceController = TextEditingController(
      text: widget.product?.costPrice?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity?.toString() ?? '',
    );
    _lowStockController = TextEditingController(
      text: widget.product?.lowStockAlert?.toString() ?? '',
    );
    _taxRateController = TextEditingController(
      text: widget.product?.taxRate?.toString() ?? '',
    );
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _taxRateController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        costPrice: _costPriceController.text.trim().isEmpty
            ? null
            : double.parse(_costPriceController.text.trim()),
        stockQuantity: _stockController.text.trim().isEmpty
            ? null
            : int.parse(_stockController.text.trim()),
        lowStockAlert: _lowStockController.text.trim().isEmpty
            ? null
            : int.parse(_lowStockController.text.trim()),
        taxRate: _taxRateController.text.trim().isEmpty
            ? null
            : double.parse(_taxRateController.text.trim()),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(product);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name (Required)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          hintText: 'Enter product name',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Product Code (Optional)
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Product Code / SKU',
                          hintText: 'Enter product code (optional)',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),

                      // Price (Required)
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price *',
                          hintText: 'Enter price',
                          prefixIcon: Icon(Icons.euro),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid price';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Price must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cost Price (Optional)
                      TextFormField(
                        controller: _costPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Cost Price',
                          hintText: 'Enter cost price (optional)',
                          prefixIcon: Icon(Icons.shopping_cart),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid cost price';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category (Optional)
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'Enter category (optional)',
                          prefixIcon: Icon(Icons.category),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Stock Quantity (Optional)
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          hintText: 'Enter stock quantity (optional)',
                          prefixIcon: Icon(Icons.storage),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Low Stock Alert (Optional)
                      TextFormField(
                        controller: _lowStockController,
                        decoration: const InputDecoration(
                          labelText: 'Low Stock Alert',
                          hintText: 'Alert when stock is below (optional)',
                          prefixIcon: Icon(Icons.warning),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tax Rate (Optional)
                      TextFormField(
                        controller: _taxRateController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Rate (%)',
                          hintText: 'Enter tax rate (optional)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final tax = double.tryParse(value);
                            if (tax == null) {
                              return 'Enter a valid tax rate';
                            }
                            if (tax < 0 || tax > 100) {
                              return 'Tax rate must be between 0 and 100';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter description (optional)',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 8),

                      // Required field note
                      const Text(
                        '* Required fields',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.surfaceGrey, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(widget.product == null ? 'Add Product' : 'Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

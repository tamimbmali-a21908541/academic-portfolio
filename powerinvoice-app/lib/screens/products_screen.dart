import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/product.dart';
import '../widgets/product_badge.dart';
import '../forms/product_form.dart';

/// Products Screen - Shows list of products/services
class ProductsScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAdd;
  final Function(Product) onUpdate;
  final Function(String) onDelete;

  const ProductsScreen({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return widget.products;
    }
    return widget.products.where((product) {
      final searchLower = _searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(searchLower) ||
          (product.code?.toLowerCase().contains(searchLower) ?? false) ||
          (product.category?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSave: (product) {
          widget.onAdd(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "${product.name}" added successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct) {
          widget.onUpdate(updatedProduct);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "${updatedProduct.name}" updated successfully'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product "${product.name}" deleted'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateStock(Product product) {
    final stockController = TextEditingController(
      text: product.stockQuantity?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              stockController.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                final updatedProduct = Product(
                  id: product.id,
                  name: product.name,
                  code: product.code,
                  price: product.price,
                  costPrice: product.costPrice,
                  stockQuantity: newStock,
                  lowStockAlert: product.lowStockAlert,
                  taxRate: product.taxRate,
                  category: product.category,
                  description: product.description,
                  createdAt: product.createdAt,
                  updatedAt: DateTime.now(),
                );

                widget.onUpdate(updatedProduct);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock updated to $newStock'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
              stockController.dispose();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Product list or empty state
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No products yet' : 'No products found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Add your first product or service to get started'
                  : 'Try a different search term',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final productNumber = (index + 1).toString().padLeft(2, '0');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _showProductDetails(product);
            },
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // Product badge with number
                  ProductBadge(number: productNumber),
                  const SizedBox(width: 16),

                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                            if (product.isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Low Stock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (product.code != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Code: ${product.code}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successGreen,
                              ),
                            ),
                            if (product.stockQuantity != null) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory,
                                      size: 14,
                                      color: AppColors.textGrey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${product.stockQuantity} in stock',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (product.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.category!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menu button
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: AppColors.textGrey,
                    onPressed: () {
                      _showProductMenu(product);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Price',
                value: '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
              ),
              if (product.code != null)
                _DetailRow(label: 'Code', value: product.code!),
              if (product.category != null)
                _DetailRow(label: 'Category', value: product.category!),
              if (product.costPrice != null)
                _DetailRow(
                  label: 'Cost Price',
                  value: '${AppConstants.currency}${product.costPrice!.toStringAsFixed(2)}',
                ),
              if (product.profitPerUnit != null)
                _DetailRow(
                  label: 'Profit per Unit',
                  value: '${AppConstants.currency}${product.profitPerUnit!.toStringAsFixed(2)}',
                ),
              if (product.stockQuantity != null)
                _DetailRow(label: 'Stock', value: '${product.stockQuantity}'),
              if (product.lowStockAlert != null)
                _DetailRow(label: 'Low Stock Alert', value: '${product.lowStockAlert}'),
              if (product.taxRate != null)
                _DetailRow(label: 'Tax Rate', value: '${product.taxRate}%'),
              if (product.description != null)
                _DetailRow(label: 'Description', value: product.description!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editProduct(product);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProductMenu(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryBlue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editProduct(product);
              },
            ),
            if (product.stockQuantity != null)
              ListTile(
                leading: const Icon(Icons.add_circle, color: AppColors.successGreen),
                title: const Text('Update Stock'),
                onTap: () {
                  Navigator.pop(context);
                  _updateStock(product);
                },
              ),
            ListTile(
              leading: const Icon(Icons.content_copy, color: AppColors.warningOrange),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                final duplicateProduct = Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '${product.name} (Copy)',
                  code: product.code,
                  price: product.price,
                  costPrice: product.costPrice,
                  stockQuantity: product.stockQuantity,
                  lowStockAlert: product.lowStockAlert,
                  taxRate: product.taxRate,
                  category: product.category,
                  description: product.description,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                widget.onAdd(duplicateProduct);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product duplicated: ${duplicateProduct.name}'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteProduct(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter options:'),
            SizedBox(height: 12),
            Text('• By category'),
            Text('• By price range'),
            Text('• Low stock only'),
            Text('• In stock / Out of stock'),
            SizedBox(height: 12),
            Text(
              'Advanced filtering coming soon!',
              style: TextStyle(
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}

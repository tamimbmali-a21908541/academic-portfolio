import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/invoice_counter.dart';

class InvoiceFormDialog extends StatefulWidget {
  final List<Client> clients;
  final List<Product> products;
  final Invoice? invoice; // null = create new, not null = edit
  final Function(Invoice) onSave;

  const InvoiceFormDialog({
    super.key,
    required this.clients,
    required this.products,
    this.invoice,
    required this.onSave,
  });

  @override
  State<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<InvoiceFormDialog> {
  Client? _selectedClient;
  final List<_InvoiceLineItem> _lineItems = [];
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  double _taxRate = 0.0;
  double _discountAmount = 0.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _loadExistingInvoice();
    }
  }

  void _loadExistingInvoice() {
    final invoice = widget.invoice!;
    _selectedClient = widget.clients.firstWhere(
      (c) => c.id == invoice.clientId,
      orElse: () => widget.clients.first,
    );
    _invoiceDate = invoice.invoiceDate;
    _dueDate = invoice.dueDate;
    _taxRate = invoice.taxAmount != null ? (invoice.taxAmount! / invoice.subtotal * 100) : 0.0;
    _discountAmount = invoice.discountAmount ?? 0.0;
    _notesController.text = invoice.notes ?? '';

    for (var item in invoice.items) {
      final product = widget.products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: item.productId,
          name: item.productName,
          price: item.price,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _lineItems.add(_InvoiceLineItem(
        product: product,
        quantity: item.quantity,
      ));
    }
  }

  double get _subtotal {
    return _lineItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get _taxAmount {
    return _taxRate > 0 ? (_subtotal * _taxRate / 100) : 0.0;
  }

  double get _total {
    return _subtotal + _taxAmount - _discountAmount;
  }

  void _addProduct() {
    if (widget.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add products first!'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ProductPickerDialog(
        products: widget.products,
        onProductSelected: (product, quantity) {
          setState(() {
            _lineItems.add(_InvoiceLineItem(
              product: product,
              quantity: quantity,
            ));
          });
        },
      ),
    );
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, double newQuantity) {
    setState(() {
      _lineItems[index] = _InvoiceLineItem(
        product: _lineItems[index].product,
        quantity: newQuantity,
      );
    });
  }

  Future<void> _save() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final now = DateTime.now();

    // Get auto-incrementing invoice number for new invoices
    final invoiceNumber = widget.invoice?.invoiceNumber ??
        await InvoiceCounter.getNextInvoiceNumber();

    final invoice = Invoice(
      id: widget.invoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: invoiceNumber,
      clientId: _selectedClient!.id,
      clientName: _selectedClient!.name,
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      items: _lineItems.map((item) => InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: item.product.id,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.product.price,
        taxRate: item.product.taxRate,
        total: item.product.price * item.quantity,
      )).toList(),
      subtotal: _subtotal,
      taxAmount: _taxAmount > 0 ? _taxAmount : null,
      discountAmount: _discountAmount > 0 ? _discountAmount : null,
      total: _total,
      amountPaid: widget.invoice?.amountPaid ?? 0.0,
      status: widget.invoice?.status ?? InvoiceStatus.unpaid,
      payments: widget.invoice?.payments ?? [],
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.invoice?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(invoice);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.infoPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.invoice == null ? 'Create Invoice' : 'Edit Invoice',
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

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Selection
                    const Text(
                      'Client *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<Client>(
                        value: _selectedClient,
                        isExpanded: true,
                        underline: const SizedBox(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        hint: const Text('Select client'),
                        items: widget.clients.map((client) {
                          return DropdownMenuItem(
                            value: client,
                            child: Text(client.name),
                          );
                        }).toList(),
                        onChanged: (client) {
                          setState(() {
                            _selectedClient = client;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Invoice Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invoice Date *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _invoiceDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _invoiceDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        _dueDate != null
                                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                            : 'Not set',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Products Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Products *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Product'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Product List
                    if (_lineItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.surfaceGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No products added yet\nClick "Add Product" to begin',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_lineItems.length, (index) {
                        final item = _lineItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${AppConstants.currency}${item.product.price.toStringAsFixed(2)} each',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: item.quantity.toString(),
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final qty = double.tryParse(value) ?? 1;
                                      _updateQuantity(index, qty);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '${AppConstants.currency}${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.successGreen,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: AppColors.errorRed,
                                  onPressed: () => _removeLineItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),

                    // Calculations
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Subtotal',
                            value: '${AppConstants.currency}${_subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Tax Rate (%)'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: _taxRate.toString(),
                                  ),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _taxRate = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${AppConstants.currency}${_taxAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Discount'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: _discountAmount.toString(),
                                  ),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _discountAmount = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '-${AppConstants.currency}${_discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _SummaryRow(
                            label: 'TOTAL',
                            value: '${AppConstants.currency}${_total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add any notes for this invoice',
                      ),
                      maxLines: 3,
                    ),
                  ],
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
                      backgroundColor: AppColors.infoPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(widget.invoice == null ? 'Create Invoice' : 'Save Changes'),
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

class _InvoiceLineItem {
  final Product product;
  final double quantity;

  _InvoiceLineItem({
    required this.product,
    required this.quantity,
  });
}

class _ProductPickerDialog extends StatefulWidget {
  final List<Product> products;
  final Function(Product, double) onProductSelected;

  const _ProductPickerDialog({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<_ProductPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final Map<Product, bool> _selectedProducts = {};
  final Map<Product, TextEditingController> _quantityControllers = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize all products as unselected
    for (var product in widget.products) {
      _selectedProducts[product] = false;
      _quantityControllers[product] = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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

  int get _selectedCount {
    return _selectedProducts.values.where((selected) => selected).length;
  }

  void _toggleSelectAll() {
    final allSelected = _selectedCount == _filteredProducts.length;
    setState(() {
      for (var product in _filteredProducts) {
        _selectedProducts[product] = !allSelected;
      }
    });
  }

  void _addSelectedProducts() {
    int addedCount = 0;
    for (var entry in _selectedProducts.entries) {
      if (entry.value) {
        final quantity = double.tryParse(_quantityControllers[entry.key]!.text) ?? 1;
        widget.onProductSelected(entry.key, quantity);
        addedCount++;
      }
    }
    Navigator.pop(context);

    if (addedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount product${addedCount > 1 ? 's' : ''} added'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Select all button and count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _toggleSelectAll,
                  icon: Icon(
                    _selectedCount == _filteredProducts.length
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  label: Text(
                    _selectedCount == _filteredProducts.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
                if (_selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_selectedCount selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),

            // Product list
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected = _selectedProducts[product] ?? false;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProducts[product] = value ?? false;
                                    });
                                  },
                                ),

                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${AppConstants.currency}${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppColors.successGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (product.code != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              'Code: ${product.code}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textGrey,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity input (only visible when selected)
                                if (isSelected)
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _quantityControllers[product],
                                      decoration: const InputDecoration(
                                        labelText: 'Qty',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectedCount > 0 ? _addSelectedProducts : null,
                  icon: const Icon(Icons.add),
                  label: Text('Add $_selectedCount Product${_selectedCount != 1 ? 's' : ''}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textWhite : AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.successGreen : AppColors.textWhite,
          ),
        ),
      ],
    );
  }
}

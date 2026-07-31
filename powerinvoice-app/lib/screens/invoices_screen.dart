import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../widgets/invoice_card.dart';
import '../forms/invoice_form.dart';
import '../forms/payment_form.dart';
import '../utils/pdf_generator.dart';
import '../services/google_drive_service.dart';

/// Invoices Screen - Shows list of invoices with filtering
class InvoicesScreen extends StatefulWidget {
  final List<Invoice> invoices;
  final List<Client> clients;
  final List<Product> products;
  final Function(Invoice) onAdd;
  final Function(Invoice) onUpdate;
  final Function(String) onDelete;

  const InvoicesScreen({
    super.key,
    required this.invoices,
    required this.clients,
    required this.products,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  InvoiceStatus? _filterStatus;

  List<Invoice> get _filteredInvoices {
    var filtered = widget.invoices;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((invoice) => invoice.status == _filterStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((invoice) {
        return invoice.invoiceNumber.toLowerCase().contains(searchLower) ||
            invoice.clientName.toLowerCase().contains(searchLower);
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onPressed: _showFilterDialog,
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
                hintText: 'Search invoices...',
                prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active filter chip
          if (_filterStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              child: Row(
                children: [
                  Chip(
                    label: Text(_getStatusLabel(_filterStatus!)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _filterStatus = null;
                      });
                    },
                    backgroundColor: _getStatusColor(_filterStatus!),
                  ),
                ],
              ),
            ),

          // Invoice list or empty state
          Expanded(
            child: _filteredInvoices.isEmpty
                ? _buildEmptyState()
                : _buildInvoiceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new invoice
          _showCreateInvoiceDialog();
        },
        tooltip: 'Create Invoice',
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
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty && _filterStatus == null
                  ? 'No invoices yet'
                  : 'No invoices found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty && _filterStatus == null
                  ? 'Create your first invoice to get started'
                  : 'Try a different search or filter',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            if (_searchQuery.isEmpty && _filterStatus == null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateInvoiceDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Invoice'),
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

  Widget _buildInvoiceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      itemCount: _filteredInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _filteredInvoices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InvoiceCard(
            invoice: invoice,
            onTap: () {
              _showInvoiceDetails(invoice);
            },
            onMenuTap: () {
              _showInvoiceMenu(invoice);
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(null, 'All Invoices'),
            const Divider(),
            _buildFilterOption(InvoiceStatus.unpaid, 'Unpaid'),
            _buildFilterOption(InvoiceStatus.partiallyPaid, 'Partially Paid'),
            _buildFilterOption(InvoiceStatus.paid, 'Paid'),
            _buildFilterOption(InvoiceStatus.overdue, 'Overdue'),
            _buildFilterOption(InvoiceStatus.draft, 'Draft'),
            _buildFilterOption(InvoiceStatus.cancelled, 'Cancelled'),
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

  Widget _buildFilterOption(InvoiceStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return ListTile(
      title: Text(label),
      leading: Radio<InvoiceStatus?>(
        value: status,
        groupValue: _filterStatus,
        onChanged: (value) {
          setState(() {
            _filterStatus = value;
          });
          Navigator.pop(context);
        },
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
        Navigator.pop(context);
      },
    );
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.unpaid:
        return 'Unpaid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.statusPaid;
      case InvoiceStatus.unpaid:
        return AppColors.statusUnpaid;
      case InvoiceStatus.partiallyPaid:
        return AppColors.statusPartiallyPaid;
      case InvoiceStatus.draft:
        return AppColors.statusDraft;
      case InvoiceStatus.overdue:
        return AppColors.errorRed;
      case InvoiceStatus.cancelled:
        return AppColors.textDisabled;
    }
  }

  void _showCreateInvoiceDialog() {
    if (widget.clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one client first'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    if (widget.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product first'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        clients: widget.clients,
        products: widget.products,
        onSave: (invoice) {
          widget.onAdd(invoice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice ${invoice.invoiceNumber} created successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(invoice.invoiceNumber),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Client', value: invoice.clientName),
              _DetailRow(
                label: 'Total',
                value: '${AppConstants.currency}${invoice.total.toStringAsFixed(2)}',
              ),
              _DetailRow(
                label: 'Amount Paid',
                value: '${AppConstants.currency}${invoice.amountPaid.toStringAsFixed(2)}',
              ),
              _DetailRow(
                label: 'Remaining',
                value: '${AppConstants.currency}${invoice.remaining.toStringAsFixed(2)}',
              ),
              _DetailRow(label: 'Status', value: _getStatusLabel(invoice.status)),
              if (invoice.payments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 8),
                ...invoice.payments.map((payment) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${AppConstants.currency}${payment.amount.toStringAsFixed(2)} - ${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                )),
              ],

              // Footer - Powered by B Department of Informatics
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Powered by the B Department of Informatics.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'thebinformatica@gmail.com',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!invoice.isPaid)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddPaymentDialog(invoice);
              },
              child: const Text('Add Payment'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => PaymentFormDialog(
        invoice: invoice,
        onSave: (updatedInvoice) {
          widget.onUpdate(updatedInvoice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment added to ${updatedInvoice.invoiceNumber}. Status: ${_getStatusLabel(updatedInvoice.status)}',
              ),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
  }

  Future<void> _generateAndViewPdf(Invoice invoice) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final pdfFile = await PdfGenerator.generateInvoicePdf(invoice);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Open PDF viewer
      await Printing.layoutPdf(
        onLayout: (format) async => await pdfFile.readAsBytes(),
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final pdfFile = await PdfGenerator.generateInvoicePdf(invoice);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Share the PDF file
      // Don't include client name in text - may contain non-ASCII characters
      await Share.shareXFiles(
        [XFile(pdfFile.path, mimeType: 'application/pdf')],
        text: 'Invoice ${invoice.invoiceNumber}',
        subject: 'Invoice ${invoice.invoiceNumber}',
      );
    } catch (e) {
      // Close loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing invoice: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _saveToGoogleDrive(Invoice invoice) async {
    try {
      // Check if user is signed in
      final isSignedIn = await GoogleDriveService.isSignedIn();

      if (!isSignedIn) {
        // Show sign-in prompt
        final signIn = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text('Sign in to Google Drive', style: TextStyle(color: AppColors.textWhite)),
            content: const Text(
              'You need to sign in with your Google account to save invoices to Google Drive.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sign In'),
              ),
            ],
          ),
        );

        if (signIn != true) return;

        // Attempt to sign in
        final account = await GoogleDriveService.signIn();
        if (account == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in to Google Drive'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      }

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final pdfFile = await PdfGenerator.generateInvoicePdf(invoice);

      // Upload to Google Drive
      final fileName = 'Invoice_${invoice.invoiceNumber}_${invoice.clientName}.pdf';
      final fileId = await GoogleDriveService.uploadPdfToDrive(pdfFile, fileName);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      if (fileId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved to Google Drive: $fileName'),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save invoice to Google Drive'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to Google Drive: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showInvoiceMenu(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: AppColors.primaryBlue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showInvoiceDetails(invoice);
              },
            ),
            if (!invoice.isPaid)
              ListTile(
                leading: const Icon(Icons.payment, color: AppColors.successGreen),
                title: const Text('Add Payment'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddPaymentDialog(invoice);
                },
              ),
            if (invoice.status != InvoiceStatus.paid)
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.warningOrange),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editInvoice(invoice);
                },
              ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.infoPurple),
              title: const Text('Generate PDF'),
              onTap: () {
                Navigator.pop(context);
                _generateAndViewPdf(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primaryBlue),
              title: const Text('Share Invoice'),
              onTap: () {
                Navigator.pop(context);
                _shareInvoice(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: AppColors.successGreen),
              title: const Text('Save to Google Drive'),
              onTap: () {
                Navigator.pop(context);
                _saveToGoogleDrive(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteInvoice(invoice);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        clients: widget.clients,
        products: widget.products,
        invoice: invoice,
        onSave: (updatedInvoice) {
          widget.onUpdate(updatedInvoice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice ${updatedInvoice.invoiceNumber} updated successfully'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  void _deleteInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(invoice.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice ${invoice.invoiceNumber} deleted'),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 2),
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

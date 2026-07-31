import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/invoice.dart';
import '../widgets/invoice_card.dart';
import '../utils/pdf_generator.dart';

/// Archive Screen - Shows all invoices with search functionality
class ArchiveScreen extends StatefulWidget {
  final List<Invoice> invoices;

  const ArchiveScreen({
    super.key,
    required this.invoices,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  InvoiceStatus? _filterStatus;

  List<Invoice> get _filteredInvoices {
    var filtered = widget.invoices;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((invoice) => invoice.status == _filterStatus).toList();
    }

    // Filter by search query (client name or invoice number)
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((invoice) {
        return invoice.clientName.toLowerCase().contains(searchLower) ||
            invoice.invoiceNumber.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
        title: const Text('Archive'),
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
                hintText: 'Search by client name or invoice number...',
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
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredInvoices.length} invoice${_filteredInvoices.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),

          // Summary stats
          if (_searchQuery.isEmpty && _filterStatus == null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: 8,
              ),
              child: _buildSummaryStats(),
            ),

          // Invoice list or empty state
          Expanded(
            child: _filteredInvoices.isEmpty
                ? _buildEmptyState()
                : _buildInvoiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final total = widget.invoices.length;
    final paid = widget.invoices.where((i) => i.status == InvoiceStatus.paid).length;
    final unpaid = widget.invoices.where((i) => i.status == InvoiceStatus.unpaid).length;
    final partial = widget.invoices.where((i) => i.status == InvoiceStatus.partiallyPaid).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Total',
              value: total.toString(),
              color: AppColors.primaryBlue,
            ),
            _StatItem(
              label: 'Paid',
              value: paid.toString(),
              color: AppColors.successGreen,
            ),
            _StatItem(
              label: 'Partial',
              value: partial.toString(),
              color: AppColors.warningOrange,
            ),
            _StatItem(
              label: 'Unpaid',
              value: unpaid.toString(),
              color: AppColors.errorRed,
            ),
          ],
        ),
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
              Icons.archive_outlined,
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
                  ? 'All your invoices will appear here'
                  : 'Try a different search or filter',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
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
            _buildFilterOption(InvoiceStatus.paid, 'Paid'),
            _buildFilterOption(InvoiceStatus.partiallyPaid, 'Partially Paid'),
            _buildFilterOption(InvoiceStatus.unpaid, 'Unpaid'),
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
              _DetailRow(
                label: 'Invoice Date',
                value: '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
              ),
              _DetailRow(
                label: 'Due Date',
                value: invoice.dueDate != null
                    ? '${invoice.dueDate!.day}/${invoice.dueDate!.month}/${invoice.dueDate!.year}'
                    : 'Not set',
              ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Invoice ${invoice.invoiceNumber} - ${invoice.clientName}',
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
          ],
        ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

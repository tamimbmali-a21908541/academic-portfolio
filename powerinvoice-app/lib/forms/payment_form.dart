import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class PaymentFormDialog extends StatefulWidget {
  final Invoice invoice;
  final Function(Invoice) onSave;

  const PaymentFormDialog({
    super.key,
    required this.invoice,
    required this.onSave,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final TextEditingController _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with remaining amount
    _amountController.text = widget.invoice.remaining.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (amount > widget.invoice.remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment amount cannot exceed remaining balance of ${AppConstants.currency}${widget.invoice.remaining.toStringAsFixed(2)}',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Create new payment
    final isPartial = amount < widget.invoice.remaining;
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceId: widget.invoice.id,
      amount: amount,
      paymentDate: _paymentDate,
      isPartial: isPartial,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    // Update invoice
    final newAmountPaid = widget.invoice.amountPaid + amount;
    final newPayments = [...widget.invoice.payments, payment];

    // Determine new status
    InvoiceStatus newStatus;
    if (newAmountPaid >= widget.invoice.total) {
      newStatus = InvoiceStatus.paid;
    } else if (newAmountPaid > 0) {
      newStatus = InvoiceStatus.partiallyPaid;
    } else {
      newStatus = InvoiceStatus.unpaid;
    }

    final updatedInvoice = widget.invoice.copyWith(
      amountPaid: newAmountPaid,
      payments: newPayments,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedInvoice);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.invoice.remaining;
    final isPartialPayment = double.tryParse(_amountController.text) != null &&
        double.parse(_amountController.text) < remaining;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.warningOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Payment',
                    style: TextStyle(
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

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Invoice',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              widget.invoice.invoiceNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _InfoRow(
                          label: 'Client',
                          value: widget.invoice.clientName,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Total',
                          value: '${AppConstants.currency}${widget.invoice.total.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Already Paid',
                          value: '${AppConstants.currency}${widget.invoice.amountPaid.toStringAsFixed(2)}',
                          valueColor: AppColors.successGreen,
                        ),
                        const Divider(height: 16),
                        _InfoRow(
                          label: 'Remaining',
                          value: '${AppConstants.currency}${remaining.toStringAsFixed(2)}',
                          valueColor: AppColors.errorRed, // RED as specified
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Amount
                  const Text(
                    'Payment Amount *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.euro),
                      hintText: 'Enter payment amount',
                      suffixIcon: TextButton(
                        onPressed: () {
                          _amountController.text = remaining.toStringAsFixed(2);
                          setState(() {});
                        },
                        child: const Text('Full'),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment Type Indicator
                  if (_amountController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPartialPayment
                            ? AppColors.warningOrange.withOpacity(0.2)
                            : AppColors.successGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPartialPayment ? Icons.credit_card : Icons.check_circle,
                            color: isPartialPayment
                                ? AppColors.warningOrange
                                : AppColors.successGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPartialPayment ? 'Partial Payment' : 'Full Payment',
                            style: TextStyle(
                              color: isPartialPayment
                                  ? AppColors.warningOrange
                                  : AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Payment Date
                  const Text(
                    'Payment Date *',
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
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _paymentDate = date;
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
                            '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add payment notes',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                ],
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
                    child: const Text('Add Payment'),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textWhite,
          ),
        ),
      ],
    );
  }
}

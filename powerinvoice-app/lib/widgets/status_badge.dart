import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/invoice.dart';

/// Status Badge Widget - Shows invoice payment status
/// Red (Unpaid), Orange (Partially Paid), Green (Paid)
class StatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  final bool showIcon;

  const StatusBadge({
    Key? key,
    required this.status,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String label;
    IconData? icon;

    switch (status) {
      case InvoiceStatus.paid:
        backgroundColor = AppColors.statusPaid;
        label = 'Paid';
        icon = Icons.check;
        break;
      case InvoiceStatus.unpaid:
        backgroundColor = AppColors.statusUnpaid;
        label = 'Unpaid';
        icon = Icons.close;
        break;
      case InvoiceStatus.partiallyPaid:
        backgroundColor = AppColors.statusPartiallyPaid;
        label = 'Partially Paid';
        icon = Icons.credit_card;
        break;
      case InvoiceStatus.draft:
        backgroundColor = AppColors.statusDraft;
        label = 'Draft';
        icon = Icons.edit;
        break;
      case InvoiceStatus.overdue:
        backgroundColor = AppColors.errorRed;
        label = 'Overdue';
        icon = Icons.warning;
        break;
      case InvoiceStatus.cancelled:
        backgroundColor = AppColors.textDisabled;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

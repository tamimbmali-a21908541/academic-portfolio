import 'payment.dart';

/// Invoice Status Enum
enum InvoiceStatus {
  draft,
  unpaid,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

/// Invoice Model
class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double? taxAmount;
  final double? discountAmount;
  final double total;
  final double amountPaid;
  final InvoiceStatus status;
  final List<Payment> payments;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.invoiceDate,
    this.dueDate,
    required this.items,
    required this.subtotal,
    this.taxAmount,
    this.discountAmount,
    required this.total,
    required this.amountPaid,
    required this.status,
    required this.payments,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate remaining amount
  double get remaining => total - amountPaid;

  /// Check if invoice is fully paid
  bool get isPaid => status == InvoiceStatus.paid || remaining <= 0;

  /// Check if invoice is partially paid
  bool get isPartiallyPaid => status == InvoiceStatus.partiallyPaid || (amountPaid > 0 && amountPaid < total);

  /// Check if invoice is unpaid
  bool get isUnpaid => status == InvoiceStatus.unpaid || amountPaid == 0;

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.unpaid:
        return 'Unpaid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'client_id': clientId,
      'client_name': clientName,
      'invoice_date': invoiceDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total': total,
      'amount_paid': amountPaid,
      'status': status.name,
      'payments': payments.map((p) => p.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'].toString(),
      invoiceNumber: json['invoice_number'] ?? '',
      clientId: json['client_id'].toString(),
      clientName: json['client_name'] ?? '',
      invoiceDate: DateTime.parse(json['invoice_date']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      items: (json['items'] as List?)?.map((item) => InvoiceItem.fromJson(item)).toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: json['tax_amount']?.toDouble(),
      discountAmount: json['discount_amount']?.toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.unpaid,
      ),
      payments: (json['payments'] as List?)?.map((p) => Payment.fromJson(p)).toList() ?? [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Create copy with updated fields
  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? total,
    double? amountPaid,
    InvoiceStatus? status,
    List<Payment>? payments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Invoice Line Item
class InvoiceItem {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double price;
  final double? taxRate;
  final double total;

  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.taxRate,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'tax_rate': taxRate,
      'total': total,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      taxRate: json['tax_rate']?.toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

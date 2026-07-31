/// Payment Model
class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final bool isPartial;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.isPartial,
    required this.createdAt,
  });

  /// Get payment type label
  String get typeLabel {
    return isPartial ? 'Partial Payment' : 'Full Payment';
  }

  /// Get bilingual label
  String get bilingualLabel {
    return isPartial ? 'Partial Payment - دفعة جزئية' : 'Full Payment - دفعة كاملة';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'notes': notes,
      'is_partial': isPartial,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      invoiceId: json['invoice_id'].toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      notes: json['notes'],
      isPartial: json['is_partial'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

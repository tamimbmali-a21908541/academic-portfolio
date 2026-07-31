/// Product/Service Model
class Product {
  final String id;
  final String name;
  final String? code;
  final double price;
  final double? costPrice;
  final int? stockQuantity;
  final int? lowStockAlert;
  final double? taxRate;
  final String? category;
  final String? unit;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.code,
    required this.price,
    this.costPrice,
    this.stockQuantity,
    this.lowStockAlert,
    this.taxRate,
    this.category,
    this.unit,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if product is low on stock
  bool get isLowStock {
    if (stockQuantity == null || lowStockAlert == null) return false;
    return stockQuantity! <= lowStockAlert!;
  }

  /// Check if product is out of stock
  bool get isOutOfStock {
    if (stockQuantity == null) return false;
    return stockQuantity! <= 0;
  }

  /// Calculate profit per unit
  double? get profitPerUnit {
    if (costPrice == null) return null;
    return price - costPrice!;
  }

  /// Calculate profit margin percentage
  double? get profitMargin {
    if (costPrice == null || costPrice == 0) return null;
    return ((price - costPrice!) / costPrice!) * 100;
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'price': price,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity,
      'low_stock_alert': lowStockAlert,
      'tax_rate': taxRate,
      'category': category,
      'unit': unit,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON response
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'],
      price: (json['price'] ?? 0).toDouble(),
      costPrice: json['cost_price'] != null ? json['cost_price'].toDouble() : null,
      stockQuantity: json['stock_quantity'],
      lowStockAlert: json['low_stock_alert'],
      taxRate: json['tax_rate'] != null ? json['tax_rate'].toDouble() : null,
      category: json['category'],
      unit: json['unit'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Create copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? code,
    double? price,
    double? costPrice,
    int? stockQuantity,
    int? lowStockAlert,
    double? taxRate,
    String? category,
    String? unit,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      taxRate: taxRate ?? this.taxRate,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

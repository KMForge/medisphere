import 'package:flutter/material.dart';

class PharmacyProduct {
  final String id;
  final String name;
  final String imageUrl;
  final String localImagePath;
  final double price;
  final int stock;
  final String stockStatus;
  final String description;
  final String category;

  PharmacyProduct({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.localImagePath = '',
    required this.price,
    required this.stock,
    required this.stockStatus,
    required this.description,
    required this.category,
  });

  Color get stockStatusColor {
    switch (stockStatus.toLowerCase()) {
      case 'in stock':
        return const Color(0xFF4CAF50);
      case 'limited stock':
        return const Color(0xFFFF9800);
      case 'out of stock':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get formattedPrice =>
      '₱${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  String get computedStockStatus {
    if (stock <= 0) return 'Out of Stock';
    if (stock <= 10) return 'Limited Stock';
    return 'In Stock';
  }

  PharmacyProduct copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? localImagePath,
    double? price,
    int? stock,
    String? stockStatus,
    String? description,
    String? category,
  }) {
    return PharmacyProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      stockStatus: stockStatus ?? this.stockStatus,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}

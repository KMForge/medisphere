import 'package:flutter/material.dart';
import '../models/pharmacy_product_model.dart';

// ─── Local cart item (used in UI before persisting) ─────────────────────────
class CartItem {
  final PharmacyProduct product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

// ─── DB cart item (from Supabase cart_items table) ──────────────────────────
class DbCartItem {
  final String cartItemId;
  final String cartId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const DbCartItem({
    this.cartItemId = '',
    this.cartId = '',
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  factory DbCartItem.fromJson(Map<String, dynamic> json) => DbCartItem(
    cartItemId: json['cart_item_id']?.toString() ?? '',
    cartId: json['cart_id']?.toString() ?? '',
    productId: json['product_id']?.toString() ?? '',
    productName: json['product_name'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toInsertJson(String cartId) => {
    'cart_id': cartId,
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'price': price,
  };
}

// ─── Order Statuses ─────────────────────────────────────────────────────────
class OrderStatus {
  static const String pending = 'Pending';
  static const String processing = 'Processing';
  static const String ready = 'Ready';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> all = [
    pending,
    processing,
    ready,
    completed,
    cancelled,
  ];

  static const List<String> lifecycle = [pending, processing, ready, completed];

  static String? nextStatus(String current) {
    final idx = lifecycle.indexOf(current);
    if (idx == -1 || idx >= lifecycle.length - 1) return null;
    return lifecycle[idx + 1];
  }

  static Color color(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFFF9800);
      case processing:
        return const Color(0xFF2196F3);
      case ready:
        return const Color(0xFF9C27B0);
      case completed:
        return const Color(0xFF4CAF50);
      case cancelled:
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case pending:
        return Icons.hourglass_top_rounded;
      case processing:
        return Icons.inventory_2_rounded;
      case ready:
        return Icons.check_circle_outline_rounded;
      case completed:
        return Icons.verified_rounded;
      case cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}

// ─── Order Item (from order_items table) ────────────────────────────────────
class OrderItem {
  final String itemId;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double? subtotal; // Generated column - optional

  const OrderItem({
    this.itemId = '',
    this.orderId = '',
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    itemId: json['item_id']?.toString() ?? '',
    orderId: json['order_id']?.toString() ?? '',
    productId: json['product_id']?.toString() ?? '',
    productName: json['product_name'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toInsertJson(String orderId) => {
    'order_id': orderId,
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'price': price,
    // subtotal is generated - don't insert
  };
}

// ─── Order (from orders table) ──────────────────────────────────────────────
class Order {
  final String orderId;
  final String userId;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final String orderType;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Joined from order_items
  final List<OrderItem> items;
  // Joined from profiles (for admin view)
  final String? userName;
  final String? userEmail;

  Order({
    this.orderId = '',
    required this.userId,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    this.orderType = 'pharmacy',
    this.notes = '',
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.userName,
    this.userEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['order_items'] is List) {
      items = (json['order_items'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    String? userName;
    String? userEmail;
    if (json['profiles'] is Map) {
      final p = json['profiles'] as Map<String, dynamic>;
      userName = p['full_name'] as String?;
      userEmail = p['email'] as String?;
    }

    return Order(
      orderId: json['order_id']?.toString() ?? '',
      userId: json['user_id'] as String? ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      status: json['status'] as String? ?? OrderStatus.pending,
      orderType: json['order_type'] as String? ?? 'pharmacy',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: items,
      userName: userName,
      userEmail: userEmail,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'total_price': totalPrice,
    'payment_method': paymentMethod,
    'status': status,
    'order_type': orderType,
    'notes': notes,
  };
}

// ─── Order Status History ───────────────────────────────────────────────────
class OrderStatusHistory {
  final String historyId;
  final String orderId;
  final String status;
  final String updatedBy;
  final DateTime? createdAt;

  const OrderStatusHistory({
    this.historyId = '',
    required this.orderId,
    required this.status,
    required this.updatedBy,
    this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      OrderStatusHistory(
        historyId: json['history_id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        status: json['status'] as String? ?? '',
        updatedBy: json['updated_by']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
}

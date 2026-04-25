import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Place an order: inserts into `orders`, then `order_items`, then logs status history.
  Future<Order> placeOrder(Order order, List<OrderItem> items) async {
    // 1. Insert into orders table
    final orderData = await _client
        .from('orders')
        .insert(order.toInsertJson())
        .select()
        .single();
    final orderId = orderData['order_id'] as String;
    debugPrint('[OrderService] Order created: $orderId');

    // 2. Insert order items
    if (items.isNotEmpty) {
      final itemRows = items.map((i) => i.toInsertJson(orderId)).toList();
      await _client.from('order_items').insert(itemRows);
      debugPrint('[OrderService] Inserted ${items.length} order items');
    }

    // 3. Log initial status in order_status_history
    await _client.from('order_status_history').insert({
      'order_id': orderId,
      'status': OrderStatus.pending,
      'updated_by': _userId,
    });

    // 4. Return the full order
    return Order.fromJson({
      ...orderData,
      'order_items': items.map((i) => i.toInsertJson(orderId)).toList(),
    });
  }

  /// Fetch current user's orders with items
  Future<List<Order>> fetchUserOrders() async {
    if (_userId == null) return [];
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  /// Fetch all orders (admin/staff) with items and user profile info
  Future<List<Order>> fetchAllOrders() async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*), profiles(full_name, email)')
        .order('created_at', ascending: false);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  /// Update order status and log to history
  Future<void> updateOrderStatus(String orderId, String status) async {
    debugPrint('[OrderService] Updating order $orderId to status: "$status"');
    await _client
        .from('orders')
        .update({'status': status})
        .eq('order_id', orderId);

    await _client.from('order_status_history').insert({
      'order_id': orderId,
      'status': status,
      'updated_by': _userId,
    });
    debugPrint('[OrderService] Order $orderId -> $status completed');
  }

  /// Fetch status history for an order
  Future<List<OrderStatusHistory>> fetchStatusHistory(String orderId) async {
    final data = await _client
        .from('order_status_history')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    return data.map((e) => OrderStatusHistory.fromJson(e)).toList();
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }
}

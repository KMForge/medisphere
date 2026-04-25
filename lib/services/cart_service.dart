import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class CartService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Convert a local product id (e.g. '1') to a deterministic UUID for the DB.
  /// Generates a valid v4 UUID deterministically from the product id.
  String _toUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(id)) return id;

    // Simple deterministic hash to generate hex bytes
    final seed = 'medisphere-product-$id'.hashCode;
    final rnd = Random(seed.abs());
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant

    // Convert to UUID string format
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Get or create the user's cart, returns cart_id
  Future<String> _ensureCart() async {
    if (_userId == null) throw Exception('Not logged in');

    // Check for existing cart — use limit(1) to avoid 406 when duplicates exist
    final rows = await _client
        .from('cart')
        .select('cart_id')
        .eq('user_id', _userId!)
        .limit(1);

    if (rows.isNotEmpty) return rows.first['cart_id'] as String;

    // Create new cart
    final newCart = await _client
        .from('cart')
        .insert({'user_id': _userId})
        .select('cart_id')
        .single();
    debugPrint('[CartService] Created new cart: ${newCart['cart_id']}');
    return newCart['cart_id'] as String;
  }

  /// Fetch all items in the user's cart
  Future<List<DbCartItem>> fetchCartItems() async {
    if (_userId == null) return [];
    final cartId = await _ensureCart();
    final data = await _client
        .from('cart_items')
        .select()
        .eq('cart_id', cartId)
        .order('created_at', ascending: true);
    return data.map((e) => DbCartItem.fromJson(e)).toList();
  }

  /// Add an item to the cart (or increment quantity if it already exists)
  Future<void> addItem({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
  }) async {
    final cartId = await _ensureCart();

    // Check if item already in cart — use limit(1) to avoid 406 if duplicates exist
    final existingRows = await _client
        .from('cart_items')
        .select()
        .eq('cart_id', cartId)
        .eq('product_id', _toUuid(productId))
        .limit(1);

    final existing = existingRows.isNotEmpty ? existingRows.first : null;

    if (existing != null) {
      final currentQty = (existing['quantity'] as num?)?.toInt() ?? 0;
      await _client
          .from('cart_items')
          .update({'quantity': currentQty + quantity})
          .eq('cart_item_id', existing['cart_item_id']);
      debugPrint(
        '[CartService] Updated qty for $productName -> ${currentQty + quantity}',
      );
    } else {
      await _client.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': _toUuid(productId),
        'product_name': productName,
        'quantity': quantity,
        'price': price,
      });
      debugPrint('[CartService] Added $productName to cart');
    }
  }

  /// Update quantity of a cart item
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('cart_item_id', cartItemId);
  }

  /// Remove an item from the cart
  Future<void> removeItem(String cartItemId) async {
    await _client.from('cart_items').delete().eq('cart_item_id', cartItemId);
    debugPrint('[CartService] Removed cart item $cartItemId');
  }

  /// Clear all items from the user's cart
  Future<void> clearCart() async {
    if (_userId == null) return;
    final cartId = await _ensureCart();
    await _client.from('cart_items').delete().eq('cart_id', cartId);
    debugPrint('[CartService] Cart cleared');
  }

  /// Get total number of items in cart
  Future<int> getCartCount() async {
    if (_userId == null) return 0;
    try {
      final items = await fetchCartItems();
      return items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (_) {
      return 0;
    }
  }
}

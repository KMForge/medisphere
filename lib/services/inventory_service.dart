import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/pharmacy_data.dart';
import '../models/pharmacy_product_model.dart';

class InventoryService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Add a new medicine to the inventory
  Future<void> addMedicine({
    required String name,
    required String category,
    required String description,
    required double price,
    required int initialStock,
    required String notes,
  }) async {
    try {
      final productId =
          'custom_${DateTime.now().millisecondsSinceEpoch}_${_userId?.substring(0, 8) ?? 'unknown'}';

      // Insert into product_stock table
      await _client.from('product_stock').insert({
        'product_id': productId,
        'product_name': name,
        'category': category,
        'description': description,
        'stock': initialStock,
        'price': price,
        'updated_by': _userId,
      });

      // Insert into stock history
      await _client.from('stock_history').insert({
        'product_id': productId,
        'action': 'set',
        'quantity_change': initialStock,
        'stock_before': 0,
        'stock_after': initialStock,
        'notes': notes,
        'created_by': _userId,
      });

      debugPrint(
        '[InventoryService] Added new medicine: $name (ID: $productId)',
      );
    } catch (e) {
      debugPrint('[InventoryService] Add medicine error: $e');
      rethrow;
    }
  }

  /// Fetch all medicines with real-time stock from Supabase.
  /// Includes custom medicines added via addMedicine, plus local defaults
  /// for any pre-seeded product not yet in DB.
  Future<List<PharmacyProduct>> fetchProductsWithStock() async {
    try {
      final dbRows = await _client
          .from('product_stock')
          .select()
          .order('product_name', ascending: true);

      // Build a map of local products keyed by ID for fast lookup
      final localMap = <String, PharmacyProduct>{
        for (final p in PharmacyData.allProducts) p.id: p,
      };

      // Track which local IDs are covered by DB rows
      final coveredIds = <String>{};
      final result = <PharmacyProduct>[];

      for (final row in dbRows) {
        final id = row['product_id'].toString();
        final stock = (row['stock'] as num?)?.toInt() ?? 0;
        final status = stock <= 0
            ? 'Out of Stock'
            : stock <= 10
            ? 'Limited Stock'
            : 'In Stock';

        final local = localMap[id];
        if (local != null) {
          // Known local product — update with live stock
          result.add(local.copyWith(stock: stock, stockStatus: status));
        } else {
          // Custom medicine added via Add Medicine form
          result.add(
            PharmacyProduct(
              id: id,
              name: row['product_name'] as String? ?? 'Unknown',
              imageUrl: row['image_url'] as String? ?? '',
              price: (row['price'] as num?)?.toDouble() ?? 0.0,
              stock: stock,
              stockStatus: status,
              category: row['category'] as String? ?? 'Others',
              description: row['description'] as String? ?? '',
            ),
          );
        }
        coveredIds.add(id);
      }

      // Append local products not yet seeded in DB (fallback)
      for (final p in PharmacyData.allProducts) {
        if (!coveredIds.contains(p.id)) {
          result.add(p);
        }
      }

      return result;
    } catch (e) {
      debugPrint('[InventoryService] Error fetching stock: $e');
      return PharmacyData.allProducts;
    }
  }

  /// Restock a medicine by adding quantity
  Future<void> restockProduct(
    String productId,
    int addQuantity, {
    String notes = '',
  }) async {
    try {
      final current = await _client
          .from('product_stock')
          .select('stock')
          .eq('product_id', productId)
          .single();

      final stockBefore = (current['stock'] as num?)?.toInt() ?? 0;
      final stockAfter = stockBefore + addQuantity;

      await _client
          .from('product_stock')
          .update({
            'stock': stockAfter,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': _userId,
          })
          .eq('product_id', productId);

      await _client.from('stock_history').insert({
        'product_id': productId,
        'action': 'restock',
        'quantity_change': addQuantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'notes': notes,
        'created_by': _userId,
      });

      debugPrint(
        '[InventoryService] Restocked $productId: $stockBefore -> $stockAfter',
      );
    } catch (e) {
      debugPrint('[InventoryService] Restock error: $e');
      rethrow;
    }
  }

  /// Set medicine stock to a specific value
  Future<void> setStock(
    String productId,
    int newStock, {
    String notes = '',
  }) async {
    try {
      final current = await _client
          .from('product_stock')
          .select('stock')
          .eq('product_id', productId)
          .single();

      final stockBefore = (current['stock'] as num?)?.toInt() ?? 0;

      await _client
          .from('product_stock')
          .update({
            'stock': newStock,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': _userId,
          })
          .eq('product_id', productId);

      await _client.from('stock_history').insert({
        'product_id': productId,
        'action': 'set',
        'quantity_change': newStock - stockBefore,
        'stock_before': stockBefore,
        'stock_after': newStock,
        'notes': notes,
        'created_by': _userId,
      });

      debugPrint(
        '[InventoryService] Set stock $productId: $stockBefore -> $newStock',
      );
    } catch (e) {
      debugPrint('[InventoryService] Set stock error: $e');
      rethrow;
    }
  }

  /// Deduct stock (e.g., after medicine is dispensed/used)
  Future<void> deductStock(String productId, int quantity) async {
    try {
      final current = await _client
          .from('product_stock')
          .select('stock')
          .eq('product_id', productId)
          .single();

      final stockBefore = (current['stock'] as num?)?.toInt() ?? 0;
      final stockAfter = (stockBefore - quantity).clamp(0, 999999);

      await _client
          .from('product_stock')
          .update({
            'stock': stockAfter,
            'updated_at': DateTime.now().toIso8601String(),
            'updated_by': _userId,
          })
          .eq('product_id', productId);

      await _client.from('stock_history').insert({
        'product_id': productId,
        'action': 'deduct',
        'quantity_change': -quantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'notes': 'Medicine dispensed',
        'created_by': _userId,
      });

      debugPrint(
        '[InventoryService] Deducted $productId: $stockBefore -> $stockAfter',
      );
    } catch (e) {
      debugPrint('[InventoryService] Deduct error: $e');
      rethrow;
    }
  }

  /// Fetch stock history for a product
  Future<List<Map<String, dynamic>>> fetchStockHistory(String productId) async {
    try {
      final data = await _client
          .from('stock_history')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[InventoryService] Fetch history error: $e');
      return [];
    }
  }

  /// Get low stock products (stock <= threshold)
  Future<List<PharmacyProduct>> getLowStockProducts({
    int threshold = 20,
  }) async {
    final products = await fetchProductsWithStock();
    return products.where((p) => p.stock <= threshold && p.stock > 0).toList();
  }

  /// Get out of stock products
  Future<List<PharmacyProduct>> getOutOfStockProducts() async {
    final products = await fetchProductsWithStock();
    return products.where((p) => p.stock <= 0).toList();
  }

  /// Get inventory summary stats
  Future<Map<String, dynamic>> getInventorySummary() async {
    final products = await fetchProductsWithStock();
    final totalProducts = products.length;
    final totalStock = products.fold<int>(0, (sum, p) => sum + p.stock);
    final outOfStock = products.where((p) => p.stock <= 0).length;
    final lowStock = products.where((p) => p.stock > 0 && p.stock <= 10).length;
    final inStock = products.where((p) => p.stock > 10).length;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );

    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'outOfStock': outOfStock,
      'lowStock': lowStock,
      'inStock': inStock,
      'totalValue': totalValue,
    };
  }
}

import '../data/pharmacy_data.dart';
import '../models/pharmacy_product_model.dart';
import 'inventory_service.dart';

class PharmacyService {
  final _inventoryService = InventoryService();

  Future<List<PharmacyProduct>> fetchProducts() async {
    try {
      return await _inventoryService.fetchProductsWithStock();
    } catch (_) {
      return PharmacyData.allProducts;
    }
  }

  Future<List<PharmacyProduct>> fetchProductsByCategory(String category) async {
    final all = await fetchProducts();
    if (category == 'All') return all;
    return all.where((p) => p.category == category).toList();
  }

  Future<List<PharmacyProduct>> searchProducts(String query) async {
    final all = await fetchProducts();
    final lowerQuery = query.toLowerCase();
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.category.toLowerCase().contains(lowerQuery) ||
              p.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}

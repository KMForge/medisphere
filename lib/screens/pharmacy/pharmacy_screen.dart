import 'package:flutter/material.dart';
import '../../data/pharmacy_data.dart';
import '../../models/order_model.dart';
import '../../models/pharmacy_product_model.dart';
import '../../services/cart_service.dart';
import '../../services/pharmacy_service.dart';
import '../../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class PharmacyScreen extends StatefulWidget {
  static const routeName = '/pharmacy';

  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final CartService _cartService = CartService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PharmacyProduct> _products = [];
  List<PharmacyProduct> _filteredProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String _searchQuery = '';

  // Cart badge count from DB
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _refreshCartCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _pharmacyService.fetchProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load products');
    }
  }

  void _filterProducts() {
    List<PharmacyProduct> result = _products;

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(lowerQuery) ||
                p.category.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    setState(() => _filteredProducts = result);
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _filterProducts();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterProducts();
  }

  Future<void> _refreshCartCount() async {
    final count = await _cartService.getCartCount();
    if (mounted) setState(() => _cartItemCount = count);
  }

  void _addToCart(PharmacyProduct product) async {
    if (product.stock <= 0) {
      _showErrorSnackBar('${product.name} is out of stock');
      return;
    }
    try {
      await _cartService.addItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
      );
      await _refreshCartCount();
      if (mounted) _showSuccessSnackBar('${product.name} added to cart');
    } catch (e) {
      debugPrint('[PharmacyScreen] Add to cart error: $e');
      if (mounted) _showErrorSnackBar('Failed to add to cart: $e');
    }
  }

  void _navigateToCart() async {
    try {
      final dbItems = await _cartService.fetchCartItems();
      // Convert DbCartItem to CartItem using local product data for images
      final cartItems = dbItems.map((dbItem) {
        final product = _products.firstWhere(
          (p) => p.id == dbItem.productId,
          orElse: () => PharmacyProduct(
            id: dbItem.productId,
            name: dbItem.productName,
            price: dbItem.price,
            imageUrl: '',
            localImagePath: '',
            stock: 99,
            stockStatus: 'In Stock',
            description: '',
            category: '',
          ),
        );
        return CartItem(product: product, quantity: dbItem.quantity);
      }).toList();

      if (!mounted) return;
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(cartItems: cartItems),
        ),
      );
      if (result == true && mounted) {
        await _refreshCartCount();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed! Cart cleared.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        // Refresh count in case items were removed in cart screen
        await _refreshCartCount();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to load cart');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToProductDetail(PharmacyProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          onAddToCart: () => _addToCart(product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0D1B2A)
        : theme.scaffoldBackgroundColor;
    final cardBgColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, cardBgColor, textColor),
            _buildSearchBar(cardBgColor, textColor, hintColor),
            _buildCategoryFilter(isDark, cardBgColor, textColor),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _filteredProducts.isEmpty
                  ? _buildEmptyState(textColor)
                  : _buildProductsGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color cardBgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pharmacy',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: _navigateToCart,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: cardBgColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$_cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color cardBgColor, Color textColor, Color hintColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: textColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search drugs, category...',
          hintStyle: TextStyle(color: hintColor, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: hintColor, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: Icon(Icons.close, color: hintColor, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark, Color cardBgColor, Color textColor) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: PharmacyData.categories.length,
        itemBuilder: (context, index) {
          final category = PharmacyData.categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () => _onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : textColor.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFF4CAF50),
      backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () => _navigateToProductDetail(product),
            onAddToCart: () => _addToCart(product),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 56,
            color: textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/pharmacy_product_model.dart';
import '../../services/inventory_service.dart';
import 'add_medicine_screen.dart';

class InventoryManagementScreen extends StatefulWidget {
  static const String routeName = '/inventory-management';
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final _inventoryService = InventoryService();
  List<PharmacyProduct> _products = [];
  List<PharmacyProduct> _filteredProducts = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  String _filter = 'All'; // All, In Stock, Low Stock, Out of Stock
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await _inventoryService.fetchProductsWithStock();
      final summary = await _inventoryService.getInventorySummary();
      if (mounted) {
        setState(() {
          _products = products;
          _summary = summary;
          _loading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading inventory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilter() {
    List<PharmacyProduct> result = _products;

    if (_filter == 'In Stock') {
      result = result.where((p) => p.stock > 10).toList();
    } else if (_filter == 'Low Stock') {
      result = result.where((p) => p.stock > 0 && p.stock <= 10).toList();
    } else if (_filter == 'Out of Stock') {
      result = result.where((p) => p.stock <= 0).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }

    setState(() => _filteredProducts = result);
  }

  void _showRestockDialog(PharmacyProduct product) {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Stock: ${product.stock}',
              style: TextStyle(
                color: product.stockStatusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to Add',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_box_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text.trim());
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await _inventoryService.restockProduct(
                  product.id,
                  qty,
                  notes: notesController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $qty units to ${product.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _load();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restock failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Restock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSetStockDialog(PharmacyProduct product) {
    final qtyController = TextEditingController(text: product.stock.toString());
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Stock: ${product.stock}',
              style: TextStyle(
                color: product.stockStatusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text.trim());
              if (qty == null || qty < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await _inventoryService.setStock(
                  product.id,
                  qty,
                  notes: notesController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} stock set to $qty'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  _load();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showStockHistory(PharmacyProduct product) async {
    final history = await _inventoryService.fetchStockHistory(product.id);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${product.name} — Stock History',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No history yet'))
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        final h = history[i];
                        final action = h['action'] as String? ?? '';
                        final change =
                            (h['quantity_change'] as num?)?.toInt() ?? 0;
                        final before =
                            (h['stock_before'] as num?)?.toInt() ?? 0;
                        final after = (h['stock_after'] as num?)?.toInt() ?? 0;
                        final notes = h['notes'] as String? ?? '';
                        final createdAt = h['created_at'] != null
                            ? DateTime.tryParse(h['created_at'].toString())
                            : null;

                        Color actionColor;
                        IconData actionIcon;
                        switch (action) {
                          case 'restock':
                            actionColor = Colors.green;
                            actionIcon = Icons.add_circle;
                            break;
                          case 'deduct':
                            actionColor = Colors.red;
                            actionIcon = Icons.remove_circle;
                            break;
                          default:
                            actionColor = Colors.blue;
                            actionIcon = Icons.edit;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(actionIcon, color: actionColor),
                            title: Text(
                              '${action.toUpperCase()} ${change > 0 ? '+$change' : '$change'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: actionColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$before → $after units'),
                                if (notes.isNotEmpty)
                                  Text(
                                    notes,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: createdAt != null
                                ? Text(
                                    '${createdAt.month}/${createdAt.day}\n${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Medicine',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AddMedicineScreen.routeName,
              );
              if (result == true) {
                _load(); // Refresh the inventory list
              }
            },
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(isDark),
                    const SizedBox(height: 20),

                    // Search Bar
                    _buildSearchBar(isDark),
                    const SizedBox(height: 12),

                    // Filter Chips
                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    // Product List
                    Text(
                      'Medicines (${_filteredProducts.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredProducts.map(
                      (p) => _buildProductTile(p, isDark),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _SummaryCard(
          title: 'Total Medicines',
          value: '${_summary['totalProducts'] ?? 0}',
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF2196F3),
          isDark: isDark,
        ),
        _SummaryCard(
          title: 'Total Stock',
          value: '${_summary['totalStock'] ?? 0}',
          icon: Icons.warehouse_rounded,
          color: const Color(0xFF4CAF50),
          isDark: isDark,
        ),
        _SummaryCard(
          title: 'Low Stock',
          value: '${_summary['lowStock'] ?? 0}',
          icon: Icons.warning_rounded,
          color: const Color(0xFFFF9800),
          isDark: isDark,
        ),
        _SummaryCard(
          title: 'Out of Stock',
          value: '${_summary['outOfStock'] ?? 0}',
          icon: Icons.block_rounded,
          color: const Color(0xFFE53935),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: (v) {
        _searchQuery = v;
        _applyFilter();
      },
      decoration: InputDecoration(
        hintText: 'Search medicines...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilter();
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1F2E) : Colors.grey[100],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    return Wrap(
      spacing: 8,
      children: filters.map((f) {
        final isSelected = _filter == f;
        Color chipColor;
        switch (f) {
          case 'In Stock':
            chipColor = const Color(0xFF4CAF50);
            break;
          case 'Low Stock':
            chipColor = const Color(0xFFFF9800);
            break;
          case 'Out of Stock':
            chipColor = const Color(0xFFE53935);
            break;
          default:
            chipColor = const Color(0xFF2196F3);
        }
        return FilterChip(
          label: Text(f),
          selected: isSelected,
          selectedColor: chipColor.withValues(alpha: 0.2),
          checkmarkColor: chipColor,
          labelStyle: TextStyle(
            color: isSelected ? chipColor : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          onSelected: (_) {
            setState(() => _filter = f);
            _applyFilter();
          },
        );
      }).toList(),
    );
  }

  Widget _buildProductTile(PharmacyProduct product, bool isDark) {
    final stockColor = product.stock <= 0
        ? const Color(0xFFE53935)
        : product.stock <= 10
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252B3D) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.localImagePath.isNotEmpty
                    ? Image.asset(
                        product.localImagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.medication, color: Colors.grey),
                      )
                    : const Icon(Icons.medication, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.stock} in stock',
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                // Restock button
                _ActionIconButton(
                  icon: Icons.add_circle_rounded,
                  color: const Color(0xFF4CAF50),
                  tooltip: 'Restock',
                  onTap: () => _showRestockDialog(product),
                ),
                const SizedBox(height: 4),
                // Set stock button
                _ActionIconButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF2196F3),
                  tooltip: 'Set Stock',
                  onTap: () => _showSetStockDialog(product),
                ),
                const SizedBox(height: 4),
                // History button
                _ActionIconButton(
                  icon: Icons.history_rounded,
                  color: const Color(0xFF9C27B0),
                  tooltip: 'History',
                  onTap: () => _showStockHistory(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

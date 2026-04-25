import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class SalesReportScreen extends StatefulWidget {
  static const String routeName = '/sales-report';
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final _orderService = OrderService();
  List<Order> _allOrders = [];
  bool _loading = true;
  String _periodFilter = 'All Time';

  // Computed stats
  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _completedOrders = 0;
  int _pendingOrders = 0;
  int _cancelledOrders = 0;
  int _totalItemsSold = 0;
  double _avgOrderValue = 0;
  List<_TopProduct> _topProducts = [];
  List<_DailySales> _dailySales = [];
  Map<String, double> _categoryRevenue = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final orders = await _orderService.fetchAllOrders();
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _loading = false;
        });
        _computeStats();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sales: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _computeStats() {
    List<Order> filtered = _allOrders;

    // Apply period filter
    final now = DateTime.now();
    if (_periodFilter == 'Today') {
      filtered = filtered.where((o) =>
        o.createdAt != null &&
        o.createdAt!.year == now.year &&
        o.createdAt!.month == now.month &&
        o.createdAt!.day == now.day
      ).toList();
    } else if (_periodFilter == 'This Week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      filtered = filtered.where((o) =>
        o.createdAt != null && o.createdAt!.isAfter(weekStart)
      ).toList();
    } else if (_periodFilter == 'This Month') {
      filtered = filtered.where((o) =>
        o.createdAt != null &&
        o.createdAt!.year == now.year &&
        o.createdAt!.month == now.month
      ).toList();
    }

    // Basic stats
    _totalOrders = filtered.length;
    _completedOrders = filtered.where((o) => o.status == OrderStatus.completed).length;
    _pendingOrders = filtered.where((o) =>
      o.status == OrderStatus.pending || o.status == OrderStatus.processing
    ).length;
    _cancelledOrders = filtered.where((o) => o.status == OrderStatus.cancelled).length;

    // Revenue (only from completed orders)
    final completedList = filtered.where((o) => o.status == OrderStatus.completed);
    _totalRevenue = completedList.fold<double>(0, (sum, o) => sum + o.totalPrice);
    _avgOrderValue = _completedOrders > 0 ? _totalRevenue / _completedOrders : 0;

    // Items sold
    _totalItemsSold = 0;
    for (final order in completedList) {
      for (final item in order.items) {
        _totalItemsSold += item.quantity;
      }
    }

    // Top products
    final productSales = <String, _TopProduct>{};
    for (final order in completedList) {
      for (final item in order.items) {
        final existing = productSales[item.productName];
        if (existing != null) {
          productSales[item.productName] = _TopProduct(
            name: item.productName,
            quantitySold: existing.quantitySold + item.quantity,
            revenue: existing.revenue + (item.price * item.quantity),
          );
        } else {
          productSales[item.productName] = _TopProduct(
            name: item.productName,
            quantitySold: item.quantity,
            revenue: item.price * item.quantity,
          );
        }
      }
    }
    _topProducts = productSales.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    if (_topProducts.length > 10) _topProducts = _topProducts.sublist(0, 10);

    // Category revenue
    _categoryRevenue = {};
    for (final tp in productSales.values) {
      // We'll group by product name prefix as a simple heuristic
      _categoryRevenue[tp.name] = (_categoryRevenue[tp.name] ?? 0) + tp.revenue;
    }

    // Daily sales (last 7 days)
    _dailySales = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayOrders = completedList.where((o) =>
        o.createdAt != null &&
        o.createdAt!.year == day.year &&
        o.createdAt!.month == day.month &&
        o.createdAt!.day == day.day
      );
      final dayRevenue = dayOrders.fold<double>(0, (sum, o) => sum + o.totalPrice);
      final dayCount = dayOrders.length;
      _dailySales.add(_DailySales(
        date: day,
        revenue: dayRevenue,
        orderCount: dayCount,
      ));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
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
                    // Period filter
                    _buildPeriodFilter(),
                    const SizedBox(height: 16),

                    // Revenue card
                    _buildRevenueCard(isDark),
                    const SizedBox(height: 16),

                    // Stats grid
                    _buildStatsGrid(isDark),
                    const SizedBox(height: 20),

                    // Daily Sales Chart (simple bar)
                    _buildDailySalesSection(isDark),
                    const SizedBox(height: 20),

                    // Top Products
                    _buildTopProductsSection(isDark),
                    const SizedBox(height: 20),

                    // Recent Orders
                    _buildRecentOrdersSection(isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Today', 'This Week', 'This Month', 'All Time'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final isSelected = _periodFilter == p;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p),
              selected: isSelected,
              selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) {
                setState(() => _periodFilter = p);
                _computeStats();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Total Revenue',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₱${_totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _RevenueChip(
                label: '$_completedOrders completed',
                icon: Icons.check_circle,
              ),
              const SizedBox(width: 12),
              _RevenueChip(
                label: '$_totalItemsSold items sold',
                icon: Icons.shopping_bag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          title: 'Total Orders',
          value: '$_totalOrders',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF2196F3),
          isDark: isDark,
        ),
        _StatCard(
          title: 'Avg. Order Value',
          value: '₱${_avgOrderValue.toStringAsFixed(2)}',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF9C27B0),
          isDark: isDark,
        ),
        _StatCard(
          title: 'Pending Orders',
          value: '$_pendingOrders',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFFF9800),
          isDark: isDark,
        ),
        _StatCard(
          title: 'Cancelled',
          value: '$_cancelledOrders',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFE53935),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDailySalesSection(bool isDark) {
    final maxRevenue = _dailySales.fold<double>(
      0,
      (max, d) => d.revenue > max ? d.revenue : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Sales (Last 7 Days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _dailySales.map((d) {
              final barHeight = maxRevenue > 0
                  ? (d.revenue / maxRevenue) * 120
                  : 0.0;
              final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  [d.date.weekday - 1];
              final isToday = d.date.day == DateTime.now().day &&
                  d.date.month == DateTime.now().month;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (d.revenue > 0)
                      Text(
                        '₱${d.revenue.toInt()}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      height: barHeight.clamp(4, 120),
                      width: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                              : [const Color(0xFF64B5F6), const Color(0xFF2196F3)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                        color: isToday
                            ? const Color(0xFF4CAF50)
                            : (isDark ? Colors.white60 : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        if (_topProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('No sales data yet', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ..._topProducts.asMap().entries.map((entry) {
            final i = entry.key;
            final tp = entry.value;
            final maxRev = _topProducts.first.revenue;
            final barWidth = maxRev > 0 ? (tp.revenue / maxRev) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: i < 3
                              ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '#${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: i < 3
                                  ? const Color(0xFFFF8F00)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tp.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₱${tp.revenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${tp.quantitySold} sold',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barWidth,
                      backgroundColor:
                          isDark ? Colors.white12 : Colors.grey[200],
                      color: const Color(0xFF4CAF50),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRecentOrdersSection(bool isDark) {
    final recent = _allOrders.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('No orders yet', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...recent.map((order) {
            final statusColor = OrderStatus.color(order.status);
            final date = order.createdAt;
            final dateStr = date != null
                ? '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                : 'Unknown';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    OrderStatus.icon(order.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  order.userName ?? order.userEmail ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${order.items.length} item(s) · $dateStr',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ─── Helper Classes ──────────────────────────────────────────────────────────

class _TopProduct {
  final String name;
  final int quantitySold;
  final double revenue;

  _TopProduct({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });
}

class _DailySales {
  final DateTime date;
  final double revenue;
  final int orderCount;

  _DailySales({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });
}

class _RevenueChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _RevenueChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

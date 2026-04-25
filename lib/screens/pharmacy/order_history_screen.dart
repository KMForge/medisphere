import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

String _shortId(String id) =>
    id.length >= 8 ? id.substring(0, 8).toUpperCase() : id;
String _fmtDate(DateTime? dt) =>
    dt != null ? '${dt.month}/${dt.day}/${dt.year}' : '';

class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order-history';
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.fetchUserOrders();
      if (mounted)
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
    }
  }

  Future<void> _markOrderAsReceived(String orderId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order Received'),
        content: const Text(
          'Are you sure you have received this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Received'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.updateOrderStatus(orderId, OrderStatus.completed);
      await _loadOrders(); // Refresh orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as received!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the modal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Order> get _filtered => _filter == 'All'
      ? _orders
      : _orders.where((o) => o.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: ['All', ...OrderStatus.lifecycle, OrderStatus.cancelled]
                  .map((s) {
                    final sel = _filter == s;
                    final c = s == 'All'
                        ? AppColors.primary
                        : OrderStatus.color(s);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s),
                        selected: sel,
                        selectedColor: c.withValues(alpha: 0.2),
                        checkmarkColor: c,
                        labelStyle: TextStyle(
                          color: sel ? c : null,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _filter = s),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: isDark ? Colors.white30 : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _OrderCard(
                        order: _filtered[i],
                        onTap: () => _showOrderDetail(_filtered[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(Order order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black87;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    OrderStatus.icon(order.status),
                    color: OrderStatus.color(order.status),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${_shortId(order.orderId)}',
                          style: TextStyle(
                            color: textCol,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: OrderStatus.color(
                              order.status,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: OrderStatus.color(order.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTimeline(order, textCol, isDark),
              const SizedBox(height: 24),
              Text(
                'Items',
                style: TextStyle(
                  color: textCol,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'x${item.quantity} · ₱${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: textCol.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${(item.subtotal ?? (item.price * item.quantity)).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: textCol,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              _summaryRow('Payment', order.paymentMethod, textCol),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: textCol,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '₱${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.createdAt != null)
                Text(
                  'Ordered: ${_fmtDate(order.createdAt)} ${TimeOfDay.fromDateTime(order.createdAt!).format(context)}',
                  style: TextStyle(
                    color: textCol.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),

              // Order Received Button
              if (order.status == OrderStatus.ready)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markOrderAsReceived(order.orderId),
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('Order Received'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color textCol) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(color: textCol.withValues(alpha: 0.6), fontSize: 14),
      ),
      Text(
        value,
        style: TextStyle(
          color: textCol,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildTimeline(Order order, Color textCol, bool isDark) {
    final currentIdx = OrderStatus.lifecycle.indexOf(order.status);
    final isCancelled = order.status == OrderStatus.cancelled;
    return Column(
      children: List.generate(OrderStatus.lifecycle.length, (i) {
        final status = OrderStatus.lifecycle[i];
        final isReached = !isCancelled && currentIdx >= i;
        final isCurrent = !isCancelled && currentIdx == i;
        final color = isReached
            ? OrderStatus.color(status)
            : (isDark ? Colors.white24 : Colors.grey.shade300);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isReached
                        ? color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isReached
                      ? Icon(
                          isCurrent
                              ? OrderStatus.icon(status)
                              : Icons.check_rounded,
                          size: 14,
                          color: color,
                        )
                      : null,
                ),
                if (i < OrderStatus.lifecycle.length - 1)
                  Container(width: 2, height: 28, color: color),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                status,
                style: TextStyle(
                  color: isReached ? textCol : textCol.withValues(alpha: 0.4),
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  fontSize: isCurrent ? 14 : 13,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black87;
    final statusColor = OrderStatus.color(order.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  OrderStatus.icon(order.status),
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${_shortId(order.orderId)}',
                    style: TextStyle(
                      color: textCol,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              order.items
                  .map((i) => '${i.productName} x${i.quantity}')
                  .join(', '),
              style: TextStyle(
                color: textCol.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmtDate(order.createdAt),
                  style: TextStyle(
                    color: textCol.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '₱${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

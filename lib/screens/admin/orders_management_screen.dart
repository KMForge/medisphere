import 'package:flutter/material.dart';
import '../../models/pharmacy_product_model.dart';

class OrdersManagementScreen extends StatefulWidget {
  static const routeName = '/admin_orders';

  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'customerName': 'John Doe',
      'customerEmail': 'john@example.com',
      'items': [
        {
          'product': PharmacyProduct(
            id: '1',
            name: 'Paracetamol (Biogesic)',
            localImagePath: 'lib/Images/Biogesic.png',
            price: 7.50,
            stock: 100,
            stockStatus: 'In Stock',
            description: 'Pain reliever and fever reducer.',
            category: 'Pain Relief',
          ),
          'quantity': 2,
        },
      ],
      'totalPrice': 15.00,
      'status': 'Pending',
      'paymentMethod': 'GCash',
      'createdAt': '2024-03-20 10:30 AM',
      'address': '123 Main St, Manila',
    },
    {
      'id': 'ORD002',
      'customerName': 'Jane Smith',
      'customerEmail': 'jane@example.com',
      'items': [
        {
          'product': PharmacyProduct(
            id: '2',
            name: 'Ibuprofen (Advil)',
            localImagePath: 'lib/Images/Advil.png',
            price: 12.00,
            stock: 80,
            stockStatus: 'In Stock',
            description: 'Anti-inflammatory pain reliever.',
            category: 'Pain Relief',
          ),
          'quantity': 1,
        },
        {
          'product': PharmacyProduct(
            id: '5',
            name: 'Vitamin C (Cecon)',
            localImagePath: 'lib/Images/Vitamin C (Cecon).png',
            price: 8.25,
            stock: 200,
            stockStatus: 'In Stock',
            description: 'Immune system support.',
            category: 'Vitamins',
          ),
          'quantity': 3,
        },
      ],
      'totalPrice': 36.75,
      'status': 'Processing',
      'paymentMethod': 'Cash',
      'createdAt': '2024-03-20 09:15 AM',
      'address': '456 Oak Ave, Quezon City',
    },
    {
      'id': 'ORD003',
      'customerName': 'Mike Johnson',
      'customerEmail': 'mike@example.com',
      'items': [
        {
          'product': PharmacyProduct(
            id: '10',
            name: 'Digital Thermometer',
            localImagePath: 'lib/Images/Digital Thermometer.png',
            price: 250.00,
            stock: 30,
            stockStatus: 'In Stock',
            description: 'Fast and accurate temperature reading.',
            category: 'Personal Care',
          ),
          'quantity': 1,
        },
      ],
      'totalPrice': 250.00,
      'status': 'Delivered',
      'paymentMethod': 'Card',
      'createdAt': '2024-03-19 02:00 PM',
      'address': '789 Pine Rd, Makati',
    },
    {
      'id': 'ORD004',
      'customerName': 'Sarah Williams',
      'customerEmail': 'sarah@example.com',
      'items': [
        {
          'product': PharmacyProduct(
            id: '15',
            name: 'Fish Oil',
            localImagePath: 'lib/Images/Fish Oil.png',
            price: 12.50,
            stock: 55,
            stockStatus: 'In Stock',
            description: 'Omega-3 supplement for heart health.',
            category: 'Vitamins',
          ),
          'quantity': 2,
        },
      ],
      'totalPrice': 25.00,
      'status': 'Cancelled',
      'paymentMethod': 'GCash',
      'createdAt': '2024-03-19 11:30 AM',
      'address': '321 Elm St, Pasig',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2A) : theme.scaffoldBackgroundColor;
    final cardBgColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Orders Management',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          Color statusColor;
          switch (order['status']) {
            case 'Pending':
              statusColor = Colors.orange;
              break;
            case 'Processing':
              statusColor = Colors.blue;
              break;
            case 'Delivered':
              statusColor = const Color(0xFF4CAF50);
              break;
            case 'Cancelled':
              statusColor = Colors.red;
              break;
            default:
              statusColor = Colors.grey;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order['status'] == 'Pending'
                      ? Icons.hourglass_empty
                      : order['status'] == 'Processing'
                          ? Icons.sync
                          : order['status'] == 'Delivered'
                              ? Icons.check_circle
                              : Icons.cancel,
                  color: statusColor,
                  size: 24,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      order['id'],
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    order['customerName'],
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(order['items'] as List).length} items • ${order['paymentMethod']}',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${(order['totalPrice'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['createdAt'].toString().split(' ')[0],
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              onTap: () => _showOrderDetails(order),
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2A) : theme.scaffoldBackgroundColor;
    final cardBgColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        Color statusColor;
        switch (order['status']) {
          case 'Pending':
            statusColor = Colors.orange;
            break;
          case 'Processing':
            statusColor = Colors.blue;
            break;
          case 'Delivered':
            statusColor = const Color(0xFF4CAF50);
            break;
          case 'Cancelled':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order ${order['id']}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Customer Information',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name', order['customerName'], textColor),
                    _buildInfoRow('Email', order['customerEmail'], textColor),
                    _buildInfoRow('Address', order['address'], textColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Items',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: (order['items'] as List).length,
                  itemBuilder: (context, index) {
                    final item = order['items'][index];
                    final product = item['product'] as PharmacyProduct;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF252B3D) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                product.localImagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.medication,
                                  color: isDark ? Colors.white38 : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Qty: ${item['quantity']} × ₱${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₱${(product.price * item['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Payment Method', order['paymentMethod'], textColor),
                    _buildInfoRow('Subtotal', '₱${(order['totalPrice'] as double).toStringAsFixed(2)}', textColor),
                    _buildInfoRow('Delivery Fee', '₱50.00', textColor),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₱${((order['totalPrice'] as double) + 50).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

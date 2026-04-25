import 'package:flutter/material.dart';
import '../models/order_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        item.product.localImagePath,
        width: 56,
        height: 56,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade800,
            child: const Icon(Icons.medication, color: Colors.grey),
          );
        },
      ),
      title: Text(item.product.name, style: const TextStyle(color: Colors.white)),
      subtitle: Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
      trailing: Text('₱${(item.product.price * item.quantity).toStringAsFixed(2)}', 
        style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

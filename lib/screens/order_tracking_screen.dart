import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';
import '../widgets/network_image_box.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().getById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track order')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final steps = [
      ('Order placed', 'We received your order'),
      ('Preparing', 'Kitchen is cooking'),
      ('On the way', order.riderName != null
          ? '${order.riderName} is delivering'
          : 'Rider assigned'),
      ('Delivered', 'Enjoy your meal!'),
    ];

    int activeStep;
    switch (order.status) {
      case OrderStatus.preparing:
        activeStep = 1;
      case OrderStatus.onTheWay:
        activeStep = 2;
      case OrderStatus.delivered:
        activeStep = 3;
      case OrderStatus.cancelled:
        activeStep = -1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track order', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.emerald700, AppColors.emerald500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.status == OrderStatus.cancelled
                      ? 'Order cancelled'
                      : order.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.address,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (order.status == OrderStatus.cancelled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'This order was cancelled. Contact support if this was a mistake.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          else
            ...List.generate(steps.length, (i) {
              final done = i <= activeStep;
              final current = i == activeStep;
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
                          color: done ? AppColors.emerald600 : Colors.white,
                          border: Border.all(
                            color: done
                                ? AppColors.emerald600
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: done
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      if (i < steps.length - 1)
                        Container(
                          width: 3,
                          height: 44,
                          color: i < activeStep
                              ? AppColors.emerald600
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].$1,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: current
                                  ? AppColors.emerald700
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[i].$2,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          const SizedBox(height: 8),
          const Text(
            'Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...order.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  NetworkImageBox(
                    url: item.food.imageUrl,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item.quantity}× ${item.food.name}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _row('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                if (order.discount > 0) ...[
                  const SizedBox(height: 6),
                  _row('Discount', '-\$${order.discount.toStringAsFixed(2)}'),
                ],
                const SizedBox(height: 6),
                _row('Delivery', '\$${order.deliveryFee.toStringAsFixed(2)}'),
                const Divider(height: 18),
                _row('Total', '\$${order.total.toStringAsFixed(2)}', bold: true),
                const SizedBox(height: 6),
                _row('Payment', order.paymentMethod),
              ],
            ),
          ),
          if (order.status == OrderStatus.preparing ||
              order.status == OrderStatus.onTheWay) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel order?'),
                    content: const Text('You can cancel while the kitchen is still working.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Keep order'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OrderProvider>().cancelOrder(order.id);
                          Navigator.pop(ctx);
                          showAppSnack(context, 'Order cancelled');
                        },
                        child: const Text('Cancel order'),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel order',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          a,
          style: TextStyle(
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          b,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: bold ? AppColors.emerald600 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue, Timestamp;

import 'cart_item.dart';
import 'food_item.dart';

enum OrderStatus { preparing, onTheWay, delivered, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String address;
  final String paymentMethod;
  final DateTime placedAt;
  final OrderStatus status;
  final String? riderName;
  final String? note;
  final String? userId;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.placedAt,
    required this.status,
    this.riderName,
    this.note,
    this.userId,
  });

  Order copyWith({
    OrderStatus? status,
    String? riderName,
    String? id,
    String? userId,
  }) {
    return Order(
      id: id ?? this.id,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      placedAt: placedAt,
      status: status ?? this.status,
      riderName: riderName ?? this.riderName,
      note: note,
      userId: userId ?? this.userId,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get statusStep {
    switch (status) {
      case OrderStatus.preparing:
        return 0;
      case OrderStatus.onTheWay:
        return 1;
      case OrderStatus.delivered:
        return 2;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  static OrderStatus statusFromString(String? value) {
    switch (value) {
      case 'onTheWay':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'preparing':
      default:
        return OrderStatus.preparing;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items
          .map(
            (i) => {
              'foodId': i.food.id,
              'name': i.food.name,
              'price': i.food.price,
              'imageUrl': i.food.imageUrl,
              'category': i.food.category,
              'quantity': i.quantity,
            },
          )
          .toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
      'placedAt': Timestamp.fromDate(placedAt),
      'status': status.name,
      'riderName': riderName,
      'note': note,
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final food = FoodItem(
        id: (m['foodId'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        description: '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        imageUrl: (m['imageUrl'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'Food',
      );
      return CartItem(
        food: food,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    DateTime placedAt = DateTime.now();
    final placed = map['placedAt'];
    if (placed is Timestamp) {
      placedAt = placed.toDate();
    } else if (placed is DateTime) {
      placedAt = placed;
    }

    return Order(
      id: id,
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      address: (map['address'] as String?) ?? '',
      paymentMethod: (map['paymentMethod'] as String?) ?? '',
      placedAt: placedAt,
      status: statusFromString(map['status'] as String?),
      riderName: map['riderName'] as String?,
      note: map['note'] as String?,
      userId: map['userId'] as String?,
    );
  }
}

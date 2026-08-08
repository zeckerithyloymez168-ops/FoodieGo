import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';

import '../models/order.dart';
import 'firestore_service.dart';

class OrderRepository {
  OrderRepository({FirestoreService? firestore})
      : _fs = firestore ?? FirestoreService.instance;

  final FirestoreService _fs;

  Future<Order> createOrder(Order order) async {
    if (!_fs.isAvailable) {
      return order;
    }
    try {
      final ref = _fs.ordersRef.doc();
      final withId = order.copyWith(id: ref.id);
      await ref.set(withId.toMap());
      return withId;
    } catch (e) {
      debugPrint('OrderRepository.createOrder error: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    if (!_fs.isAvailable) return;
    try {
      await _fs.ordersRef.doc(orderId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('OrderRepository.updateStatus error: $e');
    }
  }

  Future<List<Order>> fetchOrders({String? userId}) async {
    if (!_fs.isAvailable) return [];
    try {
      Query<Map<String, dynamic>> q = _fs.ordersRef.orderBy(
        'placedAt',
        descending: true,
      );
      if (userId != null && userId.isNotEmpty) {
        q = _fs.ordersRef
            .where('userId', isEqualTo: userId)
            .orderBy('placedAt', descending: true);
      }
      final snap = await q.limit(50).get();
      return snap.docs
          .map((d) => Order.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('OrderRepository.fetchOrders error: $e');
      try {
        final snap = await _fs.ordersRef.limit(50).get();
        var list = snap.docs
            .map((d) => Order.fromMap(d.id, d.data()))
            .toList();
        if (userId != null && userId.isNotEmpty) {
          list = list.where((o) => o.userId == userId).toList();
        }
        list.sort((a, b) => b.placedAt.compareTo(a.placedAt));
        return list;
      } catch (e2) {
        debugPrint('OrderRepository.fetchOrders fallback error: $e2');
        return [];
      }
    }
  }

  Stream<Order?> watchOrder(String orderId) {
    if (!_fs.isAvailable) {
      return Stream<Order?>.value(null);
    }
    return _fs.ordersRef.doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Order.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<List<Order>> watchOrders({String? userId}) {
    if (!_fs.isAvailable) {
      return Stream<List<Order>>.value(const []);
    }
    return _fs.ordersRef
        .orderBy('placedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      var list = snap.docs
          .map((d) => Order.fromMap(d.id, d.data()))
          .toList();
      if (userId != null && userId.isNotEmpty) {
        list = list.where((o) => o.userId == userId).toList();
      }
      return list;
    });
  }
}

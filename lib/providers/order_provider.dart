import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/firebase_bootstrap.dart';
import '../services/order_repository.dart';
import 'notification_provider.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderRepository? repository})
      : _repo = repository ?? OrderRepository();

  final OrderRepository _repo;
  final List<Order> _orders = [];
  final Map<String, Timer> _timers = {};
  final Map<String, StreamSubscription<Order?>> _watchers = {};
  bool _loading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get loading => _loading;

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadFromCloud({String? userId}) async {
    if (!FirebaseBootstrap.isReady) return;
    _loading = true;
    notifyListeners();
    try {
      final remote = await _repo.fetchOrders(userId: userId);
      // Merge: keep local-only that aren't on server yet, prefer remote
      final map = <String, Order>{for (final o in _orders) o.id: o};
      for (final o in remote) {
        map[o.id] = o;
      }
      _orders
        ..clear()
        ..addAll(map.values);
      _orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    } catch (e) {
      debugPrint('OrderProvider.loadFromCloud: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<Order> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required String address,
    required String paymentMethod,
    String? note,
    String? userId,
    NotificationProvider? notifications,
  }) async {
    var order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: items
          .map((i) => CartItem(food: i.food, quantity: i.quantity))
          .toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: (subtotal + deliveryFee - discount).clamp(0, double.infinity),
      address: address,
      paymentMethod: paymentMethod,
      placedAt: DateTime.now(),
      status: OrderStatus.preparing,
      note: note,
      riderName: 'Sam Rivera',
      userId: userId,
    );

    // Persist to FoodieGo /orders when Firebase is ready
    try {
      order = await _repo.createOrder(order);
    } catch (e) {
      debugPrint('OrderProvider: cloud save failed, keeping local: $e');
    }

    _orders.insert(0, order);
    notifyListeners();

    notifications?.add(
      AppNotification(
        id: 'n-${order.id}',
        title: 'Order placed',
        body: 'We received ${order.id}. Kitchen is preparing your food.',
        createdAt: DateTime.now(),
        type: 'order',
      ),
    );

    _simulateProgress(order.id, notifications);
    _watchRemote(order.id);
    return order;
  }

  void _watchRemote(String orderId) {
    if (!FirebaseBootstrap.isReady) return;
    _watchers[orderId]?.cancel();
    _watchers[orderId] = _repo.watchOrder(orderId).listen((Order? remote) {
      if (remote == null) return;
      final i = _orders.indexWhere((o) => o.id == orderId);
      if (i < 0) {
        _orders.insert(0, remote);
      } else {
        _orders[i] = remote;
      }
      notifyListeners();
    });
  }

  void _simulateProgress(String orderId, NotificationProvider? notifications) {
    _timers[orderId]?.cancel();
    _timers[orderId] = Timer(const Duration(seconds: 8), () async {
      await _updateStatus(orderId, OrderStatus.onTheWay);
      notifications?.add(
        AppNotification(
          id: 'n-ride-$orderId',
          title: 'Rider on the way 🛵',
          body: 'Sam picked up your order and is heading to you.',
          createdAt: DateTime.now(),
          type: 'order',
        ),
      );
      _timers[orderId] = Timer(const Duration(seconds: 10), () async {
        await _updateStatus(orderId, OrderStatus.delivered);
        notifications?.add(
          AppNotification(
            id: 'n-done-$orderId',
            title: 'Delivered 🎉',
            body: 'Enjoy your meal! Rate your order anytime.',
            createdAt: DateTime.now(),
            type: 'order',
          ),
        );
      });
    });
  }

  Future<void> _updateStatus(String id, OrderStatus status) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    _orders[i] = _orders[i].copyWith(status: status);
    notifyListeners();
    await _repo.updateStatus(id, status);
  }

  Future<void> cancelOrder(String id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    if (_orders[i].status == OrderStatus.delivered) return;
    _timers[id]?.cancel();
    _orders[i] = _orders[i].copyWith(status: OrderStatus.cancelled);
    notifyListeners();
    await _repo.updateStatus(id, OrderStatus.cancelled);
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    for (final w in _watchers.values) {
      w.cancel();
    }
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _items = [
    AppNotification(
      id: 'n1',
      title: 'Welcome to GreenBite 🌿',
      body: 'Get 10% off your first order with code FOOD10.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'promo',
    ),
    AppNotification(
      id: 'n2',
      title: 'Free delivery weekend',
      body: 'Orders over \$20 get free delivery until Sunday.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: 'promo',
    ),
  ];

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void add(AppNotification n) {
    _items.insert(0, n);
    notifyListeners();
  }
}

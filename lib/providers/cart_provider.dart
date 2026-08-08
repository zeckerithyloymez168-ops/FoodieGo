import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _promoCode;
  double _promoPercent = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get promoCode => _promoCode;
  double get promoPercent => _promoPercent;

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  double get deliveryFee {
    if (isEmpty) return 0;
    // Free delivery over $20
    if (subtotal >= 20) return 0;
    return 2.0;
  }

  double get discount {
    if (_promoPercent <= 0 || subtotal <= 0) return 0;
    return subtotal * (_promoPercent / 100);
  }

  double get total => (subtotal + deliveryFee - discount).clamp(0, double.infinity);

  bool get isEmpty => _items.isEmpty;

  int quantityOf(String foodId) {
    final match = _items.where((i) => i.food.id == foodId);
    if (match.isEmpty) return 0;
    return match.first.quantity;
  }

  void addItem(FoodItem food, {int qty = 1}) {
    final index = _items.indexWhere((i) => i.food.id == food.id);
    if (index >= 0) {
      _items[index].quantity += qty;
    } else {
      _items.add(CartItem(food: food, quantity: qty));
    }
    notifyListeners();
  }

  void increment(String foodId) {
    final index = _items.indexWhere((i) => i.food.id == foodId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(String foodId) {
    final index = _items.indexWhere((i) => i.food.id == foodId);
    if (index < 0) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.removeWhere((i) => i.food.id == foodId);
    notifyListeners();
  }

  /// Returns true if promo applied.
  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    if (c == 'FOOD10') {
      _promoCode = 'FOOD10';
      _promoPercent = 10;
      notifyListeners();
      return true;
    }
    if (c == 'GREEN20') {
      _promoCode = 'GREEN20';
      _promoPercent = 20;
      notifyListeners();
      return true;
    }
    _promoCode = null;
    _promoPercent = 0;
    notifyListeners();
    return false;
  }

  void clearPromo() {
    _promoCode = null;
    _promoPercent = 0;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    clearPromo();
    notifyListeners();
  }
}

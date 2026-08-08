import 'package:flutter/foundation.dart';

import '../models/food_item.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<String, FoodItem> _items = {};

  List<FoodItem> get items => _items.values.toList();

  int get count => _items.length;

  bool isFavorite(String id) => _items.containsKey(id);

  void toggle(FoodItem food) {
    if (_items.containsKey(food.id)) {
      _items.remove(food.id);
    } else {
      _items[food.id] = food;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

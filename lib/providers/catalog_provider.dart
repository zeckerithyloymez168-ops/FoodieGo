import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/food_item.dart';
import '../services/firebase_bootstrap.dart';
import '../services/food_repository.dart';

/// App-wide menu catalog (Firestore FoodieGo → foods, or local sample).
class CatalogProvider extends ChangeNotifier {
  CatalogProvider({FoodRepository? repository})
      : _repo = repository ?? FoodRepository();

  final FoodRepository _repo;
  List<FoodItem> _foods = SampleData.allFoods;
  bool _loading = false;
  String? _error;
  bool _fromFirestore = false;
  StreamSubscription<List<FoodItem>>? _sub;

  List<FoodItem> get foods => List.unmodifiable(_foods);
  bool get loading => _loading;
  String? get error => _error;
  bool get fromFirestore => _fromFirestore;
  bool get firebaseReady => FirebaseBootstrap.isReady;

  List<FoodItem> get popular =>
      _foods.where((f) => f.isPopular).toList();

  List<FoodItem> get pizzas =>
      _foods.where((f) => f.category == 'Pizza').toList();

  FoodItem? byId(String id) {
    try {
      return _foods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FoodItem> byCategory(String name) {
    if (name == 'All') return _foods;
    return _foods
        .where((f) => f.category.toLowerCase() == name.toLowerCase())
        .toList();
  }

  List<FoodItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _foods;
    return _foods
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _repo.fetchFoods();
      _foods = list;
      _fromFirestore = FirebaseBootstrap.isReady &&
          list.isNotEmpty &&
          // if only sample, still ok — but mark based on firebase ready + repo used firestore path
          FirebaseBootstrap.isReady;
    } catch (e) {
      _error = e.toString();
      _foods = SampleData.allFoods;
      _fromFirestore = false;
    }

    _loading = false;
    notifyListeners();

    // Live updates when Firestore is online
    if (FirebaseBootstrap.isReady) {
      await _sub?.cancel();
      _sub = _repo.watchFoods().listen((list) {
        if (list.isNotEmpty) {
          _foods = list;
          _fromFirestore = true;
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('CatalogProvider stream error: $e');
      });
    }
  }

  /// One-time seed of sample menu into FoodieGo/foods.
  Future<int> seedToFirestore() async {
    final n = await _repo.seedSampleFoods();
    await load();
    return n;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/food_item.dart';
import 'firestore_service.dart';

/// Loads menu items from FoodieGo Firestore, falls back to [SampleData].
class FoodRepository {
  FoodRepository({FirestoreService? firestore})
      : _fs = firestore ?? FirestoreService.instance;

  final FirestoreService _fs;

  Future<List<FoodItem>> fetchFoods() async {
    if (!_fs.isAvailable) {
      return SampleData.allFoods;
    }
    try {
      await _fs.ensureResolved();
      final snap = await _fs.foodsRef.orderBy('name').get();
      if (snap.docs.isEmpty) {
        debugPrint('FoodRepository: no foods in Firestore — using sample data');
        return SampleData.allFoods;
      }
      return snap.docs
          .map((d) => FoodItem.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('FoodRepository.fetchFoods error: $e');
      return SampleData.allFoods;
    }
  }

  Stream<List<FoodItem>> watchFoods() {
    if (!_fs.isAvailable) {
      return Stream.value(SampleData.allFoods);
    }
    return _fs.foodsRef.orderBy('name').snapshots().map((snap) {
      if (snap.docs.isEmpty) return SampleData.allFoods;
      return snap.docs
          .map((d) => FoodItem.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<FoodItem?> getById(String id) async {
    if (!_fs.isAvailable) {
      return SampleData.byId(id);
    }
    try {
      final doc = await _fs.foodsRef.doc(id).get();
      if (!doc.exists || doc.data() == null) return SampleData.byId(id);
      return FoodItem.fromMap(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('FoodRepository.getById error: $e');
      return SampleData.byId(id);
    }
  }

  /// Writes sample menu into FoodieGo /foods (idempotent by document id).
  Future<int> seedSampleFoods() async {
    if (!_fs.isAvailable) {
      throw StateError('Firebase not configured');
    }
    await _fs.ensureResolved();
    final batch = _fs.db.batch();
    var count = 0;
    for (final food in SampleData.allFoods) {
      final ref = _fs.foodsRef.doc(food.id);
      batch.set(ref, food.toMap(), SetOptions(merge: true));
      count++;
    }
    // categories
    for (final cat in SampleData.categories) {
      final ref = _fs.categoriesRef.doc(cat.name.toLowerCase().replaceAll(' ', '_'));
      batch.set(
        ref,
        {
          'name': cat.name,
          'emoji': cat.emoji,
          'colorValue': cat.background.toARGB32(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    debugPrint('FoodRepository: seeded $count foods into FoodieGo');
    return count;
  }
}

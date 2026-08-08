import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/address.dart';
import '../models/food_item.dart';
import 'firestore_service.dart';

class UserRepository {
  UserRepository({FirestoreService? firestore})
      : _fs = firestore ?? FirestoreService.instance;

  final FirestoreService _fs;

  Future<void> upsertProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
  }) async {
    if (!_fs.isAvailable) return;
    try {
      await _fs.userDoc(uid).set(
        {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('UserRepository.upsertProfile error: $e');
    }
  }

  Future<List<Address>> fetchAddresses(String uid) async {
    if (!_fs.isAvailable) return [];
    try {
      final snap = await _fs.userAddresses(uid).get();
      return snap.docs.map((d) {
        final m = d.data();
        return Address(
          id: d.id,
          label: (m['label'] as String?) ?? 'Home',
          line1: (m['line1'] as String?) ?? '',
          city: (m['city'] as String?) ?? '',
          phone: (m['phone'] as String?) ?? '',
          isDefault: m['isDefault'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('UserRepository.fetchAddresses error: $e');
      return [];
    }
  }

  Future<void> saveAddress(String uid, Address address) async {
    if (!_fs.isAvailable) return;
    try {
      await _fs.userAddresses(uid).doc(address.id).set({
        'label': address.label,
        'line1': address.line1,
        'city': address.city,
        'phone': address.phone,
        'isDefault': address.isDefault,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserRepository.saveAddress error: $e');
    }
  }

  Future<void> setFavorite(String uid, FoodItem food, bool liked) async {
    if (!_fs.isAvailable) return;
    try {
      final ref = _fs.userFavorites(uid).doc(food.id);
      if (liked) {
        await ref.set({
          ...food.toMap(),
          'foodId': food.id,
          'savedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.delete();
      }
    } catch (e) {
      debugPrint('UserRepository.setFavorite error: $e');
    }
  }

  Future<List<String>> fetchFavoriteIds(String uid) async {
    if (!_fs.isAvailable) return [];
    try {
      final snap = await _fs.userFavorites(uid).get();
      return snap.docs.map((d) => d.id).toList();
    } catch (e) {
      debugPrint('UserRepository.fetchFavoriteIds error: $e');
      return [];
    }
  }
}

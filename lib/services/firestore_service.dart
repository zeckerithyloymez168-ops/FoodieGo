import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

/// Access to Firestore for the **FoodieGo** Firebase project
/// (`foodiego-f2abf`, database `(default)`).
///
/// Collections: foods, orders, users, categories
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  static const String foods = 'foods';
  static const String orders = 'orders';
  static const String users = 'users';
  static const String categories = 'categories';

  FirebaseFirestore? _db;
  bool _resolved = false;

  bool get isAvailable => FirebaseBootstrap.isReady && Firebase.apps.isNotEmpty;

  FirebaseFirestore get db {
    if (!isAvailable) {
      throw StateError(
        'Firestore is not available. Configure Firebase first '
        '(see FIREBASE_SETUP.md).',
      );
    }
    _db ??= _createDb(FirebaseBootstrap.preferredDatabaseId);
    return _db!;
  }

  FirebaseFirestore _createDb(String databaseId) {
    if (databaseId == '(default)') {
      return FirebaseFirestore.instanceFor(app: Firebase.app());
    }
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: databaseId,
    );
  }

  Future<void> ensureResolved() async {
    if (!isAvailable || _resolved) return;
    _db = _createDb(FirebaseBootstrap.preferredDatabaseId);
    FirebaseBootstrap.activeDatabaseId =
        FirebaseBootstrap.preferredDatabaseId;
    try {
      await _db!.collection('_meta').limit(1).get();
      debugPrint(
        'Firestore: ready on ${FirebaseBootstrap.activeDatabaseId} '
        '(project FoodieGo / foodiego-f2abf)',
      );
    } catch (e) {
      debugPrint('Firestore probe: $e (continuing; rules/network may still work)');
    }
    _resolved = true;
  }

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      db.collection(path);

  CollectionReference<Map<String, dynamic>> get foodsRef => collection(foods);
  CollectionReference<Map<String, dynamic>> get ordersRef => collection(orders);
  CollectionReference<Map<String, dynamic>> get usersRef => collection(users);
  CollectionReference<Map<String, dynamic>> get categoriesRef =>
      collection(categories);

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersRef.doc(uid);

  CollectionReference<Map<String, dynamic>> userAddresses(String uid) =>
      userDoc(uid).collection('addresses');

  CollectionReference<Map<String, dynamic>> userFavorites(String uid) =>
      userDoc(uid).collection('favorites');

  CollectionReference<Map<String, dynamic>> userNotifications(String uid) =>
      userDoc(uid).collection('notifications');
}

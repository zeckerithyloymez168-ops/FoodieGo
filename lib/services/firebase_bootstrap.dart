import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Result of trying to start Firebase.
class FirebaseBootstrap {
  FirebaseBootstrap._(this.ready, this.error);

  final bool ready;
  final Object? error;

  static bool get isReady => _instance?.ready ?? false;
  static FirebaseBootstrap? _instance;

  /// Firestore database ID for the FoodieGo project.
  ///
  /// Uses `(default)` — free tier / no billing required.
  /// A second named DB like `foodiego` needs billing enabled on the project.
  static const String preferredDatabaseId = '(default)';

  /// Active database id after resolve.
  static String activeDatabaseId = preferredDatabaseId;

  static Future<FirebaseBootstrap> init() async {
    if (_instance != null) return _instance!;

    final projectId = DefaultFirebaseOptions.android.projectId;
    final looksLikePlaceholder =
        projectId == 'YOUR_PROJECT_ID' ||
            DefaultFirebaseOptions.android.apiKey.startsWith('YOUR_');

    if (looksLikePlaceholder && !DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'Firebase: not configured. Run flutterfire configure. Using sample data.',
      );
      _instance = FirebaseBootstrap._(false, 'not_configured');
      return _instance!;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      debugPrint(
        'Firebase: ready (project=$projectId / FoodieGo). '
        'Will use Firestore database "$preferredDatabaseId" '
        '(or default if that name is not created yet).',
      );
      _instance = FirebaseBootstrap._(true, null);
    } catch (e, st) {
      debugPrint('Firebase: init failed: $e\n$st');
      _instance = FirebaseBootstrap._(false, e);
    }
    return _instance!;
  }
}

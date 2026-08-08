import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_bootstrap.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Connect Firebase project foodiego-f2abf + Firestore (FoodieGo / default).
  final firebase = await FirebaseBootstrap.init();
  if (firebase.ready) {
    try {
      await FirestoreService.instance.ensureResolved();
      debugPrint(
        'FoodieGo: Firebase connected · Firestore=${FirebaseBootstrap.activeDatabaseId}',
      );
    } catch (e) {
      debugPrint('FoodieGo: Firestore resolve warning: $e');
    }
  } else {
    debugPrint('FoodieGo: offline mode (sample data)');
  }

  runApp(const FoodOrderApp());
}

class FoodOrderApp extends StatelessWidget {
  const FoodOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, lang, theme, child) {
          return MaterialApp(
            title: lang.tr('app_name'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            locale: lang.locale,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:food_order_app/providers/auth_provider.dart';
import 'package:food_order_app/providers/cart_provider.dart';
import 'package:food_order_app/providers/catalog_provider.dart';
import 'package:food_order_app/providers/favorites_provider.dart';
import 'package:food_order_app/providers/notification_provider.dart';
import 'package:food_order_app/providers/order_provider.dart';
import 'package:food_order_app/screens/main_shell.dart';
import 'package:food_order_app/theme/app_theme.dart';

void main() {
  testWidgets('FoodieGo home loads after auth', (WidgetTester tester) async {
    final auth = AuthProvider()..continueAsGuest();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MainShell(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('like to order'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_nav_bar.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'pizza_menu_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final lang = context.watch<LanguageProvider>();

    final navItems = [
      GlassNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: lang.tr('home'),
      ),
      GlassNavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu_rounded,
        label: lang.tr('menu'),
      ),
      GlassNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: lang.tr('orders'),
      ),
      GlassNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: lang.tr('profile'),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onOpenMenu: () => setState(() => _index = 1),
            onOpenCart: _openCart,
            onOpenProfile: () => setState(() => _index = 3),
          ),
          PizzaMenuScreen(
            onBackHome: () => setState(() => _index = 0),
          ),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: cartCount > 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.extended(
                onPressed: _openCart,
                backgroundColor: AppColors.emerald600,
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                ),
                label: Text(
                  '${lang.tr('cart')} · $cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: GlassNavBar(
        currentIndex: _index,
        badgeCount: null,
        items: navItems,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';
import '../widgets/food_card.dart';
import '../widgets/network_image_box.dart';
import 'food_detail_screen.dart';

class PizzaMenuScreen extends StatefulWidget {
  final VoidCallback? onBackHome;

  const PizzaMenuScreen({super.key, this.onBackHome});

  @override
  State<PizzaMenuScreen> createState() => _PizzaMenuScreenState();
}

class _PizzaMenuScreenState extends State<PizzaMenuScreen> {
  bool _vegOnly = false;

  void _openDetail(FoodItem food) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final catalog = context.watch<CatalogProvider>();
    final pizzaList = catalog.pizzas.isNotEmpty
        ? catalog.pizzas
        : SampleData.pizzas;
    final pizzas =
        _vegOnly ? pizzaList.where((p) => p.isVeg).toList() : pizzaList;
    final heroFood =
        catalog.byId('pepperoni') ?? pizzaList.first;
    final isFav = favs.isFavorite(heroFood.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ========== HERO ==========
          // Use SliverAppBar flexible space so SafeArea / back buttons never clash
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _circleBtn(
                Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (widget.onBackHome != null) {
                    widget.onBackHome!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _circleBtn(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: Colors.redAccent,
                  onTap: () {
                    favs.toggle(heroFood);
                    showAppSnack(
                      context,
                      isFav ? 'Removed from favorites' : 'Saved to favorites ❤️',
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(
                    url: SampleData.pizzaHeroImage,
                    borderRadius: BorderRadius.zero,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald600.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '★ 4.9 · Pizza House',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Artisan Pizzas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 12),
                            ],
                          ),
                        ),
                        Text(
                          'Wood-fired · Fresh daily · 15–25 min',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========== HEADER + FILTERS ==========
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our pizzas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Choose your favorite',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _filterChip(
                    'All',
                    active: !_vegOnly,
                    onTap: () => setState(() => _vegOnly = false),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Veg',
                    active: _vegOnly,
                    onTap: () => setState(() => _vegOnly = true),
                  ),
                ],
              ),
            ),
          ),

          // ========== GRID ==========
          if (pizzas.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No veg pizzas right now',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // width / height — taller cells for image + info
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final food = pizzas[index];
                    return PizzaGridCard(
                      food: food,
                      onTap: () => _openDetail(food),
                      onAdd: () {
                        cart.addItem(food);
                        showAppSnack(context, 'Added ${food.name} to cart');
                      },
                    );
                  },
                  childCount: pizzas.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circleBtn(
    IconData icon, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _filterChip(
    String label, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? AppColors.emerald600 : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: active ? null : Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

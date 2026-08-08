import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';
import '../widgets/network_image_box.dart';
import 'food_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (favs.count > 0)
            TextButton(
              onPressed: () {
                favs.clear();
                showAppSnack(context, 'Favorites cleared');
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.emerald600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: favs.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap the heart on any dish to save it',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: favs.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final food = favs.items[i];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FoodDetailScreen(food: food),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        NetworkImageBox(
                          url: food.imageUrl,
                          width: 72,
                          height: 72,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${food.price.toStringAsFixed(2)} · ${food.time}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            cart.addItem(food);
                            showAppSnack(context, 'Added ${food.name}');
                          },
                          icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: AppColors.emerald600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => favs.remove(food.id),
                          icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

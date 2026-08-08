import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';
import '../widgets/network_image_box.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _qty = 1;
  String? _size = 'Regular';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  double get _unitPrice {
    if (_size == 'Large') return widget.food.price * 1.25;
    if (_size == 'Small') return widget.food.price * 0.85;
    return widget.food.price;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final favs = context.watch<FavoritesProvider>();
    final cart = context.watch<CartProvider>();
    final isFav = favs.isFavorite(food.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: _circleBtn(
                    Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context),
                  ),
                  actions: [
                    _circleBtn(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      () {
                        favs.toggle(food);
                        showAppSnack(
                          context,
                          isFav ? 'Removed from favorites' : 'Added to favorites ❤️',
                        );
                      },
                      color: isFav ? Colors.redAccent : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: NetworkImageBox(
                      url: food.imageUrl,
                      height: 280,
                      width: double.infinity,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald50,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      food.category,
                                      style: const TextStyle(
                                        color: AppColors.emerald700,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${_unitPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _meta(Icons.star_rounded, AppColors.star,
                                '${food.rating} (${food.reviewCount})'),
                            _meta(Icons.schedule, AppColors.textSecondary, food.time),
                            _meta(Icons.local_fire_department_outlined,
                                AppColors.textSecondary, food.kcal),
                            _meta(
                              food.isVeg ? Icons.eco : Icons.set_meal,
                              food.isVeg ? AppColors.emerald600 : Colors.redAccent,
                              food.isVeg ? 'Veg' : 'Non-veg',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          food.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (food.ingredients.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: food.ingredients
                                .map(
                                  (i) => Chip(
                                    label: Text(
                                      i,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 22),
                        const Text(
                          'Size',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: ['Small', 'Regular', 'Large'].map((s) {
                            final active = _size == s;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s),
                                selected: active,
                                onSelected: (_) => setState(() => _size = s),
                                selectedColor: AppColors.emerald600,
                                labelStyle: TextStyle(
                                  color: active ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Special instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _note,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'e.g. Extra spicy, no onions…',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              if (_qty > 1) setState(() => _qty--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Text(
                                '$_qty',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _qtyBtn(Icons.add, () => setState(() => _qty++), filled: true),
                            const Spacer(),
                            Text(
                              'In cart: ${cart.quantityOf(food.id)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Add as base food item (size is UI-only demo)
                    cart.addItem(food, qty: _qty);
                    showAppSnack(
                      context,
                      'Added $_qty× ${food.name} · \$${(_unitPrice * _qty).toStringAsFixed(2)}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Add to cart · \$${(_unitPrice * _qty).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.emerald600 : Colors.white,
          border: filled ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : AppColors.emerald600,
        ),
      ),
    );
  }
}

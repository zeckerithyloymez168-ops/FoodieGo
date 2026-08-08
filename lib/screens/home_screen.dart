import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/food_card.dart';
import '../widgets/language_toggle_widget.dart';
import '../widgets/network_image_box.dart';
import 'addresses_screen.dart';
import 'food_detail_screen.dart';
import 'notifications_screen.dart';
import 'order_tracking_screen.dart';
import 'search_screen.dart';



class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenProfile;

  const HomeScreen({
    super.key,
    this.onOpenMenu,
    this.onOpenCart,
    this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'Food';
  int _locationIndex = 0;
  int _bannerIndex = 0;
  final _bannerController = PageController(viewportFraction: 0.92);

  static const _banners = [
    _PromoBanner(
      tag: 'HOT DEAL',
      title: '30% Off\nKebab Wraps',
      subtitle: 'Code · FOOD10 · Free delivery',
      colors: [AppColors.emerald900, AppColors.emerald700, AppColors.emerald600],
      imageUrl: SampleData.promoImage,
    ),
    _PromoBanner(
      tag: 'WEEKEND',
      title: 'Free Delivery\nover \$20',
      subtitle: 'On all artisan pizzas today',
      colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=85',
    ),
    _PromoBanner(
      tag: 'NEW',
      title: 'Buddha Bowl\nFresh drop',
      subtitle: 'Healthy picks under 15 min',
      colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF22C55E)],
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=85',
    ),
  ];

  static const _kitchens = [
    _Kitchen(
      name: 'Pizza House',
      cuisine: 'Italian · Pizza',
      rating: 4.9,
      time: '20–30 min',
      fee: '\$1.99',
      image:
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600&q=85',
    ),
    _Kitchen(
      name: 'Green Bowl Co',
      cuisine: 'Healthy · Salads',
      rating: 4.7,
      time: '12–20 min',
      fee: 'Free',
      image:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=85',
    ),
    _Kitchen(
      name: 'Burger Lab',
      cuisine: 'American · Fast',
      rating: 4.8,
      time: '15–25 min',
      fee: '\$0.99',
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=85',
    ),
    _Kitchen(
      name: 'Sakura Sushi',
      cuisine: 'Japanese · Rolls',
      rating: 4.6,
      time: '25–35 min',
      fee: '\$2.49',
      image:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=85',
    ),
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openPizzaMenu() => widget.onOpenMenu?.call();

  void _openDetail(FoodItem food) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );
  }

  void _openSearch({String? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final cart = context.watch<CartProvider>();
    final catalog = context.watch<CatalogProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final orders = context.watch<OrderProvider>().orders;
    final allFoods =
        catalog.foods.isNotEmpty ? catalog.foods : SampleData.allFoods;
    final popular = catalog.popular.isNotEmpty
        ? catalog.popular
        : SampleData.popular;
    final recommended = allFoods.take(6).toList();
    final under10 = allFoods.where((f) => f.price < 10).toList();
    final topRated = [...allFoods]..sort((a, b) => b.rating.compareTo(a.rating));
    final bestSellers = topRated.take(6).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD1FAE5),
            Color(0xFFECFDF5),
            Color(0xFFF7FDF9),
            Colors.white,
          ],
          stops: [0.0, 0.12, 0.32, 0.55],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ========== TOP HEADER ==========
            SliverToBoxAdapter(child: _buildHeader(cart.itemCount, unread)),

            // ========== GREETING + SEARCH ==========
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(child: _buildGreeting()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ========== SERVICE PILLS ==========
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _buildServicePills()),

            // ========== QUICK ACTIONS ==========
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(child: _buildQuickActions(orders)),

            // ========== ACTIVE ORDER BANNER ==========
            if (orders.isNotEmpty &&
                orders.first.status != OrderStatus.delivered &&
                orders.first.status != OrderStatus.cancelled) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildActiveOrderCard(orders.first)),
            ],

            // ========== CATEGORIES ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(
                lang.tr('categories'),
                onSeeAll: () => _openSearch(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildCategories()),

            // ========== PROMO CAROUSEL ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(lang.tr('special_offers'), actionLabel: lang.tr('all_deals')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildPromoCarousel()),

            // ========== POPULAR HORIZONTAL ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(
                lang.tr('popular_now'),
                onSeeAll: _openPizzaMenu,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildPopularRail(popular, cart)),

            // ========== FEATURED KITCHENS ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(
                lang.tr('featured_kitchens'),
                onSeeAll: _openPizzaMenu,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildKitchens()),

            // ========== BEST SELLERS GRID ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(
                lang.tr('best_sellers'),
                onSeeAll: () => _openSearch(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildBestSellers(bestSellers, cart)),

            // ========== UNDER $10 ==========
            if (under10.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: _sectionTitle(
                  lang.tr('under_10'),
                  onSeeAll: () => _openSearch(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildUnder10(under10, cart)),
            ],

            // ========== RECOMMENDED LIST ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: _sectionTitle(
                lang.tr('recommended'),
                onSeeAll: () => _openSearch(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildRecommendedList(recommended, cart)),

            // ========== WHY GREENBITE ==========
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(child: _buildWhyUs()),

            // bottom padding for glass nav + FAB
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(int cartCount, int unread) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final currentAddr = auth.defaultAddress?.fullLine ?? 'Phnom Penh, Cambodia';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _roundIconBtn(
                Icons.notifications_none_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (unread > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: _badge('$unread', Colors.red),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: _whiteCard(),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.emerald50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: AppColors.emerald600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.tr('deliver_to'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            currentAddr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const LanguageToggleWidget(style: LanguageToggleStyle.compact),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _roundIconBtn(
                Icons.shopping_bag_outlined,
                onTap: widget.onOpenCart ??
                    () => _toast('${lang.tr('cart')} · $cartCount ${lang.tr('items')}'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: _badge('$cartCount', AppColors.emerald600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GREETING + SEARCH
  // ---------------------------------------------------------------------------
  Widget _buildGreeting() {
    final lang = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppColors.emerald600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lang.isKhmer
                ? 'តើអ្នកចង់កុម្ម៉ង់\nអាហារអ្វីដែរថ្ងៃនេះ?'
                : 'What would you\nlike to order?',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final lang = context.watch<LanguageProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openSearch(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: _whiteCard(radius: 18),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Text(
                      lang.tr('search_food'),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emerald600, AppColors.emerald500],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald600.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _openSearch(),
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SERVICE PILLS
  // ---------------------------------------------------------------------------
  Widget _buildServicePills() {
    final icons = {
      'Food': '🍽',
      'Grocery': '🛒',
      'Medicine': '💊',
    };
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: SampleData.serviceFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = SampleData.serviceFilters[i];
          final active = _filter == label;
          return GestureDetector(
            onTap: () {
              setState(() => _filter = label);
              _toast('$label selected');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: active
                    ? const LinearGradient(
                        colors: [AppColors.emerald600, AppColors.emerald500],
                      )
                    : null,
                color: active ? null : Colors.white,
                border: active
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? AppColors.emerald600.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: active ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${icons[label]} $label',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK ACTIONS
  // ---------------------------------------------------------------------------
  Widget _buildQuickActions(List orders) {
    final items = [
      _QuickAction(
        icon: Icons.replay_rounded,
        label: 'Reorder',
        color: const Color(0xFFDCFCE7),
        iconColor: AppColors.emerald700,
        onTap: () {
          if (orders.isEmpty) {
            _toast('No past orders to reorder');
          } else {
            _toast('Reorder · open Orders tab');
          }
        },
      ),
      _QuickAction(
        icon: Icons.delivery_dining_rounded,
        label: 'Track',
        color: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () {
          if (orders.isEmpty) {
            _toast('No active orders');
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: orders.first.id),
              ),
            );
          }
        },
      ),
      _QuickAction(
        icon: Icons.local_offer_rounded,
        label: 'Offers',
        color: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        onTap: () => _toast('Use FOOD10 or GREEN20 at checkout'),
      ),
      _QuickAction(
        icon: Icons.favorite_rounded,
        label: 'Favorites',
        color: const Color(0xFFFEE2E2),
        iconColor: Colors.redAccent,
        onTap: () {
          if (widget.onOpenProfile != null) {
            widget.onOpenProfile!();
          } else {
            _toast('Open Profile');
          }
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: items
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: a.onTap,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: a.color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(a.icon, color: a.iconColor, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIVE ORDER
  // ---------------------------------------------------------------------------
  Widget _buildActiveOrderCard(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: order.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [AppColors.emerald700, AppColors.emerald500],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald600.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active order',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${order.statusLabel} · ${order.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------
  Widget _buildCategories() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: SampleData.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = SampleData.categories[i];
          return GestureDetector(
            onTap: () {
              if (cat.name == 'Pizza') {
                _openPizzaMenu();
              } else {
                _openSearch(category: cat.name);
              }
            },
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: cat.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(cat.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROMO CAROUSEL
  // ---------------------------------------------------------------------------
  Widget _buildPromoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final b = _banners[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _toast('${b.tag} · ${b.subtitle}'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: b.colors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: b.colors.first.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 16, 6, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        b.tag,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      b.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      b.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.88),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 150,
                              child: NetworkImageBox(
                                url: b.imageUrl,
                                height: 150,
                                width: 120,
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.emerald600 : AppColors.emerald200,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // POPULAR RAIL
  // ---------------------------------------------------------------------------
  Widget _buildPopularRail(List<FoodItem> popular, CartProvider cart) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: popular.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final food = popular[i];
          return PopularFoodCard(
            food: food,
            onTap: () => _openDetail(food),
            onAdd: () {
              cart.addItem(food);
              _toast('Added ${food.name} to cart');
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURED KITCHENS
  // ---------------------------------------------------------------------------
  Widget _buildKitchens() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _kitchens.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final k = _kitchens[i];
          return GestureDetector(
            onTap: () {
              if (k.name.contains('Pizza')) {
                _openPizzaMenu();
              } else {
                _openSearch();
              }
            },
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageBox(
                    url: k.image,
                    height: 110,
                    width: 260,
                    borderRadius: BorderRadius.zero,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          k.cuisine,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.star),
                            Text(
                              ' ${k.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.schedule,
                                size: 13, color: AppColors.textMuted),
                            Text(
                              ' ${k.time}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              k.fee,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.emerald600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BEST SELLERS (2-col compact cards)
  // ---------------------------------------------------------------------------
  Widget _buildBestSellers(List<FoodItem> items, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.take(4).map((food) {
              return SizedBox(
                width: w,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => _openDetail(food),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NetworkImageBox(
                            url: food.imageUrl,
                            height: 100,
                            width: w,
                            borderRadius: BorderRadius.zero,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 12, color: AppColors.star),
                                    Text(
                                      ' ${food.rating}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${food.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emerald600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cart.addItem(food);
                                      _toast('Added ${food.name}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald600,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UNDER $10
  // ---------------------------------------------------------------------------
  Widget _buildUnder10(List<FoodItem> items, CartProvider cart) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final food = items[i];
          return GestureDetector(
            onTap: () => _openDetail(food),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  NetworkImageBox(
                    url: food.imageUrl,
                    width: 80,
                    height: 120,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Budget',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          food.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.time,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${food.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                cart.addItem(food);
                                _toast('Added ${food.name}');
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emerald600,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RECOMMENDED LIST
  // ---------------------------------------------------------------------------
  Widget _buildRecommendedList(List<FoodItem> items, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((food) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => _openDetail(food),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
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
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              food.category,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 13, color: AppColors.star),
                                Text(
                                  ' ${food.rating}  ·  ${food.time}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${food.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              cart.addItem(food);
                              _toast('Added ${food.name}');
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.emerald200),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.emerald700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WHY US
  // ---------------------------------------------------------------------------
  Widget _buildWhyUs() {
    final points = [
      (Icons.bolt_rounded, 'Fast delivery', 'Avg 20 min'),
      (Icons.eco_rounded, 'Fresh food', 'Daily made'),
      (Icons.verified_user_rounded, 'Secure pay', 'Safe & easy'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.emerald200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why GreenBite?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.emerald800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: points.map((p) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(p.$1, color: AppColors.emerald600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED
  // ---------------------------------------------------------------------------
  Widget _sectionTitle(
    String title, {
    VoidCallback? onSeeAll,
    String actionLabel = 'See all',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.emerald600,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration _whiteCard({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      height: 16,
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _roundIconBtn(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small data holders (home-only)
// -----------------------------------------------------------------------------
class _PromoBanner {
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final String imageUrl;

  const _PromoBanner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.imageUrl,
  });
}

class _Kitchen {
  final String name;
  final String cuisine;
  final double rating;
  final String time;
  final String fee;
  final String image;

  const _Kitchen({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.time,
    required this.fee,
    required this.image,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}

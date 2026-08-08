import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_bootstrap.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';
import '../widgets/language_toggle_widget.dart';
import 'addresses_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _seeding = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<CatalogProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final favCount = context.watch<FavoritesProvider>().count;
    final firebaseOk = FirebaseBootstrap.isReady;
    final lang = context.watch<LanguageProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            Text(
              lang.tr('profile'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.emerald700, AppColors.emerald500],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald600.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        if (auth.isGuest)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              lang.tr('guest_mode'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editProfile(context, auth),
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Firebase / FoodieGo status
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        firebaseOk ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: firebaseOk ? AppColors.emerald600 : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firebaseOk
                                  ? lang.tr('firestore_connected')
                                  : lang.tr('firestore_offline'),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              firebaseOk
                                  ? catalog.fromFirestore
                                      ? '${catalog.foods.length} foods from cloud'
                                      : 'Project foodiego-f2abf · tap seed if empty'
                                  : 'See FIREBASE_SETUP.md',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (firebaseOk) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _seeding
                            ? null
                            : () async {
                                setState(() => _seeding = true);
                                try {
                                  final n =
                                      await context.read<CatalogProvider>().seedToFirestore();
                                  if (context.mounted) {
                                    showAppSnack(
                                      context,
                                      'Seeded $n foods into FoodieGo ✓',
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showAppSnack(context, 'Seed failed: $e');
                                  }
                                } finally {
                                  if (mounted) setState(() => _seeding = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _seeding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _seeding ? 'Seeding…' : lang.tr('seed_data'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Settings & Preferences / ការកំណត់',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            const LanguageToggleWidget(style: LanguageToggleStyle.tile),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.emerald600,
                  ),
                ),
                title: Text(
                  lang.isKhmer ? 'ម៉ូដងងឹត (Dark Mode)' : 'Dark Mode',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Text(
                  theme.isDarkMode
                      ? (lang.isKhmer ? 'បើកដំណើរការ' : 'Enabled')
                      : (lang.isKhmer ? 'បិទដំណើរការ' : 'Disabled'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                trailing: Switch.adaptive(
                  value: theme.isDarkMode,
                  activeColor: AppColors.emerald600,
                  onChanged: (_) => theme.toggleTheme(),
                ),
              ),
            ),
            _tile(
              Icons.location_on_outlined,
              lang.tr('my_addresses'),
              auth.defaultAddress?.fullLine ?? 'Add a delivery address',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesScreen()),
              ),
            ),
            _tile(
              Icons.favorite_border,
              lang.tr('favorites'),
              '$favCount saved dishes',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
            _tile(
              Icons.notifications_none_rounded,
              lang.tr('notifications'),
              unread > 0 ? '$unread unread' : 'All caught up',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              badge: unread,
            ),

            _tile(
              Icons.payment_outlined,
              'Payment methods',
              'Cash · Card · Wallet',
              () => showAppSnack(context, 'Demo: payment methods UI'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            _tile(
              Icons.help_outline,
              'Help center',
              'FAQs & live chat demo',
              () => showAppSnack(context, 'Help center · demo'),
            ),
            _tile(
              Icons.info_outline,
              'About FoodieGo',
              'Version 1.2.0 · Firestore FoodieGo',
              () => showAppSnack(
                context,
                firebaseOk
                    ? 'Cloud mode · database FoodieGo'
                    : 'Local demo · see FIREBASE_SETUP.md',
              ),
            ),
            const SizedBox(height: 24),
            if (auth.isGuest)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    int badge = 0,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: AppColors.emerald600),
            if (badge > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _editProfile(BuildContext context, AuthProvider auth) {
    final name = TextEditingController(text: auth.name);
    final phone = TextEditingController(text: auth.phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  auth.updateProfile(name: name.text, phone: phone.text);
                  Navigator.pop(ctx);
                  showAppSnack(context, 'Profile updated');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald600,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

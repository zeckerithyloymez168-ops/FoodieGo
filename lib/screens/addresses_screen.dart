import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/snack.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Saved addresses',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.emerald600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: auth.addresses.isEmpty
          ? const Center(child: Text('No addresses yet'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: auth.addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = auth.addresses[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: a.isDefault
                          ? AppColors.emerald600
                          : AppColors.border,
                      width: a.isDefault ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            a.label.toLowerCase() == 'work'
                                ? Icons.work_outline
                                : Icons.home_outlined,
                            color: AppColors.emerald600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            a.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          if (a.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: AppColors.emerald700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'default') {
                                auth.setDefaultAddress(a.id);
                                showAppSnack(context, 'Default address updated');
                              } else if (v == 'delete') {
                                auth.removeAddress(a.id);
                                showAppSnack(context, 'Address removed');
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'default',
                                child: Text('Set as default'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.fullLine,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.phone,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final label = TextEditingController(text: 'Home');
    final line1 = TextEditingController();
    final city = TextEditingController();
    final phone = TextEditingController(
      text: context.read<AuthProvider>().phone,
    );

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: label,
                decoration: const InputDecoration(
                  labelText: 'Label (Home / Work)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: line1,
                decoration: const InputDecoration(
                  labelText: 'Street address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: city,
                decoration: const InputDecoration(
                  labelText: 'City / Area',
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
                  if (line1.text.trim().isEmpty || city.text.trim().isEmpty) {
                    showAppSnack(context, 'Fill address and city');
                    return;
                  }
                  context.read<AuthProvider>().addAddress(
                        Address(
                          id: 'a-${DateTime.now().millisecondsSinceEpoch}',
                          label: label.text.trim().isEmpty
                              ? 'Home'
                              : label.text.trim(),
                          line1: line1.text.trim(),
                          city: city.text.trim(),
                          phone: phone.text.trim(),
                          isDefault:
                              context.read<AuthProvider>().addresses.isEmpty,
                        ),
                      );
                  Navigator.pop(ctx);
                  showAppSnack(context, 'Address saved');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald600,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Save address',
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

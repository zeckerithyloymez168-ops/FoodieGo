import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  final _noteController = TextEditingController();
  String _payment = 'Cash on delivery';
  bool _loading = false;

  final _payments = const [
    'Cash on delivery',
    'Credit / Debit card',
    'Digital wallet',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final addr = auth.defaultAddress;
    _addressController = TextEditingController(
      text: addr?.fullLine ?? 'Downtown Plaza, Suite 12',
    );
    _phoneController = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final notes = context.read<NotificationProvider>();
    if (cart.isEmpty) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    final auth = context.read<AuthProvider>();
    final order = await orders.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      discount: cart.discount,
      address: _addressController.text.trim(),
      paymentMethod: _payment,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      userId: auth.uid,
      notifications: notes,
    );
    cart.clear();

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addresses = context.watch<AuthProvider>().addresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Delivery details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            if (addresses.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final a = addresses[i];
                    return ActionChip(
                      label: Text(a.label),
                      onPressed: () {
                        _addressController.text = a.fullLine;
                        _phoneController.text = a.phone;
                        setState(() {});
                      },
                      backgroundColor: AppColors.emerald50,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration(
                'Delivery address',
                Icons.location_on_outlined,
              ),
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter address' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration('Phone number', Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter phone' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: _inputDecoration(
                'Order note (optional)',
                Icons.notes_outlined,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ..._payments.map((method) {
              final selected = _payment == method;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected ? AppColors.emerald600 : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _payment = method),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        selected ? AppColors.emerald600 : AppColors.textMuted,
                  ),
                  title: Text(
                    method,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _sum(
                    'Items (${cart.itemCount})',
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                  ),
                  if (cart.discount > 0) ...[
                    const SizedBox(height: 8),
                    _sum(
                      'Discount (${cart.promoCode})',
                      '-\$${cart.discount.toStringAsFixed(2)}',
                    ),
                  ],
                  const SizedBox(height: 8),
                  _sum(
                    cart.deliveryFee == 0 ? 'Delivery (FREE)' : 'Delivery',
                    '\$${cart.deliveryFee.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 20),
                  _sum(
                    'Total',
                    '\$${cart.total.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: cart.isEmpty || _loading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Place order · \$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.emerald600),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.emerald600, width: 2),
      ),
    );
  }

  Widget _sum(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
            color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: highlight ? 18 : 14,
            color: highlight ? AppColors.emerald600 : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

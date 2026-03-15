import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedCity = 'Addis Ababa';
  double _shippingFee = AppConstants.defaultShippingFee;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.fullName ?? '';
    _phoneCtrl.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;
    final total = ref.read(cartTotalProvider);

    final success = await ref.read(checkoutProvider.notifier).createOrder(
      items: cartItems,
      shippingAddress: ShippingAddress(
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        addressLine: _addressCtrl.text.trim(),
        city: _selectedCity,
        state: _selectedCity,
        country: 'Ethiopia',
      ),
      totalAmount: total + _shippingFee,
      shippingFee: _shippingFee,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    if (!success || !mounted) return;
    final order = ref.read(checkoutProvider).order!;
    final user = ref.read(currentUserProvider)!;
    final parts = user.fullName.split(' ');

    final paySuccess = await ref.read(checkoutProvider.notifier).initiatePayment(
      email: user.email,
      firstName: parts.isNotEmpty ? parts.first : user.fullName,
      lastName: parts.length > 1 ? parts.last : '',
      phoneNumber: user.phoneNumber ?? _phoneCtrl.text.trim(),
    );

    if (!paySuccess || !mounted) return;
    final state = ref.read(checkoutProvider);
    context.push(RouteConstants.payment, extra: {
      'checkoutUrl': state.checkoutUrl!,
      'txRef': state.txRef!,
      'orderId': order.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);

    return LoadingOverlay(
      isLoading: checkoutState.isLoading,
      message: 'Processing order...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _sectionTitle(context, 'Delivery Information'),
              const SizedBox(height: 12),
              AppTextField(controller: _nameCtrl, label: 'Full Name', prefixIcon: Icons.person_outline_rounded, validator: AppValidators.validateFullName),
              const SizedBox(height: 12),
              AppTextField(controller: _phoneCtrl, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: AppValidators.validateEthiopianPhone),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(labelText: 'City', prefixIcon: const Icon(Icons.location_city_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: AppConstants.ethiopianCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() { _selectedCity = v!; _shippingFee = AppConstants.getShippingFee(v); }),
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _addressCtrl, label: 'Delivery Address', hint: 'Street, building, area...', prefixIcon: Icons.home_outlined, maxLines: 2, validator: (v) => v?.isEmpty == true ? 'Address is required' : null),
              const SizedBox(height: 12),
              AppTextField(controller: _notesCtrl, label: 'Order Notes (optional)', hint: 'Any special instructions...', prefixIcon: Icons.note_outlined, maxLines: 2),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Order Summary'),
              const SizedBox(height: 12),
              ...cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text('${item.title} x${item.quantity}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                  Text(AppFormatters.formatCurrency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              )),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                Text(AppFormatters.formatCurrency(subtotal)),
              ]),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Shipping', style: TextStyle(color: AppColors.textSecondary)),
                Text(AppFormatters.formatCurrency(_shippingFee)),
              ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(AppFormatters.formatCurrency(subtotal + _shippingFee),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryGradientStart)),
              ]),
              const SizedBox(height: 24),
              if (checkoutState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(checkoutState.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              AppButton(onPressed: _placeOrder, label: 'Pay with Chapa', isLoading: checkoutState.isLoading,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Image.asset('assets/images/chapa.png', height: 20, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    const SizedBox(width: 8),
                    const Text('Pay with Chapa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ])),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
}
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/product_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final String productId; final ProductEntity? product;
  const ProductEditScreen({super.key, required this.productId, this.product});
  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  List<String> _existingImages = [];
  List<File> _newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toStringAsFixed(2) ?? '');
    _stockCtrl = TextEditingController(text: p?.stockCount.toString() ?? '');
    _existingImages = List.from(p?.imageUrls ?? []);
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _stockCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await ref.read(updateProductUseCaseProvider).call(
      productId: widget.productId, title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text), stockCount: int.parse(_stockCtrl.text),
      newImages: _newImages.isNotEmpty ? _newImages : null, existingImageUrls: _existingImages,
    );
    setState(() => _isLoading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) { ref.read(productsProvider.notifier).loadProducts(refresh: true); context.pop(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Product'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_existingImages.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length,
                  itemBuilder: (_, i) => Stack(children: [
                    Padding(padding: const EdgeInsets.only(right: 8, top: 8),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: _existingImages[i], width: 90, height: 90, fit: BoxFit.cover))),
                    Positioned(top: 0, right: 0, child: GestureDetector(
                      onTap: () => setState(() => _existingImages.removeAt(i)),
                      child: Container(
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16)))),
                  ]),
                ),
              ),
            const SizedBox(height: 12),
            AppTextField(controller: _titleCtrl, label: 'Title', prefixIcon: Icons.title_rounded, validator: AppValidators.validateProductTitle),
            const SizedBox(height: 12),
            AppTextField(controller: _descCtrl, label: 'Description', prefixIcon: Icons.description_outlined, maxLines: 4, validator: AppValidators.validateDescription),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppTextField(controller: _priceCtrl, label: 'Price (ETB)', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, validator: AppValidators.validatePrice)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: _stockCtrl, label: 'Stock', prefixIcon: Icons.inventory_2_outlined, keyboardType: TextInputType.number, validator: AppValidators.validateStockCount)),
            ]),
            const SizedBox(height: 24),
            AppButton(onPressed: _submit, label: 'Save Changes', isLoading: _isLoading),
            const SizedBox(height: 32),
          ])),
        ),
      ),
    );
  }
}
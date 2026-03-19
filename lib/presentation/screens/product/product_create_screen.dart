import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/product_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({super.key});
  @override
  ConsumerState<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  String _category = AppConstants.productCategories[1];
  List<File> _images = [];
  bool _isLoading = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _stockCtrl.dispose(); _brandCtrl.dispose(); super.dispose(); }

  Future<void> _pickImages() async {
    final result = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (result.isNotEmpty) setState(() => _images = result.map((x) => File(x.path)).toList());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one image'))); return; }
    setState(() => _isLoading = true);
    final result = await ref.read(createProductUseCaseProvider).call(
      title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text), category: _category,
      images: _images, stockCount: int.parse(_stockCtrl.text),
      brand: _brandCtrl.text.trim().isNotEmpty ? _brandCtrl.text.trim() : null,
    );
    setState(() => _isLoading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (p) { ref.read(productsProvider.notifier).loadProducts(refresh: true); context.pop(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Uploading product...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Product'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.dividerBorder.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerBorder, style: BorderStyle.solid),
                ),
                child: _images.isEmpty
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('Tap to add product images', style: TextStyle(color: AppColors.textSecondary)),
                      ])
                    : ListView.builder(
                        scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8),
                        itemCount: _images.length,
                        itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(borderRadius: BorderRadius.circular(8),
                            child: Image.file(_images[i], width: 120, height: 120, fit: BoxFit.cover))),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _titleCtrl, label: 'Product Title', prefixIcon: Icons.title_rounded, validator: AppValidators.validateProductTitle),
            const SizedBox(height: 12),
            AppTextField(controller: _descCtrl, label: 'Description', prefixIcon: Icons.description_outlined, maxLines: 4, validator: AppValidators.validateDescription),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(labelText: 'Category', prefixIcon: const Icon(Icons.category_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: AppConstants.productCategories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppTextField(controller: _priceCtrl, label: 'Price (ETB)', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, validator: AppValidators.validatePrice)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: _stockCtrl, label: 'Stock Qty', prefixIcon: Icons.inventory_2_outlined, keyboardType: TextInputType.number, validator: AppValidators.validateStockCount)),
            ]),
            const SizedBox(height: 12),
            AppTextField(controller: _brandCtrl, label: 'Brand (optional)', prefixIcon: Icons.branding_watermark_outlined),
            const SizedBox(height: 24),
            AppButton(onPressed: _submit, label: 'Publish Product', isLoading: _isLoading, icon: Icons.publish_rounded),
            const SizedBox(height: 32),
          ])),
        ),
      ),
    );
  }
}
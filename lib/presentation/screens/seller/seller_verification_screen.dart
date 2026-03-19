import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class SellerVerificationScreen extends ConsumerStatefulWidget {
  const SellerVerificationScreen({super.key});
  @override
  ConsumerState<SellerVerificationScreen> createState() => _SellerVerificationScreenState();
}

class _SellerVerificationScreenState extends ConsumerState<SellerVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<File> _documents = [];
  bool _isLoading = false;

  @override
  void dispose() { _businessNameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
    if (result != null) {
      setState(() => _documents = result.paths.whereType<String>().map((p) => File(p)).toList());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_documents.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please attach at least one document'))); return; }
    setState(() => _isLoading = true);
    final userId = ref.read(currentUserIdProvider)!;
    final result = await ref.read(userRepositoryProvider).submitSellerVerification(
      userId: userId, documents: _documents,
      businessName: _businessNameCtrl.text.trim(), businessDescription: _descCtrl.text.trim(),
    );
    setState(() => _isLoading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification submitted! We will review within 48 hours.'))); context.pop(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Submitting verification...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Seller Verification'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.secondaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Column(children: [
                Icon(Icons.verified_outlined, color: AppColors.secondaryAccent, size: 48),
                SizedBox(height: 12),
                Text('Get Verified Seller Badge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                SizedBox(height: 8),
                Text('Submit your business documents to get verified. Verification increases buyer trust and boosts your sales.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 24),
            AppTextField(controller: _businessNameCtrl, label: 'Business Name', prefixIcon: Icons.business_outlined, validator: (v) => v?.isEmpty == true ? 'Required' : null),
            const SizedBox(height: 14),
            AppTextField(controller: _descCtrl, label: 'Business Description', prefixIcon: Icons.description_outlined, maxLines: 3, validator: (v) => v?.isEmpty == true ? 'Required' : null),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickDocuments,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(_documents.isEmpty ? 'Attach Documents' : '${_documents.length} file(s) attached'),
            ),
            const SizedBox(height: 24),
            AppButton(onPressed: _submit, label: 'Submit for Verification', isLoading: _isLoading),
          ])),
        ),
      ),
    );
  }
}
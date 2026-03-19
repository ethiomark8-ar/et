import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _pickAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _avatarFile = File(file.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final userId = ref.read(currentUserIdProvider)!;
    final result = await ref.read(userRepositoryProvider).updateProfile(
      userId: userId, fullName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(), avatar: _avatarFile,
    );
    setState(() => _isLoading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'))); context.pop(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryGradientStart,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : user?.avatarUrl != null ? CachedNetworkImageProvider(user!.avatarUrl!) : null,
                      child: (_avatarFile == null && user?.avatarUrl == null)
                          ? Text(user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.primaryGradientStart, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              AppTextField(controller: _nameCtrl, label: 'Full Name', prefixIcon: Icons.person_outline_rounded, validator: AppValidators.validateFullName),
              const SizedBox(height: 14),
              AppTextField(controller: _phoneCtrl, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: AppValidators.validateEthiopianPhone),
              const SizedBox(height: 32),
              AppButton(onPressed: _save, label: 'Save Changes', isLoading: _isLoading),
            ]),
          ),
        ),
      ),
    );
  }
}
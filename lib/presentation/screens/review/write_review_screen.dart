import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String orderId; final String productId; final String productTitle;
  const WriteReviewScreen({super.key, required this.orderId, required this.productId, required this.productTitle});
  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewCtrl = TextEditingController();
  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void dispose() { _reviewCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await ref.read(submitReviewUseCaseProvider).call(
      productId: widget.productId, orderId: widget.orderId,
      rating: _rating, reviewText: _reviewCtrl.text.trim(),
    );
    setState(() => _isLoading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!'))); context.pop(); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Write Review'), backgroundColor: AppColors.primaryDark),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(widget.productTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Center(child: RatingBar.builder(
              initialRating: _rating, minRating: 1, direction: Axis.horizontal,
              itemCount: 5, itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.ratingActive),
              onRatingUpdate: (r) => setState(() => _rating = r),
              itemSize: 48,
            )),
            const SizedBox(height: 24),
            AppTextField(controller: _reviewCtrl, label: 'Your Review', hint: 'Share your experience with this product...', prefixIcon: Icons.rate_review_outlined, maxLines: 4, validator: (v) => v?.trim().isEmpty == true ? 'Please write a review' : null),
            const SizedBox(height: 32),
            AppButton(onPressed: _submit, label: 'Submit Review', isLoading: _isLoading, icon: Icons.send_rounded),
          ])),
        ),
      ),
    );
  }
}
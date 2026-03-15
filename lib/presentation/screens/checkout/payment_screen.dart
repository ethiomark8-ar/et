import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final String txRef;
  final String orderId;
  const PaymentScreen({super.key, required this.checkoutUrl, required this.txRef, required this.orderId});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (req) {
          final url = req.url;
          if (url.contains(AppConstants.chapaCallbackSuccess) || url.contains('success')) {
            _handleSuccess();
            return NavigationDecision.prevent;
          }
          if (url.contains(AppConstants.chapaCallbackCancel) || url.contains('cancel')) {
            _handleCancel();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _handleSuccess() async {
    final verified = await ref.read(checkoutProvider.notifier).handlePaymentCallback(widget.txRef);
    if (!mounted) return;
    if (verified) {
      ref.read(cartProvider.notifier).clearCart();
      context.go('/order/confirmation/${widget.orderId}');
    } else {
      _showError('Payment verification failed. Please contact support.');
    }
  }

  void _handleCancel() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
      context.pop();
    }
  }

  void _showError(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Payment Error'),
      content: Text(msg),
      actions: [TextButton(onPressed: () { Navigator.pop(context); context.pop(); }, child: const Text('OK'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: _handleCancel),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryGradientStart)),
        ],
      ),
    );
  }
}
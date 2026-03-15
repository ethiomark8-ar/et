import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_verifications_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/payment_screen.dart';
import '../screens/checkout/order_confirmation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/product_create_screen.dart';
import '../screens/product/product_edit_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/review/write_review_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/seller_products_screen.dart';
import '../screens/seller/seller_verification_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;

      final location = state.matchedLocation;

      // Don't redirect on splash
      if (location == RouteConstants.splash) return null;

      // Still initializing
      if (isLoading) return RouteConstants.splash;

      // Auth routes
      final isAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register') ||
          location.startsWith('/forgot-password');

      if (!isAuthenticated && !isAuthRoute) {
        return RouteConstants.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Shell with Bottom Nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteConstants.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteConstants.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteConstants.notifications,
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: RouteConstants.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Product routes
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final product = state.extra as ProductEntity?;
          return ProductDetailScreen(productId: productId, product: product);
        },
      ),
      GoRoute(
        path: RouteConstants.productCreate,
        builder: (context, state) => const ProductCreateScreen(),
      ),
      GoRoute(
        path: '/product/edit/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final product = state.extra as ProductEntity?;
          return ProductEditScreen(productId: productId, product: product);
        },
      ),

      // Order routes
      GoRoute(
        path: RouteConstants.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteConstants.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteConstants.payment,
        builder: (context, state) {
          final data = state.extra as Map<String, String>?;
          return PaymentScreen(
            checkoutUrl: data?['checkoutUrl'] ?? '',
            txRef: data?['txRef'] ?? '',
            orderId: data?['orderId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/order/confirmation/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderConfirmationScreen(orderId: orderId);
        },
      ),

      // Chat
      GoRoute(
        path: RouteConstants.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatDetailScreen(
            chatId: chatId,
            otherUserName: extra?['otherUserName'] as String? ?? 'User',
            otherUserAvatar: extra?['otherUserAvatar'] as String?,
          );
        },
      ),

      // Profile routes
      GoRoute(
        path: RouteConstants.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.sellerVerification,
        builder: (context, state) => const SellerVerificationScreen(),
      ),

      // Seller
      GoRoute(
        path: RouteConstants.sellerDashboard,
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.sellerProducts,
        builder: (context, state) => const SellerProductsScreen(),
      ),
      GoRoute(
        path: RouteConstants.sellerOrders,
        builder: (context, state) => const SellerOrdersScreen(),
      ),

      // Admin
      GoRoute(
        path: RouteConstants.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminOrders,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminVerifications,
        builder: (context, state) => const AdminVerificationsScreen(),
      ),

      // Reviews
      GoRoute(
        path: '/review/write/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return WriteReviewScreen(
            orderId: orderId,
            productId: extra?['productId'] as String? ?? '',
            productTitle: extra?['productTitle'] as String? ?? '',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error?.message}'),
      ),
    ),
  );
});

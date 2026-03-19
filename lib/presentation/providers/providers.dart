import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_constants.dart';
import '../../data/datasources/local/cart_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/datasources/remote/order_remote_datasource.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/cart/cart_usecases.dart';
import '../../domain/usecases/chat/chat_usecases.dart';
import '../../domain/usecases/order/order_usecases.dart';
import '../../domain/usecases/product/product_usecases.dart';
import '../../domain/usecases/review/review_usecases.dart';

// ── Firebase ────────────────────────────────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn(scopes: ['email']));
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ── Hive ────────────────────────────────────────────────────────────────────
final cartBoxProvider = Provider<Box<CartItemModel>>(
  (ref) => Hive.box<CartItemModel>(HiveConstants.cartBox),
);
final settingsBoxProvider = Provider<Box>(
  (ref) => Hive.box(HiveConstants.settingsBox),
);

// ── DataSources ─────────────────────────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    auth: ref.watch(firebaseAuthProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    auth: ref.watch(firebaseAuthProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl(cartBox: ref.watch(cartBoxProvider));
});

// ── Repositories ─────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    remoteDataSource: ref.watch(orderRemoteDataSourceProvider),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    auth: ref.watch(firebaseAuthProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    uuid: ref.watch(uuidProvider),
  );
});

// ── UseCases ─────────────────────────────────────────────────────────────────
final signInUseCaseProvider = Provider((ref) => SignInUseCase(ref.watch(authRepositoryProvider)));
final signUpUseCaseProvider = Provider((ref) => SignUpUseCase(ref.watch(authRepositoryProvider)));
final googleSignInUseCaseProvider = Provider((ref) => GoogleSignInUseCase(ref.watch(authRepositoryProvider)));
final signOutUseCaseProvider = Provider((ref) => SignOutUseCase(ref.watch(authRepositoryProvider)));
final forgotPasswordUseCaseProvider = Provider((ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)));
final getCurrentUserUseCaseProvider = Provider((ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)));

final getProductsUseCaseProvider = Provider((ref) => GetProductsUseCase(ref.watch(productRepositoryProvider)));
final getProductByIdUseCaseProvider = Provider((ref) => GetProductByIdUseCase(ref.watch(productRepositoryProvider)));
final getProductsBySellerUseCaseProvider = Provider((ref) => GetProductsBySellerUseCase(ref.watch(productRepositoryProvider)));
final getFeaturedProductsUseCaseProvider = Provider((ref) => GetFeaturedProductsUseCase(ref.watch(productRepositoryProvider)));
final createProductUseCaseProvider = Provider((ref) => CreateProductUseCase(ref.watch(productRepositoryProvider)));
final updateProductUseCaseProvider = Provider((ref) => UpdateProductUseCase(ref.watch(productRepositoryProvider)));
final deleteProductUseCaseProvider = Provider((ref) => DeleteProductUseCase(ref.watch(productRepositoryProvider)));
final searchProductsUseCaseProvider = Provider((ref) => SearchProductsUseCase(ref.watch(productRepositoryProvider)));
final toggleWishlistUseCaseProvider = Provider((ref) => ToggleWishlistUseCase(ref.watch(productRepositoryProvider)));
final getWishlistProductsUseCaseProvider = Provider((ref) => GetWishlistProductsUseCase(ref.watch(productRepositoryProvider)));

final createOrderUseCaseProvider = Provider((ref) => CreateOrderUseCase(ref.watch(orderRepositoryProvider)));
final getOrderByIdUseCaseProvider = Provider((ref) => GetOrderByIdUseCase(ref.watch(orderRepositoryProvider)));
final getBuyerOrdersUseCaseProvider = Provider((ref) => GetBuyerOrdersUseCase(ref.watch(orderRepositoryProvider)));
final getSellerOrdersUseCaseProvider = Provider((ref) => GetSellerOrdersUseCase(ref.watch(orderRepositoryProvider)));
final updateOrderStatusUseCaseProvider = Provider((ref) => UpdateOrderStatusUseCase(ref.watch(orderRepositoryProvider)));
final confirmDeliveryUseCaseProvider = Provider((ref) => ConfirmDeliveryUseCase(ref.watch(orderRepositoryProvider)));
final initiatePaymentUseCaseProvider = Provider((ref) => InitiatePaymentUseCase(ref.watch(orderRepositoryProvider)));
final verifyPaymentUseCaseProvider = Provider((ref) => VerifyPaymentUseCase(ref.watch(orderRepositoryProvider)));

final addToCartUseCaseProvider = Provider((ref) => AddToCartUseCase(ref.watch(cartRepositoryProvider)));
final removeFromCartUseCaseProvider = Provider((ref) => RemoveFromCartUseCase(ref.watch(cartRepositoryProvider)));
final updateQuantityUseCaseProvider = Provider((ref) => UpdateQuantityUseCase(ref.watch(cartRepositoryProvider)));
final getCartItemsUseCaseProvider = Provider((ref) => GetCartItemsUseCase(ref.watch(cartRepositoryProvider)));
final clearCartUseCaseProvider = Provider((ref) => ClearCartUseCase(ref.watch(cartRepositoryProvider)));
final syncCartUseCaseProvider = Provider((ref) => SyncCartUseCase(ref.watch(cartRepositoryProvider)));

final submitReviewUseCaseProvider = Provider((ref) => SubmitReviewUseCase(ref.watch(reviewRepositoryProvider)));
final getProductReviewsUseCaseProvider = Provider((ref) => GetProductReviewsUseCase(ref.watch(reviewRepositoryProvider)));
final checkHasReviewedUseCaseProvider = Provider((ref) => CheckHasReviewedUseCase(ref.watch(reviewRepositoryProvider)));

final getOrCreateChatUseCaseProvider = Provider((ref) => GetOrCreateChatUseCase(ref.watch(chatRepositoryProvider)));
final sendMessageUseCaseProvider = Provider((ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)));
final sendImageMessageUseCaseProvider = Provider((ref) => SendImageMessageUseCase(ref.watch(chatRepositoryProvider)));
final getUserChatsUseCaseProvider = Provider((ref) => GetUserChatsUseCase(ref.watch(chatRepositoryProvider)));
final markMessagesReadUseCaseProvider = Provider((ref) => MarkMessagesReadUseCase(ref.watch(chatRepositoryProvider)));

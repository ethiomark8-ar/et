import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import 'providers.dart';

// Products list state
class ProductsState {
  final List<ProductEntity> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final String? category;
  final String? sortBy;
  final bool descending;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.category,
    this.sortBy,
    this.descending = true,
  });

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    String? category,
    String? sortBy,
    bool? descending,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final Ref _ref;
  static const int _pageSize = 20;

  ProductsNotifier(this._ref) : super(const ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, products: [], error: null, hasMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _ref.read(getProductsUseCaseProvider).call(
          category: state.category,
          sortBy: state.sortBy,
          descending: state.descending,
          limit: _pageSize,
        );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length == _pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    final lastId = state.products.isNotEmpty ? state.products.last.id : null;
    final result = await _ref.read(getProductsUseCaseProvider).call(
          category: state.category,
          sortBy: state.sortBy,
          descending: state.descending,
          lastDocumentId: lastId,
          limit: _pageSize,
        );

    result.fold(
      (failure) => state = state.copyWith(isLoadingMore: false),
      (newProducts) => state = state.copyWith(
        isLoadingMore: false,
        products: [...state.products, ...newProducts],
        hasMore: newProducts.length == _pageSize,
      ),
    );
  }

  Future<void> setCategory(String? category) async {
    state = state.copyWith(category: category == 'All' ? null : category);
    await loadProducts(refresh: true);
  }

  Future<void> setSorting({required String sortBy, required bool descending}) async {
    state = state.copyWith(sortBy: sortBy, descending: descending);
    await loadProducts(refresh: true);
  }

  void clearFilter() {
    state = const ProductsState();
    loadProducts();
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(ref);
});

// Single product provider
final productByIdProvider = FutureProvider.family<ProductEntity?, String>((ref, productId) async {
  final result = await ref.read(getProductByIdUseCaseProvider).call(productId);
  return result.fold((_) => null, (product) => product);
});

// Featured products
final featuredProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final result = await ref.read(getFeaturedProductsUseCaseProvider).call(limit: 10);
  return result.fold((_) => [], (products) => products);
});

// Seller products
final sellerProductsProvider = FutureProvider.family<List<ProductEntity>, String>(
  (ref, sellerId) async {
    final result = await ref.read(getProductsBySellerUseCaseProvider).call(sellerId);
    return result.fold((_) => [], (products) => products);
  },
);

// Search state
class SearchState {
  final String query;
  final List<ProductEntity> results;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<ProductEntity>? results,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true, error: null);
    final result = await _ref.read(searchProductsUseCaseProvider).call(query);
    result.fold(
      (failure) => state = state.copyWith(isSearching: false, error: failure.message),
      (products) => state = state.copyWith(isSearching: false, results: products),
    );
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

// Wishlist
final wishlistProvider = FutureProvider.family<List<ProductEntity>, String>((ref, userId) async {
  final result = await ref.read(getWishlistProductsUseCaseProvider).call(userId);
  return result.fold((_) => [], (p) => p);
});

// Watch single product
final watchProductProvider = StreamProvider.family<ProductEntity?, String>((ref, id) {
  return ref.read(productRepositoryProvider).watchProduct(id).handleError((_) => null);
});

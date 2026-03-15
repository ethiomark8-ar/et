class AppConstants {
  // App info
  static const String appName = 'EthioShop';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.ethio.shop';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';
  static const String verificationsCollection = 'verifications';
  static const String notificationsCollection = 'notifications';

  // Storage paths
  static const String usersStoragePath = 'users';
  static const String productsStoragePath = 'products';
  static const String chatsStoragePath = 'chats';
  static const String verificationsStoragePath = 'verifications';

  // Chapa
  static const String chapaPublicKey = 'CHAPUBK_TEST-QmCIBhWYIsdp2tgG0sPr67h5fozBbSz3';
  static const String chapaBaseUrl = 'https://api.chapa.co/v1';
  static const String chapaCallbackSuccess = 'ethioshop://payment/success';
  static const String chapaCallbackCancel = 'ethioshop://payment/cancel';
  static const String chapaReturnUrl = 'https://ethioshop.app/payment/return';

  // Timeouts
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxProductImages = 6;

  // Shipping
  static const double defaultShippingFee = 50.0;
  static const double freeShippingThreshold = 1000.0;

  static double getShippingFee(String city) {
    const fees = {
      'Addis Ababa': 50.0,
      'Adama': 80.0,
      'Hawassa': 120.0,
      'Dire Dawa': 150.0,
      'Bahir Dar': 180.0,
      'Gondar': 200.0,
      'Mekelle': 220.0,
      'Jimma': 130.0,
      'Dessie': 170.0,
    };
    return fees[city] ?? 100.0;
  }

  // Product
  static const double lowStockThreshold = 5.0;
  static const int maxReviewImages = 3;

  // Ethiopian cities
  static const List<String> ethiopianCities = [
    'Addis Ababa', 'Adama', 'Hawassa', 'Dire Dawa',
    'Bahir Dar', 'Gondar', 'Mekelle', 'Jimma',
    'Dessie', 'Harar', 'Dilla', 'Shashemene', 'Arba Minch',
  ];

  // Product categories
  static const List<String> productCategories = [
    'All', 'Electronics', 'Fashion & Clothing', 'Home & Garden',
    'Health & Beauty', 'Food & Beverages', 'Books & Education',
    'Sports & Outdoors', 'Automotive', 'Art & Crafts',
    'Agricultural', 'Traditional Items', 'Other',
  ];
}
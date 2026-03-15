class AppValidators {
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validateConfirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? validateFullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? validateEthiopianPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final clean = v.trim().replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^(251|0)[97]\d{8}$').hasMatch(clean)) {
      return 'Enter a valid Ethiopian phone number';
    }
    return null;
  }

  static String? validateProductTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Product title is required';
    if (v.trim().length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  static String? validateDescription(String? v) {
    if (v == null || v.trim().isEmpty) return 'Description is required';
    if (v.trim().length < 20) return 'Description must be at least 20 characters';
    return null;
  }

  static String? validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required';
    final price = double.tryParse(v.trim());
    if (price == null) return 'Enter a valid price';
    if (price <= 0) return 'Price must be greater than 0';
    if (price > 10000000) return 'Price exceeds maximum allowed';
    return null;
  }

  static String? validateStockCount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Stock count is required';
    final stock = int.tryParse(v.trim());
    if (stock == null) return 'Enter a valid number';
    if (stock < 0) return 'Stock cannot be negative';
    return null;
  }
}
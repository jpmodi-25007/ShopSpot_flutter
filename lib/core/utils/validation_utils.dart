class ValidationUtils {
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  static String? validatePrice(String? value, {String fieldName = 'Price'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Enter a valid number';
    }
    if (price < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? validateQuantity(String? value, {String fieldName = 'Quantity'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final qty = int.tryParse(value);
    if (qty == null) {
      return 'Enter a valid integer';
    }
    if (qty < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }
}

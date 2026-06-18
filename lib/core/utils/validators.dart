class Validators {
  /// Validates if the string is a valid Kenyan phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(
      r'^(\+254|0)?(7|1)([0-9]{8})$',
    );

    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid Kenyan phone number format';
    }

    return null;
  }

  /// Validates if the string is a valid email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates if the string is not empty
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value, {
    required int minLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(
    String? value, {
    required int maxLength,
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates if password meets requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// Validates if OTP is valid (4-6 digits)
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(value)) {
      return 'OTP must be 4-6 digits';
    }

    return null;
  }

  /// Validates if a value is a positive number
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return '${fieldName ?? 'Value'} must be greater than 0';
    }

    return null;
  }

  /// Validates a price range
  static String? validatePriceRange(
    String? minValue,
    String? maxValue, {
    double? min,
    double? max,
  }) {
    if ((minValue == null || minValue.isEmpty) &&
        (maxValue == null || maxValue.isEmpty)) {
      return 'Please enter a price range';
    }

    if (minValue != null && minValue.isNotEmpty) {
      final minPrice = double.tryParse(minValue);
      if (minPrice == null || minPrice < (min ?? 0)) {
        return 'Minimum price is invalid';
      }
    }

    if (maxValue != null && maxValue.isNotEmpty) {
      final maxPrice = double.tryParse(maxValue);
      if (maxPrice == null || maxPrice > (max ?? double.infinity)) {
        return 'Maximum price is invalid';
      }
    }

    if (minValue != null &&
        minValue.isNotEmpty &&
        maxValue != null &&
        maxValue.isNotEmpty) {
      final min = double.parse(minValue);
      final maxV = double.parse(maxValue);
      if (min > maxV) {
        return 'Minimum price cannot be greater than maximum price';
      }
    }

    return null;
  }

  /// Validates M-Pesa receipt number format
  static String? validateMpesaReceipt(String? value) {
    if (value == null || value.isEmpty) {
      return 'M-Pesa receipt number is required';
    }

    // M-Pesa receipts typically follow format: ABC123456789D (3 letters + numbers + letter)
    if (!RegExp(r'^[A-Z]{3}[0-9]{9}[A-Z]$').hasMatch(value.toUpperCase())) {
      return 'Invalid M-Pesa receipt number format';
    }

    return null;
  }

  /// Validates date string (DD/MM/YYYY or YYYY-MM-DD)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      // Try parsing common date formats
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date (DD/MM/YYYY or YYYY-MM-DD)';
    }
  }

  /// Validates if date is not in the past
  static String? validateFutureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return 'Date cannot be in the past';
      }
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Validates username (alphanumeric + underscore, 3-20 chars)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must not exceed 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }
}

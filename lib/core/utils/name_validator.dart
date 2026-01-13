/// Name Validator Utility
/// Provides validation and formatting for user names
/// Synchronized with Backend RegisterDto validation
/// Allows: a-z, A-Z, À-ỹ (Vietnamese diacritics), spaces
/// Rejects: numbers, special characters (@#$%^&*), etc.
class NameValidator {
  /// Validates if name contains only letters and spaces
  /// Supports Vietnamese diacritics (À-ỹ) and spaces
  /// Rejects: numbers (0-9) and special characters (@#$%^&*)
  /// 
  /// Matches Backend Rules:
  /// - FirstName: MinLength 1, MaxLength 100, Pattern: ^[a-zA-ZÀ-ỹ\s]+$
  /// - LastName: MinLength 1, MaxLength 100, Pattern: ^[a-zA-ZÀ-ỹ\s]+$ (but enforce >= 2 for better UX)
  ///
  /// Returns error message if invalid, null if valid
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();
    
    // Check max length first
    if (trimmed.length > 100) {
      return '$fieldName must not exceed 100 characters';
    }

    // Check if contains only letters (including Vietnamese) and spaces
    if (!_isValidNameCharacters(trimmed)) {
      return '$fieldName must contain only letters and spaces';
    }

    // Last name must be at least 2 characters (UX improvement)
    if (fieldName == 'Last name' && trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    return null;
  }

  /// Check if string contains ONLY valid name characters
  /// Pattern: ^[a-zA-ZÀ-ỹ\s]+$
  /// Allows: a-z, A-Z, À-ỹ (Vietnamese diacritics), spaces
  /// Rejects: numbers (0-9), special characters (@#$%^&*), etc.
  static bool _isValidNameCharacters(String value) {
    // Unicode pattern for Latin letters + Vietnamese diacritics + spaces
    // À-ỹ covers Vietnamese characters (U+00C0 to U+1EFF range)
    final namePattern = RegExp(
      r'^[a-zA-ZÀ-ỹ\s]+$',
      unicode: true,
    );

    return namePattern.hasMatch(value);
  }

  /// Format name according to backend rules:
  /// - Auto-capitalize: "john doe" → "John Doe"
  /// - Remove extra spaces: "  john   doe  " → "John Doe"
  /// - Only process if validation passes
  ///
  /// Returns formatted name or original value if null/empty
  static String formatName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    // Trim leading/trailing whitespace
    var formatted = value.trim();

    // Replace multiple spaces with single space
    formatted = formatted.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter of each word
    final words = formatted.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    return capitalizedWords.join(' ');
  }

  /// Sanitize name by removing invalid characters
  /// Used as fallback if validation fails
  /// Keeps only letters and spaces (removes numbers and special chars)
  static String sanitizeName(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    // Keep only letters (including Vietnamese) and spaces
    final sanitized = value.replaceAll(
      RegExp(r'[^a-zA-ZÀ-ỹ\s]', unicode: true),
      '',
    );

    return formatName(sanitized);
  }

  /// Get initials from name for avatar
  /// Returns first letter of first name + first letter of last name
  /// If names are empty, returns '?'
  static String getInitials(String firstName, String lastName) {
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isEmpty && last.isEmpty) {
      return '?';
    } else if (first.isEmpty) {
      return last[0].toUpperCase();
    } else if (last.isEmpty) {
      return first[0].toUpperCase();
    } else {
      return (first[0] + last[0]).toUpperCase();
    }
  }
}

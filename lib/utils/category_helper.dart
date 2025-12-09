class CategoryHelper {
  // Define the single source of truth for category ID to Name mapping
  static const Map<String, String> _categoryMap = {
    '1': 'Computer Science',
    '2': 'Natural Science',
    '3': 'Social Science',
    '4': 'Math',
    '5': 'English Language',
    '6': 'Art & Design',
    '7': 'Business',
  };

  /// Returns the full category name based on the ID prefix.
  /// Uses the first character of the ID for mapping.
  /// If the ID does not match a known prefix, returns 'General'.
  static String getName(String categoryId) {
    if (categoryId.isEmpty) return 'General';
    
    // Get the first character (the prefix)
    final prefix = categoryId.substring(0, 1);
    
    // Use the map to get the name, defaulting to 'General' if not found.
    return _categoryMap[prefix] ?? 'General';
  }
}
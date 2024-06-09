import 'package:collection/collection.dart';

/// Enumeration of supported categories for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#category).
enum Category {
  spot,
  linear,
  option,
  inverse;

  /// Allows to get a [Category] object from API responses
  factory Category.fromString(String str) {
    return Category.values.singleWhere((e) => e.name == str);
  }

  /// Allows to get a [Category] object from API responses where it might not be present
  static Category? tryFromString(String? str) {
    return Category.values.singleWhereOrNull((e) => e.name == str);
  }
}

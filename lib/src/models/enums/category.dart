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
}

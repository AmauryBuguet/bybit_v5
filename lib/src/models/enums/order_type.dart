import 'package:collection/collection.dart';

/// Enumeration of supported order types for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#ordertype).
enum OrderType {
  market("Market"),
  limit("Limit");

  final String json;

  const OrderType(this.json);

  /// Allows to get a [OrderType] object from API responses
  factory OrderType.fromString(String str) {
    return OrderType.values.singleWhere((e) => e.json == str);
  }

  /// Allows to get a [OrderType] object from API responses where it might not be
  static OrderType? tryFromString(String? str) {
    return OrderType.values.singleWhereOrNull((e) => e.json == str);
  }
}

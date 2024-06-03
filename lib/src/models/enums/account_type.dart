import 'package:collection/collection.dart';

/// Enumeration of supported account types for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#accounttype).
enum AccountType {
  contract("CONTRACT"),
  unified("UNIFIED"),
  fund("FUND"),
  spot("SPOT"),
  option("OPTION");

  final String json;

  const AccountType(this.json);

  /// Allows to get a [AccountType] object from API responses
  factory AccountType.fromString(String str) {
    return AccountType.values.singleWhere((e) => e.json == str);
  }

  /// Allows to get a [AccountType] object from API responses that may not contain one
  static AccountType? tryFromString(String? str) {
    return AccountType.values.singleWhereOrNull((e) => e.json == str);
  }
}

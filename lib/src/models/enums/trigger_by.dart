import 'package:collection/collection.dart';

/// Enumeration of supported trigger reasons for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#triggerby).
enum TriggerBy {
  lastPrice("LastPrice"),
  indexPrice("IndexPrice"),
  markPrice("MarkPrice");

  final String json;

  const TriggerBy(this.json);

  /// Allows to get a [TriggerBy] object from API responses
  factory TriggerBy.fromString(String str) {
    return TriggerBy.values.singleWhere((e) => e.json == str);
  }

  /// Allows to get a [TriggerBy] object from API responses that may not contain one
  static TriggerBy? tryFromString(String? str) {
    return TriggerBy.values.singleWhereOrNull((e) => e.json == str);
  }
}

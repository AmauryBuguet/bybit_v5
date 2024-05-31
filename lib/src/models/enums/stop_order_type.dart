import 'package:collection/collection.dart';

/// Enumeration of supported stop order types for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#stopordertype).
enum StopOrderType {
  takeProfit("TakeProfit"),
  stopLoss("StopLoss"),
  trailingStop("TrailingStop"),
  stop("Stop"),
  partialTakeProfit("PartialTakeProfit"),
  partialStopLoss("PartialStopLoss"),
  tpslOrder("tpslOrder"),
  ocoOrder("OcoOrder"),
  mmRateClose("MmRateClose"),
  bidirectionalTpslOrder("BidirectionalTpslOrder");

  final String json;

  const StopOrderType(this.json);

  /// Allows to get a [StopOrderType] object from API responses
  factory StopOrderType.fromString(String str) {
    return StopOrderType.values.singleWhere((e) => e.json == str);
  }

  /// Allows to get a [StopOrderType] object from API responses that may not contain one
  static StopOrderType? tryFromString(String? str) {
    return StopOrderType.values.singleWhereOrNull((e) => e.json == str);
  }
}

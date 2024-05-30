/// Enumeration of supported position index for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#positionidx).
enum PositionIdx {
  oneWay(0),
  hedgeModeBuySide(1),
  hedgeModeSellSide(2);

  final int json;

  const PositionIdx(this.json);

  /// Allows to get a [PositionIdx] object from API responses
  factory PositionIdx.fromInt(int number) {
    return PositionIdx.values.singleWhere((e) => e.json == number);
  }
}

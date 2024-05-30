/// Enumeration of supported market units for queries to the Bybit API.
enum MarketUnit {
  baseCoin,
  sell;

  const MarketUnit();

  /// Allows to get a [MarketUnit] object from API responses
  factory MarketUnit.fromString(String str) {
    return MarketUnit.values.singleWhere((e) => e.name == str);
  }
}

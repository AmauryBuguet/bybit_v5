/// Enumeration of supported sides for queries to the Bybit API.
enum Side {
  buy("Buy"),
  sell("Sell");

  final String json;

  const Side(this.json);

  /// Allows to get a [Side] object from API responses
  factory Side.fromString(String str) {
    return Side.values.singleWhere((e) => e.json == str);
  }
}

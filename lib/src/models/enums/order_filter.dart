/// Enumeration of supported sides for queries to the Bybit API.
enum OrderFilter {
  order("Order"),
  tpslOrder("tpslOrder"),
  stopOrder("StopOrder");

  final String json;

  const OrderFilter(this.json);

  /// Allows to get a [OrderFilter] object from API responses
  factory OrderFilter.fromString(String str) {
    return OrderFilter.values.singleWhere((e) => e.json == str);
  }
}

/// Enumeration of supported time-in-force options for queries to the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/enum#orderstatus).
enum OrderStatus {
  newOrder("New"),
  partiallyFilled("PartiallyFilled"),
  rejected("Rejected"),
  partiallyFilledCanceled("PartiallyFilledCanceled"),
  filled("Filled"),
  cancelled("Cancelled"),
  triggered("Triggered"),
  deactivated("Deactivated"),
  untriggered("Untriggered");

  final String json;

  const OrderStatus(this.json);

  /// Allows to get a [OrderStatus] object from API responses
  factory OrderStatus.fromString(String str) {
    return OrderStatus.values.singleWhere((e) => e.json == str);
  }
}

import '../enums/side.dart';

/// Represents a single trade in the Bybit API response.
class Trade {
  final String execId;
  final String symbol;
  final double price;
  final double size;
  final Side side;
  final int time;
  final bool isBlockTrade;

  /// Creates a Trade object with the provided parameters.
  Trade({
    required this.execId,
    required this.symbol,
    required this.price,
    required this.size,
    required this.side,
    required this.time,
    required this.isBlockTrade,
  });

  /// Creates a Trade object from a map of dynamic values.
  factory Trade.fromMap(Map<String, dynamic> map) {
    return Trade(
      execId: map['execId'],
      symbol: map['symbol'],
      price: double.parse(map['price']),
      size: double.parse(map['size']),
      side: Side.fromString(map['side']),
      time: int.parse(map['time']),
      isBlockTrade: map['isBlockTrade'],
    );
  }
}

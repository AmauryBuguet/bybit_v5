class LongShortRatio {
  final String symbol;
  final double buyRatio;
  final double sellRatio;
  final int timestamp;

  factory LongShortRatio.fromMap(Map<String, dynamic> map) {
    return LongShortRatio(
      symbol: map["symbol"],
      buyRatio: double.parse(map["buyRatio"]),
      sellRatio: double.parse(map["sellRatio"]),
      timestamp: int.parse(map["timestamp"]),
    );
  }

  LongShortRatio({
    required this.symbol,
    required this.buyRatio,
    required this.sellRatio,
    required this.timestamp,
  });
}

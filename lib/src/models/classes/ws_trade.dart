import '../enums/side.dart';

class WsTradeMessage {
  final String topic;
  final String type;
  final int timestamp;
  final List<WsTrade> trades;

  WsTradeMessage({
    required this.topic,
    required this.type,
    required this.timestamp,
    required this.trades,
  });

  factory WsTradeMessage.fromMap(Map<String, dynamic> map) {
    return WsTradeMessage(
      topic: map['topic'],
      type: map['type'],
      timestamp: map['ts'],
      trades: List<WsTrade>.from((map['data'] as List<dynamic>).map((x) => WsTrade.fromMap(x))),
    );
  }
}

class WsTrade {
  final int timestamp;
  final String symbol;
  final Side side;
  final double size;
  final double price;
  final String priceChangeDirection;
  final String tradeId;
  final bool isBlockTrade;
  final double? markPrice;
  final double? indexPrice;
  final double? markIv;
  final double? iv;

  WsTrade({
    required this.timestamp,
    required this.symbol,
    required this.side,
    required this.size,
    required this.price,
    required this.priceChangeDirection,
    required this.tradeId,
    required this.isBlockTrade,
    required this.markPrice,
    required this.indexPrice,
    required this.markIv,
    required this.iv,
  });

  factory WsTrade.fromMap(Map<String, dynamic> map) {
    return WsTrade(
      timestamp: map['T'],
      symbol: map['s'],
      side: Side.fromString(map['S']),
      size: double.parse(map['v']),
      price: double.parse(map['p']),
      priceChangeDirection: map['L'],
      tradeId: map['i'],
      isBlockTrade: map['BT'],
      markPrice: double.tryParse(map['mP'] ?? ""),
      indexPrice: double.tryParse(map['iP'] ?? ""),
      markIv: double.tryParse(map['mIv'] ?? ""),
      iv: double.tryParse(map['iv'] ?? ""),
    );
  }
}

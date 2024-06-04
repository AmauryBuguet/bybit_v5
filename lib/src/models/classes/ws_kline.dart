class WsKlineMessage {
  final String topic;
  final String type;
  final int timestamp;
  final List<WsKline> klines;

  WsKlineMessage({
    required this.topic,
    required this.type,
    required this.timestamp,
    required this.klines,
  });

  factory WsKlineMessage.fromMap(Map<String, dynamic> map) {
    return WsKlineMessage(
      topic: map['topic'],
      type: map['type'],
      timestamp: map['ts'],
      klines: List<WsKline>.from((map['data'] as List<dynamic>).map((x) => WsKline.fromMap(x))),
    );
  }
}

class WsKline {
  final int startTimestamp;
  final int endTimestamp;
  final String interval;
  final double openPrice;
  final double closePrice;
  final double highPrice;
  final double lowPrice;
  final double tradeVolume;
  final double turnover;
  final bool isConfirmed;
  final int lastMatchTimestamp;

  WsKline({
    required this.startTimestamp,
    required this.endTimestamp,
    required this.interval,
    required this.openPrice,
    required this.closePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.tradeVolume,
    required this.turnover,
    required this.isConfirmed,
    required this.lastMatchTimestamp,
  });

  factory WsKline.fromMap(Map<String, dynamic> map) {
    return WsKline(
      startTimestamp: map['start'],
      endTimestamp: map['end'],
      interval: map['interval'],
      openPrice: double.parse(map['open']),
      closePrice: double.parse(map['close']),
      highPrice: double.parse(map['high']),
      lowPrice: double.parse(map['low']),
      tradeVolume: double.parse(map['volume']),
      turnover: double.parse(map['turnover']),
      isConfirmed: map['confirm'],
      lastMatchTimestamp: map['timestamp'],
    );
  }
}

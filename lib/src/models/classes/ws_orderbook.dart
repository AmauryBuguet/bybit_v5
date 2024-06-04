class WsOrderBookMessage {
  final String topic;
  final WsOrderbookMsgType type;
  final int timestamp;
  final int matchEngineTimestamp;
  final WsOrderBook data;

  WsOrderBookMessage({
    required this.topic,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.matchEngineTimestamp,
  });

  factory WsOrderBookMessage.fromMap(Map<String, dynamic> map) {
    return WsOrderBookMessage(
      topic: map['topic'],
      type: WsOrderbookMsgType.fromString(map['type']),
      timestamp: map['ts'],
      matchEngineTimestamp: map['cts'],
      data: WsOrderBook.fromMap(map['data']),
    );
  }
}

class WsOrderBook {
  final String symbolName;
  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final int updateId;
  final int sequence;

  WsOrderBook({
    required this.symbolName,
    required this.bids,
    required this.asks,
    required this.updateId,
    required this.sequence,
  });

  factory WsOrderBook.fromMap(Map<String, dynamic> map) {
    return WsOrderBook(
      symbolName: map['s'],
      bids: List<OrderBookEntry>.from((map['b'] as List<dynamic>).map((x) => OrderBookEntry.fromMap(x))),
      asks: List<OrderBookEntry>.from((map['a'] as List<dynamic>).map((x) => OrderBookEntry.fromMap(x))),
      updateId: map['u'],
      sequence: map['seq'],
    );
  }
}

class OrderBookEntry {
  final double price;
  final double size;

  OrderBookEntry({
    required this.price,
    required this.size,
  });

  factory OrderBookEntry.fromMap(List<dynamic> map) {
    return OrderBookEntry(
      price: double.parse(map[0]),
      size: double.parse(map[1]),
    );
  }
}

enum WsOrderbookMsgType {
  snapshot,
  delta;

  factory WsOrderbookMsgType.fromString(String str) {
    return WsOrderbookMsgType.values.singleWhere((e) => e.name == str);
  }
}

import '../enums/order_type.dart';
import '../enums/side.dart';

class ClosedPnlRecord {
  final String symbol;
  final String orderId;
  final Side side;
  final double qty;
  final double orderPrice;
  final OrderType orderType;
  final String execType;
  final double closedSize;
  final double cumEntryValue;
  final double avgEntryPrice;
  final double cumExitValue;
  final double avgExitPrice;
  final double closedPnl;
  final int fillCount;
  final int leverage;
  final int createdTime;
  final int updatedTime;

  ClosedPnlRecord({
    required this.symbol,
    required this.orderId,
    required this.side,
    required this.qty,
    required this.orderPrice,
    required this.orderType,
    required this.execType,
    required this.closedSize,
    required this.cumEntryValue,
    required this.avgEntryPrice,
    required this.cumExitValue,
    required this.avgExitPrice,
    required this.closedPnl,
    required this.fillCount,
    required this.leverage,
    required this.createdTime,
    required this.updatedTime,
  });

  factory ClosedPnlRecord.fromMap(Map<String, dynamic> map) {
    return ClosedPnlRecord(
      symbol: map['symbol'],
      orderId: map['orderId'],
      side: Side.fromString(map['side']),
      qty: double.parse(map['qty']),
      orderPrice: double.parse(map['orderPrice']),
      orderType: OrderType.fromString(map['orderType']),
      execType: map['execType'],
      closedSize: double.parse(map['closedSize']),
      cumEntryValue: double.parse(map['cumEntryValue']),
      avgEntryPrice: double.parse(map['avgEntryPrice']),
      cumExitValue: double.parse(map['cumExitValue']),
      avgExitPrice: double.parse(map['avgExitPrice']),
      closedPnl: double.parse(map['closedPnl']),
      fillCount: int.parse(map['fillCount']),
      leverage: int.parse(map['leverage']),
      createdTime: int.parse(map['createdTime']),
      updatedTime: int.parse(map['updatedTime']),
    );
  }
}

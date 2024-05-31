import '../enums/order_type.dart';
import '../enums/side.dart';
import '../enums/stop_order_type.dart';

class UserTrade {
  final String symbol;
  final String orderId;
  final String? orderLinkId;
  final Side side;
  final double orderPrice;
  final double orderQty;
  final double? leavesQty;
  final String createType;
  final OrderType orderType;
  final StopOrderType? stopOrderType;
  final double execFee;
  final String execId;
  final double execPrice;
  final double execQty;
  final String? execType;
  final double? execValue;
  final int execTime;
  final String? feeCurrency;
  final bool isMaker;
  final double? feeRate;
  final String? tradeIv;
  final String? markIv;
  final double? markPrice;
  final double? indexPrice;
  final double? underlyingPrice;
  final String blockTradeId;
  final double closedSize;
  final int? seq;

  UserTrade({
    required this.symbol,
    required this.orderId,
    this.orderLinkId,
    required this.side,
    required this.orderPrice,
    required this.orderQty,
    this.leavesQty,
    required this.createType,
    required this.orderType,
    required this.stopOrderType,
    required this.execFee,
    required this.execId,
    required this.execPrice,
    required this.execQty,
    required this.execType,
    required this.execValue,
    required this.execTime,
    required this.feeCurrency,
    required this.isMaker,
    required this.feeRate,
    required this.tradeIv,
    required this.markIv,
    this.markPrice,
    this.indexPrice,
    this.underlyingPrice,
    required this.blockTradeId,
    required this.closedSize,
    this.seq,
  });

  factory UserTrade.fromMap(Map<String, dynamic> map) {
    return UserTrade(
      symbol: map['symbol'] as String,
      orderId: map['orderId'] as String,
      orderLinkId: map['orderLinkId'],
      side: Side.fromString(map['side']),
      orderPrice: double.parse(map['orderPrice']),
      orderQty: double.parse(map['orderQty']),
      leavesQty: double.tryParse(map['leavesQty']),
      createType: map['createType'] as String,
      orderType: OrderType.fromString(map['orderType']),
      stopOrderType: StopOrderType.tryFromString(map['stopOrderType']),
      execFee: double.parse(map['execFee']),
      execId: map['execId'] as String,
      execPrice: double.parse(map['execPrice']),
      execQty: double.parse(map['execQty']),
      execType: map['execType'] as String,
      execValue: double.parse(map['execValue']),
      execTime: int.parse(map['execTime']),
      feeCurrency: map['feeCurrency'],
      isMaker: map['isMaker'] as bool,
      feeRate: double.tryParse(map['feeRate']),
      tradeIv: map['tradeIv'],
      markIv: map['markIv'],
      markPrice: double.tryParse(map['markPrice']),
      indexPrice: double.tryParse(map['indexPrice']),
      underlyingPrice: double.tryParse(map['underlyingPrice']),
      blockTradeId: map['blockTradeId'],
      closedSize: double.parse(map['closedSize']),
      seq: map['seq'],
    );
  }
}

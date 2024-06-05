import 'package:bybit_v5/src/models/enums/category.dart';
import 'package:bybit_v5/src/models/enums/market_unit.dart';
import 'package:bybit_v5/src/models/enums/order_status.dart';
import 'package:bybit_v5/src/models/enums/order_type.dart';
import 'package:bybit_v5/src/models/enums/position_idx.dart';
import 'package:bybit_v5/src/models/enums/side.dart';
import 'package:bybit_v5/src/models/enums/stop_order_type.dart';
import 'package:bybit_v5/src/models/enums/time_in_force.dart';
import 'package:bybit_v5/src/models/enums/tpsl_mode.dart';
import 'package:bybit_v5/src/models/enums/trigger_by.dart';
import 'package:bybit_v5/src/models/enums/trigger_direction.dart';

class WsOrderMessage {
  final String id;
  final String topic;
  final int creationTime;
  final List<OrderData> data;

  WsOrderMessage({
    required this.id,
    required this.topic,
    required this.creationTime,
    required this.data,
  });

  factory WsOrderMessage.fromMap(Map<String, dynamic> map) {
    return WsOrderMessage(
      id: map['id'],
      topic: map['topic'],
      creationTime: map['creationTime'],
      data: List<OrderData>.from(map['data']?.map((x) => OrderData.fromMap(x))),
    );
  }
}

class OrderData {
  final Category category;
  final String orderId;
  final String orderLinkId;
  final bool isLeverage;
  final String blockTradeId;
  final String symbol;
  final double price;
  final double qty;
  final Side side;
  final PositionIdx positionIdx;
  final OrderStatus orderStatus;
  final String? createType;
  final String? cancelType;
  final String? rejectReason;
  final double? avgPrice;
  final double? leavesQty;
  final double? leavesValue;
  final double cumExecQty;
  final double cumExecValue;
  final double cumExecFee;
  final String? feeCurrency;
  final TimeInForce timeInForce;
  final OrderType orderType;
  final StopOrderType? stopOrderType;
  final String? ocoTriggerBy;
  final double? orderIv;
  final MarketUnit? marketUnit;
  final double? triggerPrice;
  final double? takeProfit;
  final double? stopLoss;
  final TpslMode? tpslMode;
  final double? tpLimitPrice;
  final double? slLimitPrice;
  final TriggerBy? tpTriggerBy;
  final TriggerBy? slTriggerBy;
  final TriggerDirection? triggerDirection;
  final TriggerBy? triggerBy;
  final double? lastPriceOnCreated;
  final bool reduceOnly;
  final bool closeOnTrigger;
  final String? placeType;
  final String? smpType;
  final int? smpGroup;
  final String? smpOrderId;
  final int createdTime;
  final int updatedTime;

  OrderData({
    required this.category,
    required this.orderId,
    required this.orderLinkId,
    required this.isLeverage,
    required this.blockTradeId,
    required this.symbol,
    required this.price,
    required this.qty,
    required this.side,
    required this.positionIdx,
    required this.orderStatus,
    this.createType,
    this.cancelType,
    this.rejectReason,
    this.avgPrice,
    this.leavesQty,
    this.leavesValue,
    required this.cumExecQty,
    required this.cumExecValue,
    required this.cumExecFee,
    this.feeCurrency,
    required this.timeInForce,
    required this.orderType,
    this.stopOrderType,
    this.ocoTriggerBy,
    this.orderIv,
    this.marketUnit,
    this.triggerPrice,
    this.takeProfit,
    this.stopLoss,
    this.tpslMode,
    this.tpLimitPrice,
    this.slLimitPrice,
    this.tpTriggerBy,
    this.slTriggerBy,
    required this.triggerDirection,
    this.triggerBy,
    this.lastPriceOnCreated,
    required this.reduceOnly,
    required this.closeOnTrigger,
    this.placeType,
    this.smpType,
    this.smpGroup,
    this.smpOrderId,
    required this.createdTime,
    required this.updatedTime,
  });

  factory OrderData.fromMap(Map<String, dynamic> map) {
    return OrderData(
      category: Category.fromString(map['category']),
      orderId: map['orderId'],
      orderLinkId: map['orderLinkId'],
      isLeverage: map['isLeverage'] == "1",
      blockTradeId: map['blockTradeId'] ?? '',
      symbol: map['symbol'],
      price: double.parse(map['price']),
      qty: double.parse(map['qty']),
      side: Side.fromString(map['side']),
      positionIdx: PositionIdx.fromInt(map['positionIdx']),
      orderStatus: OrderStatus.fromString(map['orderStatus']),
      createType: map['createType'],
      cancelType: map['cancelType'],
      rejectReason: map['rejectReason'],
      avgPrice: double.tryParse(map['avgPrice']),
      leavesQty: double.tryParse(map['leavesQty'] ?? ""),
      leavesValue: double.tryParse(map['leavesValue'] ?? ""),
      cumExecQty: double.parse(map['cumExecQty']),
      cumExecValue: double.parse(map['cumExecValue']),
      cumExecFee: double.parse(map['cumExecFee']),
      feeCurrency: map['feeCurrency'],
      timeInForce: TimeInForce.fromString(map['timeInForce']),
      orderType: OrderType.fromString(map['orderType']),
      stopOrderType: StopOrderType.tryFromString(map['stopOrderType']),
      ocoTriggerBy: map['ocoTriggerBy'],
      orderIv: double.tryParse(map['orderIv']),
      marketUnit: MarketUnit.tryFromString(map['marketUnit']),
      triggerPrice: double.tryParse(map['triggerPrice']),
      takeProfit: double.tryParse(map['takeProfit']),
      stopLoss: double.tryParse(map['stopLoss']),
      tpslMode: TpslMode.tryFromString(map['tpslMode']),
      tpLimitPrice: double.tryParse(map['tpLimitPrice']),
      slLimitPrice: double.tryParse(map['slLimitPrice']),
      tpTriggerBy: TriggerBy.tryFromString(map['tpTriggerBy']),
      slTriggerBy: TriggerBy.tryFromString(map['slTriggerBy']),
      triggerDirection: TriggerDirection.tryFromInt(map['triggerDirection']),
      triggerBy: TriggerBy.tryFromString(map['triggerBy']),
      lastPriceOnCreated: double.tryParse(map['lastPriceOnCreated']),
      reduceOnly: map['reduceOnly'],
      closeOnTrigger: map['closeOnTrigger'],
      placeType: map['placeType'],
      smpType: map['smpType'],
      smpGroup: map['smpGroup'],
      smpOrderId: map['smpOrderId'],
      createdTime: int.parse(map['createdTime']),
      updatedTime: int.parse(map['updatedTime']),
    );
  }
}

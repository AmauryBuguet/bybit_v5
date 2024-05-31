import '../enums/market_unit.dart';
import '../enums/order_status.dart';
import '../enums/order_type.dart';
import '../enums/position_idx.dart';
import '../enums/side.dart';
import '../enums/stop_order_type.dart';
import '../enums/time_in_force.dart';
import '../enums/tpsl_mode.dart';
import '../enums/trigger_by.dart';
import '../enums/trigger_direction.dart';

class Order {
  final String orderId;
  final String? orderLinkId;
  final String? blockTradeId;
  final String symbol;
  final double price;
  final double qty;
  final Side side;
  final String? isLeverage;
  final PositionIdx positionIdx;
  final OrderStatus orderStatus;
  final String? createType;
  final String? cancelType;
  final String? rejectReason;
  final double? avgPrice;
  final double? leavesQty;
  final double? leavesValue;
  final double cumExecQty;
  final double? cumExecValue;
  final double? cumExecFee;
  final TimeInForce timeInForce;
  final OrderType orderType;
  final StopOrderType? stopOrderType;
  final double? orderIv;
  final MarketUnit? marketUnit;
  final double? triggerPrice;
  final double? takeProfit;
  final double? stopLoss;
  final TpslMode? tpslMode;
  final String? ocoTriggerBy;
  final double? tpLimitPrice;
  final double? slLimitPrice;
  final TriggerBy? tpTriggerBy;
  final TriggerBy? slTriggerBy;
  final TriggerDirection? triggerDirection;
  final TriggerBy? triggerBy;
  final double lastPriceOnCreated;
  final bool reduceOnly;
  final bool closeOnTrigger;
  final String? placeType;
  final String? smpType;
  final int? smpGroup;
  final String? smpOrderId;
  final int createdTime;
  final int updatedTime;

  Order({
    required this.orderId,
    required this.orderLinkId,
    required this.blockTradeId,
    required this.symbol,
    required this.price,
    required this.qty,
    required this.side,
    required this.isLeverage,
    required this.positionIdx,
    required this.orderStatus,
    required this.createType,
    required this.cancelType,
    required this.rejectReason,
    required this.avgPrice,
    required this.leavesQty,
    required this.leavesValue,
    required this.cumExecQty,
    required this.cumExecValue,
    required this.cumExecFee,
    required this.timeInForce,
    required this.orderType,
    required this.stopOrderType,
    required this.orderIv,
    required this.marketUnit,
    required this.triggerPrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.tpslMode,
    required this.ocoTriggerBy,
    required this.tpLimitPrice,
    required this.slLimitPrice,
    required this.tpTriggerBy,
    required this.slTriggerBy,
    required this.triggerDirection,
    required this.triggerBy,
    required this.lastPriceOnCreated,
    required this.reduceOnly,
    required this.closeOnTrigger,
    required this.placeType,
    required this.smpType,
    required this.smpGroup,
    required this.smpOrderId,
    required this.createdTime,
    required this.updatedTime,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'],
      orderLinkId: map['orderLinkId'],
      blockTradeId: map['blockTradeId'],
      symbol: map['symbol'],
      price: double.tryParse(map['price']) ?? 0.0,
      qty: double.tryParse(map['qty']) ?? 0.0,
      side: Side.fromString(map['side']),
      isLeverage: map['isLeverage'],
      positionIdx: PositionIdx.fromInt(map['positionIdx']),
      orderStatus: OrderStatus.fromString(map['orderStatus']),
      createType: map['createType'],
      cancelType: map['cancelType'],
      rejectReason: map['rejectReason'],
      avgPrice: double.tryParse(map['avgPrice']),
      leavesQty: double.tryParse(map['leavesQty']),
      leavesValue: double.tryParse(map['leavesValue']),
      cumExecQty: double.tryParse(map['cumExecQty']) ?? 0.0,
      cumExecValue: double.tryParse(map['cumExecValue']),
      cumExecFee: double.tryParse(map['cumExecFee']),
      timeInForce: TimeInForce.fromString(map['timeInForce']),
      orderType: OrderType.fromString(map['orderType']),
      stopOrderType: StopOrderType.tryFromString(map['stopOrderType']),
      orderIv: double.tryParse(map['orderIv']),
      marketUnit: MarketUnit.tryFromString(map['marketUnit']),
      triggerPrice: double.tryParse(map['triggerPrice']),
      takeProfit: double.tryParse(map['takeProfit']),
      stopLoss: double.tryParse(map['stopLoss']),
      tpslMode: TpslMode.tryFromString(map['tpslMode']),
      ocoTriggerBy: map['ocoTriggerBy'],
      tpLimitPrice: double.tryParse(map['tpLimitPrice']),
      slLimitPrice: double.tryParse(map['slLimitPrice']),
      tpTriggerBy: TriggerBy.tryFromString(map['tpTriggerBy']),
      slTriggerBy: TriggerBy.tryFromString(map['slTriggerBy']),
      triggerDirection: TriggerDirection.tryFromInt(map['triggerDirection']),
      triggerBy: TriggerBy.tryFromString(map['triggerBy']),
      lastPriceOnCreated: double.tryParse(map['lastPriceOnCreated']) ?? 0.0,
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

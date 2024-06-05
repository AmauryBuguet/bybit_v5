import 'package:bybit_v5/src/models/enums/category.dart';
import 'package:bybit_v5/src/models/enums/position_idx.dart';
import 'package:bybit_v5/src/models/enums/side.dart';

class WsPositionMessage {
  final String id;
  final String topic;
  final int creationTime;
  final List<PositionData> data;

  WsPositionMessage({
    required this.id,
    required this.topic,
    required this.creationTime,
    required this.data,
  });

  factory WsPositionMessage.fromMap(Map<String, dynamic> map) {
    return WsPositionMessage(
      id: map['id'],
      topic: map['topic'],
      creationTime: map['creationTime'],
      data: List<PositionData>.from(map['data']?.map((x) => PositionData.fromMap(x))),
    );
  }
}

class PositionData {
  final Category category;
  final String symbol;
  final Side? side;
  final double size;
  final PositionIdx positionIdx;
  final int tradeMode;
  final double positionValue;
  final int riskId;
  final double riskLimitValue;
  final double entryPrice;
  final double markPrice;
  final double? leverage;
  final double? positionBalance;
  final int autoAddMargin;
  final double? positionMM;
  final double? positionIM;
  final double? liqPrice;
  final double? bustPrice;
  final double takeProfit;
  final double stopLoss;
  final double trailingStop;
  final double unrealisedPnl;
  final double curRealisedPnl;
  final double? sessionAvgPrice;
  final double? delta;
  final double? gamma;
  final double? vega;
  final double? theta;
  final double cumRealisedPnl;
  final String positionStatus;
  final int? adlRankIndicator;
  final bool? isReduceOnly;
  final int? mmrSysUpdatedTime;
  final int? leverageSysUpdatedTime;
  final int createdTime;
  final int updatedTime;
  final int seq;

  PositionData({
    required this.category,
    required this.symbol,
    required this.side,
    required this.size,
    required this.positionIdx,
    required this.tradeMode,
    required this.positionValue,
    required this.riskId,
    required this.riskLimitValue,
    required this.entryPrice,
    required this.markPrice,
    required this.leverage,
    required this.positionBalance,
    required this.autoAddMargin,
    required this.positionMM,
    required this.positionIM,
    required this.liqPrice,
    required this.bustPrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.trailingStop,
    required this.unrealisedPnl,
    required this.curRealisedPnl,
    required this.sessionAvgPrice,
    required this.delta,
    required this.gamma,
    required this.vega,
    required this.theta,
    required this.cumRealisedPnl,
    required this.positionStatus,
    required this.adlRankIndicator,
    required this.isReduceOnly,
    required this.mmrSysUpdatedTime,
    required this.leverageSysUpdatedTime,
    required this.createdTime,
    required this.updatedTime,
    required this.seq,
  });

  factory PositionData.fromMap(Map<String, dynamic> map) {
    return PositionData(
      category: Category.fromString(map['category']),
      symbol: map['symbol'],
      side: Side.tryFromString(map['side']),
      size: double.parse(map['size']),
      positionIdx: PositionIdx.fromInt(map['positionIdx']),
      tradeMode: map['tradeMode'],
      positionValue: double.parse(map['positionValue']),
      riskId: map['riskId'],
      riskLimitValue: double.parse(map['riskLimitValue'] ?? '0'),
      entryPrice: double.parse(map['entryPrice']),
      markPrice: double.parse(map['markPrice']),
      leverage: double.tryParse(map['leverage']),
      positionBalance: double.tryParse(map['positionBalance']),
      autoAddMargin: map['autoAddMargin'],
      positionMM: double.tryParse(map['positionMM']),
      positionIM: double.tryParse(map['positionIM']),
      liqPrice: double.tryParse(map['liqPrice']),
      bustPrice: double.tryParse(map['bustPrice']),
      takeProfit: double.parse(map['takeProfit'] ?? '0'),
      stopLoss: double.parse(map['stopLoss'] ?? '0'),
      trailingStop: double.parse(map['trailingStop'] ?? '0'),
      unrealisedPnl: double.parse(map['unrealisedPnl']),
      curRealisedPnl: double.parse(map['curRealisedPnl']),
      sessionAvgPrice: double.tryParse(map['sessionAvgPrice'] ?? ""),
      delta: double.tryParse(map['delta'] ?? ""),
      gamma: double.tryParse(map['gamma'] ?? ""),
      vega: double.tryParse(map['vega'] ?? ""),
      theta: double.tryParse(map['theta'] ?? ""),
      cumRealisedPnl: double.parse(map['cumRealisedPnl']),
      positionStatus: map['positionStatus'],
      adlRankIndicator: map['adlRankIndicator'],
      isReduceOnly: map['isReduceOnly'],
      mmrSysUpdatedTime: int.tryParse(map['mmrSysUpdatedTime'] ?? ""),
      leverageSysUpdatedTime: int.tryParse(map['leverageSysUpdatedTime'] ?? ""),
      createdTime: int.parse(map['createdTime']),
      updatedTime: int.parse(map['updatedTime']),
      seq: map['seq'],
    );
  }
}

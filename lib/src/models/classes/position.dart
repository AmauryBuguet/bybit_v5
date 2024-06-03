import '../enums/position_idx.dart';
import '../enums/side.dart';
import '../enums/tpsl_mode.dart';

class Position {
  final PositionIdx positionIdx;
  final int riskId;
  final String riskLimitValue;
  final String symbol;
  final Side? side;
  final double size;
  final double avgPrice;
  final double positionValue;
  final int tradeMode;
  final String positionStatus;
  final int autoAddMargin;
  final int adlRankIndicator;
  final int? leverage;
  final double positionBalance;
  final double markPrice;
  final double? liqPrice;
  final double? bustPrice;
  final double? positionMM;
  final double? positionIM;
  final TpslMode? tpslMode;
  final double? takeProfit;
  final double? stopLoss;
  final double? trailingStop;
  final double unrealisedPnl;
  final double curRealisedPnl;
  final double cumRealisedPnl;
  final int seq;
  final bool isReduceOnly;
  final int? mmrSysUpdatedTime;
  final int? leverageSysUpdatedTime;
  final int createdTime;
  final int updatedTime;

  Position({
    required this.positionIdx,
    required this.riskId,
    required this.riskLimitValue,
    required this.symbol,
    required this.side,
    required this.size,
    required this.avgPrice,
    required this.positionValue,
    required this.tradeMode,
    required this.positionStatus,
    required this.autoAddMargin,
    required this.adlRankIndicator,
    required this.leverage,
    required this.positionBalance,
    required this.markPrice,
    required this.liqPrice,
    required this.bustPrice,
    required this.positionMM,
    required this.positionIM,
    required this.tpslMode,
    required this.takeProfit,
    required this.stopLoss,
    required this.trailingStop,
    required this.unrealisedPnl,
    required this.curRealisedPnl,
    required this.cumRealisedPnl,
    required this.seq,
    required this.isReduceOnly,
    required this.mmrSysUpdatedTime,
    required this.leverageSysUpdatedTime,
    required this.createdTime,
    required this.updatedTime,
  });

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      positionIdx: PositionIdx.fromInt(map['positionIdx']),
      riskId: map['riskId'] as int,
      riskLimitValue: map['riskLimitValue'] as String,
      symbol: map['symbol'] as String,
      side: Side.tryFromString(map['side']),
      size: double.tryParse(map['size']) ?? 0.0,
      avgPrice: double.tryParse(map['avgPrice']) ?? 0.0,
      positionValue: double.tryParse(map['positionValue']) ?? 0.0,
      tradeMode: map['tradeMode'] as int,
      positionStatus: map['positionStatus'] as String,
      autoAddMargin: map['autoAddMargin'] as int,
      adlRankIndicator: map['adlRankIndicator'] as int,
      leverage: int.tryParse(map['leverage']),
      positionBalance: double.parse(map['positionBalance']),
      markPrice: double.parse(map['markPrice']),
      liqPrice: double.tryParse(map['liqPrice']),
      bustPrice: double.tryParse(map['bustPrice']),
      positionMM: double.tryParse(map['positionMM']),
      positionIM: double.tryParse(map['positionIM']),
      tpslMode: TpslMode.tryFromString(map['tpslMode']),
      takeProfit: double.tryParse(map['takeProfit']),
      stopLoss: double.tryParse(map['stopLoss']),
      trailingStop: double.tryParse(map['trailingStop']),
      unrealisedPnl: double.parse(map['unrealisedPnl']),
      curRealisedPnl: double.parse(map['curRealisedPnl']),
      cumRealisedPnl: double.parse(map['cumRealisedPnl']),
      seq: map['seq'] as int,
      isReduceOnly: map['isReduceOnly'] as bool,
      mmrSysUpdatedTime: int.tryParse(map['mmrSysUpdatedTime']),
      leverageSysUpdatedTime: int.tryParse(map['leverageSysUpdatedTime']),
      createdTime: int.parse(map['createdTime']),
      updatedTime: int.parse(map['updatedTime']),
    );
  }
}

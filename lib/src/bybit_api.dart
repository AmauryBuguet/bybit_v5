import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../bybit_v5.dart';

/// A class to interact with the Bybit API.
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/intro).
///
/// Use the `BybitApi.authenticated` constructor when performing
/// actions that require authentication, such as placing orders.
class BybitApi {
  /// The base URL for the Bybit API.
  static const String baseUrl = "api.bybit.com";

  /// Indicates if the instance is authenticated.
  final bool isAuthenticated;

  /// The API key for authenticated requests.
  final String? apiKey;

  /// The API secret for authenticated requests.
  final String? apiSecret;

  /// Creates a non-authenticated instance of the Bybit API client.
  BybitApi()
      : isAuthenticated = false,
        apiKey = null,
        apiSecret = null;

  /// Creates an authenticated instance of the Bybit API client.
  ///
  /// The [apiKey] and [apiSecret] are required for authenticated API calls.
  BybitApi.authenticated({required this.apiKey, required this.apiSecret}) : isAuthenticated = true;

  /// Generate headers for signed requests
  Map<String, String> _generateHeaders(String recvWindow, String body) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String signaturePayload = apiKey! + timestamp + recvWindow + body;
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret!));
    final signature = hmacSha256.convert(utf8.encode(signaturePayload)).toString();

    return {
      'Content-Type': 'application/json',
      'X-BAPI-SIGN': signature,
      'X-BAPI-API-KEY': apiKey!,
      'X-BAPI-TIMESTAMP': timestamp,
      'X-BAPI-RECV-WINDOW': recvWindow,
    };
  }

  /// Fetches the server time from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// Returns the server time as a DateTime object using the `timeNano` parameter.
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/time).
  Future<DateTime> getServerTime() async {
    final uri = Uri.https(baseUrl, '/v5/market/time');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int timeNano = int.parse(data['result']['timeNano']);
      final int microseconds = timeNano ~/ Duration.microsecondsPerSecond;
      return DateTime.fromMicrosecondsSinceEpoch(microseconds);
    } else {
      throw Exception('Failed to get server time, code : ${response.statusCode}');
    }
  }

  /// Fetches the server time from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// The [Category] can be [Category.spot], [Category.linear] or [Category.inverse], it default to [Category.linear].
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/kline).
  Future<List<Kline>> getKlines({
    required String symbol,
    required TimeInterval interval,
    Category? category,
    int? start,
    int? end,
    int? limit,
  }) async {
    final queryParams = {
      'symbol': symbol.toUpperCase(),
      'interval': interval.json,
      if (category != null) 'category': category.name,
      if (start != null) 'start': start.toString(),
      if (end != null) 'end': end.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final uri = Uri.https(baseUrl, '/v5/market/kline', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> klineList = data['result']['list'];
      return klineList.map((klineData) => Kline.fromList(klineData)).toList();
    } else {
      throw Exception('Failed to fetch klines, code ${response.statusCode}');
    }
  }

  /// Fetches recent public trading data from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// Parameters [baseCoin] and [optionType] are needed only when [category] is [Category.option].
  ///
  /// Max and default [limit] is 60 when [category] is [Category.option], else default is 500 and max is 1000.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/recent-trade).
  Future<List<Trade>> getPublicRecentTrades({
    required Category category,
    String? symbol,
    String? baseCoin,
    OptionType? optionType,
    int? limit,
  }) async {
    final queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol.toUpperCase(),
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (optionType != null) 'optionType': optionType.name,
      if (limit != null) 'limit': limit.toString(),
    };

    final uri = Uri.https(baseUrl, '/v5/market/recent-trade', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> tradeList = data['result']['list'];
      return tradeList.map((tradeData) => Trade.fromMap(tradeData)).toList();
    } else {
      throw Exception('Failed to fetch recent trades, code ${response.statusCode}');
    }
  }

  /// This endpoint supports to create the order for spot, spot margin, USDT perpetual, USDC perpetual, USDC futures, inverse futures and options.
  ///
  /// This method requires authentication.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/create-order).
  Future<String> placeOrder({
    required Category category,
    required String symbol,
    required Side side,
    required OrderType orderType,
    required String qty,
    bool? isLeverage,
    MarketUnit? marketUnit,
    String? price,
    TriggerDirection? triggerDirection,
    OrderFilter? orderFilter,
    String? triggerPrice,
    TriggerBy? triggerBy,
    TimeInForce? timeInForce,
    PositionIdx? positionIdx,
    String? orderLinkId,
    String? takeProfit,
    String? stopLoss,
    TriggerBy? tpTriggerBy,
    TriggerBy? slTriggerBy,
    bool? reduceOnly,
    bool? closeOnTrigger,
    TpslMode? tpslMode,
    String? tpLimitPrice,
    String? slLimitPrice,
    OrderType? tpOrderType,
    OrderType? slOrderType,
  }) async {
    if (!isAuthenticated) {
      throw Exception("Authentication required to place an order.");
    }
    final uri = Uri.parse('$baseUrl/v5/order/create');

    final recvWindow = '5000';

    final body = {
      'category': category,
      'symbol': symbol,
      'side': side,
      'orderType': orderType,
      'qty': qty,
      if (isLeverage != null) 'isLeverage': isLeverage,
      if (marketUnit != null) 'marketUnit': marketUnit.name,
      if (price != null) 'price': price,
      if (triggerDirection != null) 'triggerDirection': triggerDirection.json,
      if (orderFilter != null) 'orderFilter': orderFilter.json,
      if (triggerPrice != null) 'triggerPrice': triggerPrice,
      if (triggerBy != null) 'triggerBy': triggerBy.json,
      if (timeInForce != null) 'timeInForce': timeInForce.json,
      if (positionIdx != null) 'positionIdx': positionIdx.json,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (takeProfit != null) 'takeProfit': takeProfit,
      if (stopLoss != null) 'stopLoss': stopLoss,
      if (tpTriggerBy != null) 'tpTriggerBy': tpTriggerBy.json,
      if (slTriggerBy != null) 'slTriggerBy': slTriggerBy.json,
      if (reduceOnly != null) 'reduceOnly': reduceOnly,
      if (closeOnTrigger != null) 'closeOnTrigger': closeOnTrigger,
      if (tpslMode != null) 'tpslMode': tpslMode.json,
      if (tpLimitPrice != null) 'tpLimitPrice': tpLimitPrice,
      if (slLimitPrice != null) 'slLimitPrice': slLimitPrice,
      if (tpOrderType != null) 'tpOrderType': tpOrderType.json,
      if (slOrderType != null) 'slOrderType': slOrderType.json,
    };

    final headers = _generateHeaders(recvWindow, json.encode(body));

    final response = await http.post(uri, headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      return json.decode(response.body)["orderId"];
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }
}

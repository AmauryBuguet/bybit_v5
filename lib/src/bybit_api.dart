import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'models/classes/cancel_all_response.dart';
import 'models/classes/get_orders_response.dart';
import 'models/classes/get_trades_response.dart';
import 'models/classes/kline.dart';
import 'models/classes/order_ids.dart';
import 'models/classes/trade.dart';
import 'models/enums/category.dart';
import 'models/enums/market_unit.dart';
import 'models/enums/option_type.dart';
import 'models/enums/order_filter.dart';
import 'models/enums/order_status.dart';
import 'models/enums/order_type.dart';
import 'models/enums/position_idx.dart';
import 'models/enums/request_type.dart';
import 'models/enums/side.dart';
import 'models/enums/stop_order_type.dart';
import 'models/enums/time_in_force.dart';
import 'models/enums/time_interval.dart';
import 'models/enums/tpsl_mode.dart';
import 'models/enums/trigger_by.dart';
import 'models/enums/trigger_direction.dart';

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

  /// The order reception time windpw
  final int recvWindow;

  /// The API key for authenticated requests.
  final String? apiKey;

  /// The API secret for authenticated requests.
  final String? apiSecret;

  /// Creates a non-authenticated instance of the Bybit API client.
  BybitApi({this.recvWindow = 5000})
      : isAuthenticated = false,
        apiKey = null,
        apiSecret = null;

  /// Creates an authenticated instance of the Bybit API client.
  ///
  /// The [apiKey] and [apiSecret] are required for authenticated API calls.
  BybitApi.authenticated({required this.apiKey, required this.apiSecret, this.recvWindow = 5000}) : isAuthenticated = true;

  /// Helper function to sign if needed and send requests to Bybit API
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/guide).
  Future<dynamic> _sendRequest(
    String path, {
    Map<String, dynamic>? body,
    RequestType requestType = RequestType.getRequest,
    bool signed = false,
  }) async {
    // generate headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (signed) {
      if (!isAuthenticated) {
        throw Exception("Authentication required to perform this action.");
      }
      String payload = "";
      if (body != null && body.isNotEmpty) {
        if (requestType == RequestType.getRequest) {
          for (final p in body.entries) {
            payload += "&${p.key}=${p.value}";
          }
          payload = payload.replaceFirst("&", "");
        } else {
          payload = jsonEncode(body);
        }
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String signaturePayload = timestamp + apiKey! + recvWindow.toString() + payload;
      final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret!));
      final signature = hmacSha256.convert(utf8.encode(signaturePayload)).toString();
      headers['X-BAPI-API-KEY'] = apiKey!;
      headers['X-BAPI-SIGN'] = signature;
      headers['X-BAPI-SIGN-TYPE'] = '2';
      headers['X-BAPI-TIMESTAMP'] = timestamp.toString();
      headers['X-BAPI-RECV-WINDOW'] = recvWindow.toString();
    }

    // Send request
    late final http.Response response;
    if (requestType == RequestType.postRequest) {
      response = await http.post(
        Uri.https(baseUrl, path),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await http.get(
        Uri.https(baseUrl, path, body),
        headers: headers,
      );
    }

    // Parse response
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse["retCode"] == 0 && jsonResponse["retMsg"] == "OK") {
        return jsonResponse["result"];
      } else {
        throw Exception('Request failed, retCode ${jsonResponse["retCode"]}, retMsg ${jsonResponse["retMsg"]}');
      }
    } else {
      throw Exception('Request failed with error code: ${response.statusCode}');
    }
  }

  /// Fetches the server time from the Bybit API.
  ///
  /// This method does not require authentication.
  ///
  /// Returns the server time as a DateTime object using the `timeNano` parameter.
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/time).
  Future<DateTime> getServerTime() async {
    final response = await _sendRequest('/v5/market/time');
    final int timeNano = int.parse(response['timeNano']);
    final int microseconds = timeNano ~/ 1000;
    return DateTime.fromMicrosecondsSinceEpoch(microseconds);
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

    final response = await _sendRequest('/v5/market/kline', body: queryParams);
    final List<dynamic> klineList = response['list'];
    return klineList.map((klineData) => Kline.fromList(klineData)).toList();
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

    final response = await _sendRequest('/v5/market/recent-trade', body: queryParams);
    final List<dynamic> tradeList = response['list'];
    return tradeList.map((tradeData) => Trade.fromMap(tradeData)).toList();
  }

  /// This endpoint supports to create the order for spot, spot margin, USDT perpetual, USDC perpetual, USDC futures, inverse futures and options.
  ///
  /// This method requires authentication.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/create-order).
  Future<OrderIds> placeOrder({
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
    final body = {
      'category': category.name,
      'symbol': symbol,
      'side': side.json,
      'orderType': orderType.json,
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

    final response = await _sendRequest('/v5/order/create', body: body, requestType: RequestType.postRequest, signed: true);
    return OrderIds.fromJson(response);
  }

  /// This endpoint allows to edit orders.
  ///
  /// This method requires authentication.
  ///
  /// One of [orderId] or [orderLinkId] is required.
  ///
  /// You can only modify unfilled or partially filled orders.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/amend-order).
  Future<OrderIds> amendOrder({
    required Category category,
    required String symbol,
    String? orderId,
    String? orderLinkId,
    String? triggerPrice,
    String? qty,
    String? price,
    TpslMode? tpslMode,
    String? takeProfit,
    String? stopLoss,
    TriggerBy? tpTriggerBy,
    TriggerBy? slTriggerBy,
    TriggerBy? triggerBy,
    String? tpLimitPrice,
    String? slLimitPrice,
  }) async {
    final body = {
      'category': category.name,
      'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (triggerPrice != null) 'triggerPrice': triggerPrice,
      if (qty != null) 'qty': qty,
      if (price != null) 'price': price,
      if (tpslMode != null) 'tpslMode': tpslMode.json,
      if (takeProfit != null) 'takeProfit': takeProfit,
      if (stopLoss != null) 'stopLoss': stopLoss,
      if (tpTriggerBy != null) 'tpTriggerBy': tpTriggerBy.json,
      if (slTriggerBy != null) 'slTriggerBy': slTriggerBy.json,
      if (triggerBy != null) 'triggerBy': triggerBy.json,
      if (tpLimitPrice != null) 'tpLimitPrice': tpLimitPrice,
      if (slLimitPrice != null) 'slLimitPrice': slLimitPrice,
    };

    final response = await _sendRequest('/v5/order/amend', body: body, requestType: RequestType.postRequest, signed: true);
    return OrderIds.fromJson(response);
  }

  /// This endpoint allows to cancel orders.
  ///
  /// This method requires authentication.
  ///
  /// One of [orderId] or [orderLinkId] is required.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/cancel-order).
  Future<OrderIds> cancelOrder({
    required Category category,
    required String symbol,
    String? orderId,
    String? orderLinkId,
    OrderFilter? orderFilter,
  }) async {
    final body = {
      'category': category.name,
      'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (orderFilter != null) 'orderFilter': orderFilter.json,
    };

    final response = await _sendRequest('/v5/order/cancel', body: body, requestType: RequestType.postRequest, signed: true);
    return OrderIds.fromJson(response);
  }

  /// This endpoint allows to query open and closed orders.
  ///
  /// This method requires authentication.
  ///
  /// One on [symbol], [baseCoin] or [settleCoin] is required.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/open-order).
  Future<GetOrdersResponse> getOrders({
    required Category category,
    String? symbol,
    String? baseCoin,
    String? settleCoin,
    String? orderId,
    String? orderLinkId,
    int? openOnly,
    OrderFilter? orderFilter,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> params = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (settleCoin != null) 'settleCoin': settleCoin,
      if (orderId != null) 'orderId': orderId,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (openOnly != null) 'openOnly': openOnly.toString(),
      if (orderFilter != null) 'orderFilter': orderFilter.json,
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/order/realtime', body: params, signed: true);
    return GetOrdersResponse.fromMap(response);
  }

  /// This endpoint allows to close all active orders.
  ///
  /// This method requires authentication.
  ///
  /// One on [symbol], [baseCoin] or [settleCoin] is required.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/cancel-all).
  Future<CancelAllResponse> cancelAllOrders({
    required Category category,
    String? symbol,
    String? baseCoin,
    String? settleCoin,
    OrderFilter? orderFilter,
    StopOrderType? stopOrderType,
  }) async {
    final Map<String, dynamic> body = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (settleCoin != null) 'settleCoin': settleCoin,
      if (orderFilter != null) 'orderFilter': orderFilter.json,
      if (stopOrderType != null) 'stopOrderType': stopOrderType.json,
    };

    final response = await _sendRequest('/v5/order/cancel-all', body: body, signed: true, requestType: RequestType.postRequest);
    return CancelAllResponse.fromMap(response);
  }

  /// This endpoint allows to query order history over 2 years.
  ///
  /// This method requires authentication.
  ///
  /// You can query by [symbol], [baseCoin], [orderId] and [orderLinkId]
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/order-list).
  Future<GetOrdersResponse> getOrderHistory({
    required Category category,
    String? symbol,
    String? baseCoin,
    String? settleCoin,
    String? orderId,
    String? orderLinkId,
    OrderFilter? orderFilter,
    OrderStatus? orderStatus,
    int? startTime,
    int? endTime,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (settleCoin != null) 'settleCoin': settleCoin,
      if (orderId != null) 'orderId': orderId,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (orderFilter != null) 'orderFilter': orderFilter.json,
      if (orderStatus != null) 'orderStatus': orderStatus.json,
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/order/history', body: queryParams, signed: true);
    return GetOrdersResponse.fromMap(response);
  }

  /// This endpoint allows to query users' execution records.
  ///
  /// This method requires authentication.
  ///
  /// You can query by [symbol], [orderId], [orderLinkId], and [baseCoin].
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/order/execution).
  Future<GetTradesResponse> getTradeHistory({
    required Category category,
    String? symbol,
    String? orderId,
    String? orderLinkId,
    String? baseCoin,
    int? startTime,
    int? endTime,
    String? execType,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (orderLinkId != null) 'orderLinkId': orderLinkId,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
      if (execType != null) 'execType': execType,
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/execution/list', body: queryParams, signed: true);
    return GetTradesResponse.fromMap(response);
  }
}

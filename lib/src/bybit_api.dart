import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

import 'models/classes/cancel_all_response.dart';
import 'models/classes/closed_pnl_response.dart';
import 'models/classes/fee_rate.dart';
import 'models/classes/instruments_response.dart';
import 'models/classes/kline.dart';
import 'models/classes/long_short_ratio.dart';
import 'models/classes/open_interest.dart';
import 'models/classes/order_ids.dart';
import 'models/classes/orders_list_response.dart';
import 'models/classes/position_list_response.dart';
import 'models/classes/subscription.dart';
import 'models/classes/ticker_info.dart';
import 'models/classes/trade.dart';
import 'models/classes/trade_list_response.dart';
import 'models/classes/wallet_balance.dart';
import 'models/classes/ws_kline.dart';
import 'models/classes/ws_order.dart';
import 'models/classes/ws_orderbook.dart';
import 'models/classes/ws_position.dart';
import 'models/classes/ws_trade.dart';
import 'models/classes/ws_wallet.dart';
import 'models/enums/account_type.dart';
import 'models/enums/category.dart';
import 'models/enums/connect_status.dart';
import 'models/enums/instrument_status.dart';
import 'models/enums/interval_time.dart';
import 'models/enums/market_unit.dart';
import 'models/enums/option_type.dart';
import 'models/enums/order_filter.dart';
import 'models/enums/order_status.dart';
import 'models/enums/order_type.dart';
import 'models/enums/orderbook_depth.dart';
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
  static const String _baseUrl = "api.bybit.com";

  /// The base URL for Bybit public websocket streams.
  static const String _basePublicWsUrl = "wss://stream.bybit.com/v5/public/";

  /// Current ws endpoint used
  String? _currWsUrl;

  /// timer for ping packets
  Timer? _timer;

  /// stream controller that can be listened to more than once
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// channel object to handle stages of ws connection
  IOWebSocketChannel? _wsChannel;

  /// list of currently subscribed topics
  final List<String> _topics = [];

  /// list of topics whose subscription has not been confirmed yet
  final List<String> _pendingTopics = [];

  /// Indicates if the websocket connection has been made already
  ConnectStatus _connectStatus = ConnectStatus.disconnected;

  /// Indicates if the instance is authenticated.
  final bool isAuthenticated;

  /// The order reception time window
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

  /// Ping packet as specified in bybit API docs
  ///
  /// Must be sent every 20 seconds
  void _sendPing(Timer timer) {
    final Map<String, dynamic> obj = {"op": "ping"};
    _wsChannel!.sink.add(jsonEncode(obj));
  }

  /// Creates an authenticated instance of the Bybit API client.
  ///
  /// The [apiKey] and [apiSecret] are required for authenticated API calls.
  BybitApi.authenticated({required this.apiKey, required this.apiSecret, this.recvWindow = 5000}) : isAuthenticated = true;

  Future<void> _wsConnect(String url, {bool signed = false}) async {
    _currWsUrl = url;
    _connectStatus = ConnectStatus.connecting;
    log("connecting to ws endpoint $url");
    try {
      _wsChannel = IOWebSocketChannel.connect(
        url,
        pingInterval: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 3),
      );
      await _wsChannel!.ready;
    } catch (e) {
      log("Couldn't connect to endpoint $url");
      _connectStatus = ConnectStatus.disconnected;
      _currWsUrl = null;
      return;
    }
    if (signed) {
      if (!isAuthenticated) {
        throw Exception("Authentication required to perform this action.");
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch + 1000;
      final msg = utf8.encode('GET/realtime$timestamp');
      final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret!));
      final sign = hmacSha256.convert(msg).toString();
      final obj = {
        "op": "auth",
        "args": [
          apiKey,
          timestamp,
          sign,
        ]
      };
      _wsChannel!.sink.add(jsonEncode(obj));
    }
    _wsChannel!.stream.listen((data) {
      Map<String, dynamic> json = jsonDecode(data);
      if (json.containsKey("topic")) {
        _controller.add(json);
      } else {
        if (json["op"] == "subscribe") {
          if (json["success"]) {
            final topic = (json["req_id"] as String).split("/").first;
            _topics.add(topic);
            _pendingTopics.remove(topic);
            log("Subscribed to $topic");
          }
        } else if (json["op"] == "unsubscribe") {
          if (json["success"]) {
            final topic = (json["req_id"] as String).split("/").first;
            _topics.remove(topic);
            log("Unsubscribed from $topic");
            if (_topics.isEmpty) {
              checkForActiveTopics();
            }
          }
        } else if (json["op"] == "auth") {
          if (json["success"]) {
            log("Auth successful");
          } else {
            log("Auth failed");
          }
        } else if (json["op"] == "ping" || json["op"] == "pong") {
        } else {
          log("unknown message : ${json.toString()}");
        }
      }
    });
    log("ws connected");
    // start ping timer
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 20), _sendPing);
    _connectStatus = ConnectStatus.connected;
  }

  Future<void> checkForActiveTopics() async {
    await Future.delayed(Duration(seconds: 3));
    if (_topics.isEmpty && _pendingTopics.isEmpty) {
      log("No more active or pending topics, disconnecting...");
      disconnectWs();
    }
  }

  Future<void> _subscribeToTopic(String topic, String url, {int retries = 0, bool signed = false}) async {
    if (retries >= 3) {
      log("too many retries, canceling ...");
      return;
    }
    if (_connectStatus == ConnectStatus.connected) {
      if (_currWsUrl != url) {
        throw Exception("Can't connect to a different endpoint, make another instance of BybitApi");
      }
      log("subscribing to $topic");
      _pendingTopics.add(topic);
      final obj = {
        "op": "subscribe",
        "req_id": "$topic/${DateTime.now().millisecondsSinceEpoch}",
        "args": [topic],
      };
      _wsChannel!.sink.add(jsonEncode(obj));
    } else if (_connectStatus == ConnectStatus.connecting) {
      log("already connecting, awaiting 1s for retry ${++retries}");
      await Future.delayed(Duration(seconds: 1));
      _subscribeToTopic(topic, url, retries: retries, signed: signed);
      return;
    } else {
      await _wsConnect(url, signed: signed);
      _subscribeToTopic(topic, url, retries: ++retries, signed: signed);
    }
  }

  /// Helper function to unsubscribe from a particular websocket topic
  void unsubscribeFromTopic(String topic) async {
    final obj = {
      "op": "unsubscribe",
      "req_id": "$topic/${DateTime.now().millisecondsSinceEpoch}",
      "args": [topic],
    };
    _wsChannel!.sink.add(jsonEncode(obj));
  }

  /// Close websocket connection
  void disconnectWs() {
    // cancel ping timer
    _timer?.cancel();
    log("ws disconnected");
    _wsChannel?.sink.close();
    _connectStatus = ConnectStatus.disconnected;
    _currWsUrl = null;
  }

  /// Subscribe to the klines stream.
  ///
  /// Push frequency: 1-60s
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/public/kline).
  Subscription<WsKlineMessage> subscribeToKlines({required TimeInterval interval, required String symbol, required Category category}) {
    final topic = "kline.${interval.json}.$symbol";
    _subscribeToTopic(topic, "$_basePublicWsUrl${category.name}");
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsKlineMessage.fromMap(e)),
      topic: topic,
    );
  }

  /// Subscribe to the recent trades stream.
  ///
  /// Push frequency: real-time
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/public/trade).
  Subscription<WsTradeMessage> subscribeToTrades({required String symbol, required Category category}) {
    final topic = "publicTrade.$symbol";
    _subscribeToTopic(topic, "$_basePublicWsUrl${category.name}");
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsTradeMessage.fromMap(e)),
      topic: topic,
    );
  }

  /// Subscribe to the orderbook stream. Supports different depths.
  ///
  /// Push frequency : dedends on chosen depth, see documentation.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/public/orderbook).
  Subscription<WsOrderBookMessage> subscribeToOrderbook({required OrderbookDepth depth, required String symbol, required Category category}) {
    final topic = "orderbook.${depth.json}.$symbol";
    _subscribeToTopic(topic, "$_basePublicWsUrl${category.name}");
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsOrderBookMessage.fromMap(e)),
      topic: topic,
    );
  }

  /// Subscribe to the position stream to see changes to your position data in real-time.
  ///
  /// [Category.spot] is not supported
  ///
  /// Push frequency : real-time.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/private/position).
  Subscription<WsPositionMessage> subscribeToPositionUpdates({Category? category}) {
    final topic = category != null ? "position.${category.name}" : "position";
    _subscribeToTopic(topic, "wss://stream.bybit.com/v5/private", signed: true);
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsPositionMessage.fromMap(e)),
      topic: topic,
    );
  }

  /// Subscribe to the order stream to see changes to your orders in real-time.
  ///
  /// Push frequency : real-time.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/private/order).
  Subscription<WsOrderMessage> subscribeToOrderUpdates({Category? category}) {
    final topic = category != null ? "order.${category.name}" : "order";
    _subscribeToTopic(topic, "wss://stream.bybit.com/v5/private", signed: true);
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsOrderMessage.fromMap(e)),
      topic: topic,
    );
  }

  /// Subscribe to the wallet stream to see changes to your wallet in real-time.
  ///
  /// Push frequency : real-time.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/websocket/private/wallet).
  Subscription<WsWalletMessage> subscribeToWalletUpdates() {
    final topic = "wallet";
    _subscribeToTopic(topic, "wss://stream.bybit.com/v5/private", signed: true);
    return Subscription(
      stream: _controller.stream.where((e) => e["topic"] == topic).map((e) => WsWalletMessage.fromMap(e)),
      topic: topic,
    );
  }

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
        Uri.https(_baseUrl, path),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await http.get(
        Uri.https(_baseUrl, path, body),
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

  /// Query for historical klines (also known as candles/candlesticks). Charts are returned in groups based on the requested interval.
  ///
  /// This method does not require authentication.
  ///
  /// The [Category] can be [Category.spot], [Category.linear] or [Category.inverse], it default to [Category.linear].
  ///
  /// Max [limit] is 1000, defaults to 200 if not provided
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

  /// Query for the instrument specification of online trading pairs.
  ///
  /// This method does not require authentication.
  ///
  /// THIS METHOD CURRENTLY SUPPORTS ONLY [Category.linear] OR [Category.inverse].
  ///
  /// When query by baseCoin, regardless of category=linear or inverse, the result will have USDT perpetual, USDC contract and Inverse contract symbols.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/instrument).
  Future<InstrumentsResponse> getDerivativeInstrumentsInfo({
    required Category category,
    String? symbol,
    InstrumentStatus? status,
    String? baseCoin,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (status != null) 'status': status.json,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/market/instruments-info', body: queryParams);
    return InstrumentsResponse.fromMap(response);
  }

  /// Get the latest price snapshot, best bid/ask price, and trading volume in the last 24 hours.
  ///
  /// This method does not require authentication.
  ///
  /// THIS METHOD CURRENTLY SUPPORTS ONLY [Category.linear] OR [Category.inverse].
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/tickers).
  Future<List<TickerInfo>> getDerivativesTickers({
    required Category category,
    String? symbol,
    String? baseCoin,
    String? expDate,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (expDate != null) 'expDate': expDate,
    };

    final response = await _sendRequest('/v5/market/tickers', body: queryParams);
    return List<TickerInfo>.from((response["list"] as List<dynamic>).map((e) => TickerInfo.fromMap(e)));
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

  /// Get the open interest of each symbol.
  ///
  /// This method does not require authentication.
  ///
  /// Max [limit] is 200, defaults to 50
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/open-interest).
  Future<List<OpenInterest>> getOpenInterest({
    required Category category,
    required String symbol,
    required IntervalTime interval,
    int? startTime,
    int? endTime,
    int? limit,
    String? cursor,
  }) async {
    final queryParams = {
      'category': category.name,
      'symbol': symbol.toUpperCase(),
      'intervalTime': interval.json,
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/market/open-interest', body: queryParams);
    return (response["list"] as List<dynamic>).map((data) => OpenInterest.fromMap(data)).toList();
  }

  /// Get the long short ratio of a [symbol].
  ///
  /// This method does not require authentication.
  ///
  /// Max [limit] is 500, defaults to 50
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/market/long-short-ratio).
  Future<List<LongShortRatio>> getLongShortRatio({
    required Category category,
    required String symbol,
    required IntervalTime period,
    int? limit,
  }) async {
    final queryParams = {
      'category': category.name,
      'symbol': symbol.toUpperCase(),
      'period': period.json,
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _sendRequest('/v5/market/account-ratio', body: queryParams);
    return (response["list"] as List<dynamic>).map((data) => LongShortRatio.fromMap(data)).toList();
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

  /// This endpoint allows to query real-time position data.
  ///
  /// This method requires authentication.
  ///
  /// Will return an empty position if there are no current positions
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/position).
  Future<PositionListResponse> getPositionInfo({
    required Category category,
    String? symbol,
    String? baseCoin,
    String? settleCoin,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
      if (settleCoin != null) 'settleCoin': settleCoin,
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/position/list', body: queryParams, signed: true);
    return PositionListResponse.fromMap(response);
  }

  /// This endpoint allows to set the leverage.
  ///
  /// This method requires authentication.
  ///
  /// [buyLeverage] must be the same as [sellLeverage] for UTA (cross margin)
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/position/leverage).
  Future<void> setLeverage({
    required Category category,
    required String symbol,
    required int buyLeverage,
    required int sellLeverage,
  }) async {
    final Map<String, dynamic> bodyParams = {
      'category': category.name,
      'symbol': symbol,
      'buyLeverage': buyLeverage.toString(),
      'sellLeverage': sellLeverage.toString(),
    };

    await _sendRequest('/v5/position/set-leverage', body: bodyParams, signed: true, requestType: RequestType.postRequest);
  }

  /// This endpoint allows to set the take profit, stop loss or trailing stop for the position.
  ///
  /// This method requires authentication.
  ///
  /// [takeProfit], [stopLoss] and [trailingStop] cannot be less than 0. 0 means cancel TP / SL / TS.
  ///
  /// Unified account covers: USDT perpetual / USDC contract / Inverse contract
  ///
  /// Classic account covers: USDT perpetual / Inverse contract
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/position/trading-stop).
  Future<void> setTradingStop({
    required Category category,
    required String symbol,
    String? takeProfit,
    String? stopLoss,
    String? trailingStop,
    TriggerBy? tpTriggerBy,
    TriggerBy? slTriggerBy,
    String? activePrice,
    required TpslMode tpslMode,
    String? tpSize,
    String? slSize,
    String? tpLimitPrice,
    String? slLimitPrice,
    OrderType? tpOrderType,
    OrderType? slOrderType,
    required PositionIdx positionIdx,
  }) async {
    final Map<String, dynamic> bodyParams = {
      'category': category.name,
      'symbol': symbol,
      if (takeProfit != null) 'takeProfit': takeProfit,
      if (stopLoss != null) 'stopLoss': stopLoss,
      if (trailingStop != null) 'trailingStop': trailingStop,
      if (tpTriggerBy != null) 'tpTriggerBy': tpTriggerBy.json,
      if (slTriggerBy != null) 'slTriggerBy': slTriggerBy.json,
      if (activePrice != null) 'activePrice': activePrice,
      'tpslMode': tpslMode.json,
      if (tpSize != null) 'tpSize': tpSize,
      if (slSize != null) 'slSize': slSize,
      if (tpLimitPrice != null) 'tpLimitPrice': tpLimitPrice,
      if (slLimitPrice != null) 'slLimitPrice': slLimitPrice,
      if (tpOrderType != null) 'tpOrderType': tpOrderType.json,
      if (slOrderType != null) 'slOrderType': slOrderType.json,
      'positionIdx': positionIdx.json,
    };

    await _sendRequest('/v5/position/trading-stop', body: bodyParams, signed: true, requestType: RequestType.postRequest);
  }

  /// This endpoint allows querying user's closed profit and loss records.
  ///
  /// This method requires authentication.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/position/close-pnl).
  Future<ClosedPnlResponse> getClosedPnl({
    required Category category,
    String? symbol,
    int? startTime,
    int? endTime,
    int? limit,
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _sendRequest('/v5/position/closed-pnl', body: queryParams, signed: true);
    return ClosedPnlResponse.fromMap(response);
  }

  /// Obtain wallet balance, query asset information of each currency, and account risk rate information.
  ///
  /// This method requires authentication.
  ///
  /// By default, currency information with assets or liabilities of 0 is not returned.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/account/wallet-balance).
  Future<WalletBalance> getWalletBalance({
    required AccountType accountType,
    String? coin,
  }) async {
    final Map<String, dynamic> queryParams = {
      'accountType': accountType.json,
      if (coin != null) 'coin': coin,
    };

    final response = await _sendRequest('/v5/account/wallet-balance', body: queryParams, signed: true);
    return WalletBalance.fromMap((response["list"] as List<dynamic>).first);
  }

  /// Get the trading fee rate.
  ///
  /// This method requires authentication.
  ///
  /// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/account/fee-rate).
  Future<List<FeeRate>> getFeeRates({
    required Category category,
    String? symbol,
    String? baseCoin,
  }) async {
    final Map<String, dynamic> queryParams = {
      'category': category.name,
      if (symbol != null) 'symbol': symbol,
      if (baseCoin != null) 'baseCoin': baseCoin,
    };

    final response = await _sendRequest('/v5/account/fee-rate', body: queryParams, signed: true);
    return List<FeeRate>.from((response["list"] as List<dynamic>).map((e) => FeeRate.fromMap(e)));
  }
}

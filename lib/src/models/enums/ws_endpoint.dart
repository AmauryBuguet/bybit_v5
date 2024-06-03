/// Enumeration of websocket endpoints for Bybit mainnet
///
/// For more information, refer to the [Bybit API documentation](https://bybit-exchange.github.io/docs/v5/ws/connect).
enum WsEndpoint {
  spot("wss://stream.bybit.com/v5/public/spot"),
  linear("wss://stream.bybit.com/v5/public/linear"),
  inverse("wss://stream.bybit.com/v5/public/inverse"),
  option("wss://stream.bybit.com/v5/public/option"),
  private("wss://stream.bybit.com/v5/private"),
  trade("wss://stream.bybit.com/v5/trade");

  final String url;

  const WsEndpoint(this.url);
}

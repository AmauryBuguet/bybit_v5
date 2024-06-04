enum OrderbookDepth {
  lvl1("1"),
  lvl50("50"),
  lvl200("200"),
  lvl500("500");

  final String json;

  const OrderbookDepth(this.json);
}

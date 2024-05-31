class OrderIds {
  final String orderId;
  final String orderLinkId;

  OrderIds({
    required this.orderId,
    required this.orderLinkId,
  });

  factory OrderIds.fromJson(Map<String, dynamic> json) {
    return OrderIds(
      orderId: json['orderId'],
      orderLinkId: json['orderLinkId'],
    );
  }
}

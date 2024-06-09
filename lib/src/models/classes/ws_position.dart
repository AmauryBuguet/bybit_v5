import 'position.dart';

class WsPositionMessage {
  final String id;
  final String topic;
  final int creationTime;
  final List<Position> data;

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
      data: List<Position>.from(map['data']?.map((x) => Position.fromMap(x))),
    );
  }
}

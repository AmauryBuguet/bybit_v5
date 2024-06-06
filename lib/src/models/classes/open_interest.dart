class OpenInterest {
  final double value;
  final int timestamp;

  OpenInterest({required this.value, required this.timestamp});

  factory OpenInterest.fromMap(Map<String, dynamic> map) {
    return OpenInterest(
      value: double.parse(map["openInterest"]),
      timestamp: int.parse(map["timestamp"]),
    );
  }
}

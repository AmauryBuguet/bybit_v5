class Subscription<T> {
  final Stream<T> stream;
  final String topic;

  Subscription({required this.stream, required this.topic});
}

enum OriginMessage {me, other}

class Message {
  final String text;
  final String? messageId;
  final OriginMessage origin;

  Message({
    required this.text,
    this.messageId,
    required this.origin,
  });
}
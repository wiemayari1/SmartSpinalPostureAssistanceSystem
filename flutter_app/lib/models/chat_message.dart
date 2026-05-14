enum MessageType { text, alert, report, exercise, advice }

enum Sender { user, bot }

class ChatMessage {
  final String text;
  final Sender sender;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.user(String text) => ChatMessage(
        text: text,
        sender: Sender.user,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.bot(String text, {MessageType type = MessageType.text}) =>
      ChatMessage(
        text: text,
        sender: Sender.bot,
        type: type,
        timestamp: DateTime.now(),
      );

  bool get isUser => sender == Sender.user;
}

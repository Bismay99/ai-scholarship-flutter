class ChatMessage {
  final String role; // 'user' or 'model'
  final String text;

  ChatMessage({required this.role, required this.text});

  bool get isUser => role == 'user';
  bool get isError => text.contains("unavailable");
}

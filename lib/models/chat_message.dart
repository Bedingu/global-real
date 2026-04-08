class ChatMessage {
  final String id;
  final String leadId;
  final String senderType; // 'advisor', 'lead', 'ai'
  final String senderId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.leadId,
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      leadId: json['lead_id'] ?? '',
      senderType: json['sender_type'] ?? '',
      senderId: json['sender_id'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isAdvisor => senderType == 'advisor';
  bool get isAi => senderType == 'ai';
  bool get isLead => senderType == 'lead';
}

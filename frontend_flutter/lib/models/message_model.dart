class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String recipientId;
  final String text;
  final bool isSimulatedReply;
  final bool read;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientId,
    required this.text,
    this.isSimulatedReply = false,
    this.read = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      if (d is DateTime) return d;
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Message(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderName: (json['senderName'] ?? 'Unknown User').toString(),
      senderRole: (json['senderRole'] ?? 'brand').toString(),
      recipientId: (json['recipientId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      isSimulatedReply: json['isSimulatedReply'] == true,
      read: json['read'] == true,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'senderName': senderName,
    'senderRole': senderRole,
    'recipientId': recipientId,
    'text': text,
    'isSimulatedReply': isSimulatedReply,
    'read': read,
    'createdAt': createdAt.toIso8601String(),
  };
}

class ConversationParticipant {
  final String userId;
  final String name;
  final String role;
  final String avatar;

  String get id => userId;

  ConversationParticipant({
    required this.userId,
    required this.name,
    required this.role,
    this.avatar = '',
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      userId: (json['userId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Participant').toString(),
      role: (json['role'] ?? 'creator').toString(),
      avatar: (json['avatar'] ?? '').toString(),
    );
  }
}

class Conversation {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final List<ConversationParticipant> participants;
  String lastMessageText;
  String lastSenderName;
  DateTime lastMessageTime;
  int unreadCount;

  String get lastMessage => lastMessageText;
  set lastMessage(String val) => lastMessageText = val;

  DateTime get updatedAt => lastMessageTime;
  set updatedAt(DateTime val) => lastMessageTime = val;

  Conversation({
    required this.id,
    this.campaignId = '',
    this.campaignTitle = 'Direct Collaboration',
    required this.participants,
    this.lastMessageText = '',
    this.lastSenderName = '',
    DateTime? lastMessageTime,
    this.unreadCount = 0,
    String? lastMessage,
    DateTime? updatedAt,
  }) : lastMessageTime = lastMessageTime ?? updatedAt ?? DateTime.now() {
    if (lastMessage != null && lastMessage.isNotEmpty) {
      lastMessageText = lastMessage;
    }
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      if (d is DateTime) return d;
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final rawParts = json['participants'];
    final List<ConversationParticipant> parts = [];
    if (rawParts is List) {
      for (final p in rawParts) {
        if (p is Map<String, dynamic>) {
          parts.add(ConversationParticipant.fromJson(p));
        }
      }
    }

    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;

    return Conversation(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      campaignId: (json['campaignId'] ?? '').toString(),
      campaignTitle: (json['campaignTitle'] ?? 'Direct Collaboration').toString(),
      participants: parts,
      lastMessageText: (lastMsg?['text'] ?? '').toString(),
      lastSenderName: (lastMsg?['senderName'] ?? '').toString(),
      lastMessageTime: parseDate(lastMsg?['createdAt'] ?? json['updatedAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  ConversationParticipant getOtherParticipant(String currentUserId) {
    if (participants.isEmpty) {
      return ConversationParticipant(userId: 'unknown', name: 'Collaborator', role: 'creator');
    }
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }
}


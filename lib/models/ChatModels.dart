import 'package:app_machin/models/Product.dart';

class ChatMessage {
  final String role; // "user", "assistant", "system"
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
    );
  }
}

class ChatRequest {
  final List<ChatMessage> messages;

  ChatRequest({required this.messages});

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}

class ChatResponse {
  final String status;
  final String message;
  final ChatData data;

  ChatResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: ChatData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ChatData {
  final String response;
  final List<Product> products;

  ChatData({required this.response, required this.products});

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      response: json['response'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

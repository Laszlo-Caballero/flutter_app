import 'package:app_machin/models/ChatModels.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApi {
  final Dio dio = Dio(BaseOptions(
    baseUrl: dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api"),
  ));

  Future<ChatResponse?> sendChat(List<ChatMessage> messages) async {
    try {
      final res = await dio.post(
        '/products/chat',
        data: {
          'messages': messages.map((m) => m.toJson()).toList(),
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        return ChatResponse.fromJson(res.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

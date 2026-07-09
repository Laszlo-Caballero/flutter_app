import 'package:app_machin/models/ChatModels.dart';
import 'package:app_machin/services/ChatApi.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApi _chatApi = ChatApi();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text, String? token) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: text);
    _messages.add(userMessage);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _chatApi.sendChat(_messages, token);
      if (response != null) {
        final assistantMessage = ChatMessage(
          role: 'assistant',
          content: response.data.response,
        );
        _messages.add(assistantMessage);
      } else {
        _errorMessage = "No se pudo obtener respuesta del asistente.";
      }
    } catch (e) {
      _errorMessage = "Error de conexión con el servidor.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
}

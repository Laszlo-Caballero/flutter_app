import 'package:app_machin/providers/ChatProvider.dart';
import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    // Scroll to bottom when new messages arrive
    _scrollToBottom();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Top Bar for Chat actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.blue,
                      child: Icon(Icons.assistant, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asistente Visionario",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue, fontSize: 16),
                        ),
                        Text(
                          "En línea",
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    chatProvider.clearChat();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Conversación reiniciada")),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text("Limpiar", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

          // Message history list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              "¡Hola! Soy tu Asistente Inteligente.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Pregúntame sobre cualquier producto, disponibilidad o especificaciones. Por ejemplo:\n\"¿Tienen laptops gamer ASUS?\"",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.blue : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue),
              ),
            ),

          // Message input bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: "Escribe un mensaje...",
                                border: InputBorder.none,
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  chatProvider.sendMessage(val.trim(), auth.token);
                                  _messageController.clear();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic, color: AppColors.gray),
                            onPressed: () {
                              // Mic action placeholder matching speech recognition trigger
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Búsqueda por voz activada")),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: AppColors.blue,
                  mini: true,
                  onPressed: () {
                    final text = _messageController.text;
                    if (text.trim().isNotEmpty) {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      chatProvider.sendMessage(text.trim(), auth.token);
                      _messageController.clear();
                    }
                  },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

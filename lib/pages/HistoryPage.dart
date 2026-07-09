import 'package:app_machin/models/HistoryItem.dart';
import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/services/HistoryApi.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Historypage extends StatefulWidget {
  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  final HistoryApi _historyApi = HistoryApi();
  List<HistoryItem>? _historyItems;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final items = await _historyApi.getHistory(authProvider.token);
      setState(() {
        _historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error al cargar el historial";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.blue,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Reintentar"),
            )
          ],
        ),
      );
    }

    if (_historyItems == null || _historyItems!.isEmpty) {
      // Empty state matching Kotlin layout empty state visual
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                "Historial Vacío",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                "No has realizado búsquedas o análisis de imágenes recientemente.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _historyItems!.length,
      itemBuilder: (context, index) {
        final item = _historyItems![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with rounded corners on left side
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: item.image.isNotEmpty
                        ? Image.network(
                            item.image.startsWith('http')
                                ? item.image
                                : '${dotenvGetApi()}${item.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.history, size: 40, color: AppColors.gray),
                          )
                        : const Icon(Icons.history, size: 40, color: AppColors.gray),
                  ),
                ),
                const SizedBox(width: 16),
                // Text details on right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category badge with background
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Time
                          Text(
                            item.time,
                            style: const TextStyle(
                              color: AppColors.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String dotenvGetApi() {
    // Return base URL from environment
    final api = dotenv.get("PUBLIC_API", fallback: "");
    if (api.endsWith('/api')) {
      return api.substring(0, api.length - 4);
    }
    return api;
  }
}

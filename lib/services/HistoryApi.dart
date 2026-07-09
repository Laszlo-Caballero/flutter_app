import 'package:app_machin/models/HistoryItem.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryApi {
  final Dio dio = Dio(BaseOptions(
    baseUrl: _normalizeUrl(dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api")),
  ));

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  Future<List<HistoryItem>?> getHistory(String? token) async {
    try {
      final res = await dio.get(
        'history',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (res.statusCode == 200) {
        final dynamic responseData = res.data;
        if (responseData is List) {
          return responseData.map((e) => HistoryItem.fromJson(e)).toList();
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final dataJson = responseData['data'];
          if (dataJson is List) {
            return dataJson.map((e) => HistoryItem.fromJson(e)).toList();
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteHistory(String? token) async {
    try {
      final res = await dio.delete(
        'history',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

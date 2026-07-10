import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationApi {
  final Dio dio = Dio(BaseOptions(
    baseUrl: _normalizeUrl(dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api")),
  ));

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  Future<bool> registerToken(String? authToken, String fcmToken) async {
    try {
      final res = await dio.post(
        'notifications/register-token',
        data: {
          'token': fcmToken,
          'platform': 'android',
        },
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
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

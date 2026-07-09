import 'package:app_machin/models/Auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {
  final Dio dio = Dio(BaseOptions(
    baseUrl: _normalizeUrl(dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api")),
  ));

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  Future<AuthData?> login(String username, String password) async {
    try {
      final res = await dio.post(
        'auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data != null) {
          return AuthData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AuthData?> register(String username, String email, String password) async {
    try {
      final res = await dio.post(
        'auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data != null) {
          return AuthData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

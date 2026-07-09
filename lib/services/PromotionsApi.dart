import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PromotionsApi {
  final Dio dio = Dio(BaseOptions(
    baseUrl: _normalizeUrl(dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api")),
  ));

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  Future<Map<String, dynamic>?> redeemPromotion(String code, String? token) async {
    try {
      final res = await dio.get(
        'promotions/redeem/$code',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (res.statusCode == 200 && res.data != null) {
        final dynamic responseData = res.data;
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

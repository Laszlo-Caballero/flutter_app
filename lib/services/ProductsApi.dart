import 'dart:io';
import 'package:app_machin/models/Product.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Productsapi {
  final dio = Dio(BaseOptions(
    baseUrl: _normalizeUrl(dotenv.get("PUBLIC_API", fallback: "http://localhost:8000/api")),
  ));

  static String _normalizeUrl(String url) {
    return url.endsWith('/') ? url : '$url/';
  }

  Future<List<Product>?> getProductsByImage(File image, String? token) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final res = await dio.post(
        'products/identify',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        final dynamic responseData = res.data;
        print(responseData);
        if (responseData is List) {
          return responseData.map((e) => Product.fromJson(e)).toList();
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final dataJson = responseData['data'];
          if (dataJson is List) {
            return dataJson.map((e) => Product.fromJson(e)).toList();
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>?> getProducts(String query, String? token) async {
    try {
      final res = await dio.get(
        'products',
        queryParameters: {
          if (query.isNotEmpty) 'query': query,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data is List) {
          return data.map((e) => Product.fromJson(e)).toList();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>?> voiceSearch(String query, String? token) async {
    try {
      final res = await dio.get(
        'products/voice',
        queryParameters: {
          'query': query,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data is List) {
          return data.map((e) => Product.fromJson(e)).toList();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

import 'dart:io';
import 'package:app_machin/models/ApiResponse.dart';
import 'package:app_machin/models/Product.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Productsapi {
  final dio = Dio(BaseOptions(baseUrl: dotenv.get("PUBLIC_API")));

  Future<List<Product>?> getProductsByImage(File image) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final res = await dio.post<Apiresponse<List<Product>>>(
        '/products/identify',
        data: formData,
      );

      return res.data?.data;
    } catch (e) {
      return null;
    }
  }
}

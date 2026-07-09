import 'dart:io';
import 'package:app_machin/models/Product.dart';
import 'package:app_machin/services/ProductsApi.dart';
import 'package:flutter/material.dart';

class AnalysisProvider extends ChangeNotifier {
  final Productsapi _productsApi = Productsapi();

  bool _isLoading = false;
  List<Product>? _products;
  Product? _selectedProduct;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Product>? get products => _products;
  Product? get selectedProduct => _selectedProduct;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _products = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final results = await _productsApi.getProductsByImage(imageFile);
      if (results != null && results.isNotEmpty) {
        _products = results;
        _selectedProduct = results.first;
      } else {
        _errorMessage = "No se encontraron productos en la imagen.";
      }
    } catch (e) {
      _errorMessage = "Error al analizar la imagen: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clear() {
    _isLoading = false;
    _products = null;
    _selectedProduct = null;
    _errorMessage = null;
    notifyListeners();
  }
}

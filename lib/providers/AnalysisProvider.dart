import 'dart:io';
import 'package:app_machin/models/Tienda.dart';
import 'package:app_machin/services/TiendasApi.dart';
import 'package:flutter/material.dart';

class AnalysisProvider extends ChangeNotifier {
  final TiendasApi _tiendasApi = TiendasApi();

  bool _isLoading = false;
  List<Tienda>? _tiendas;
  Tienda? _selectedTienda;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Tienda>? get tiendas => _tiendas;
  Tienda? get selectedTienda => _selectedTienda;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _tiendas = null;
    _selectedTienda = null;
    notifyListeners();

    try {
      // Simulate slight delay to show the beautiful premium loading animation
      await Future.delayed(const Duration(seconds: 2));
      
      final results = await _tiendasApi.getTiendasByImage(imageFile);
      if (results != null && results.isNotEmpty) {
        _tiendas = results;
        _selectedTienda = results.first; // Default select the first store
      } else {
        _errorMessage = "No se encontraron tiendas en la imagen.";
      }
    } catch (e) {
      _errorMessage = "Error al analizar la imagen: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTienda(Tienda tienda) {
    _selectedTienda = tienda;
    notifyListeners();
  }

  void clear() {
    _isLoading = false;
    _tiendas = null;
    _selectedTienda = null;
    _errorMessage = null;
    notifyListeners();
  }
}

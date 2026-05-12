import 'package:flutter/material.dart';

class Routeprovider extends ChangeNotifier {
  String _currentRoute = "/";

  String get currentRoute => _currentRoute;

  void navigateTo(String route) {
    _currentRoute = route;
    notifyListeners();
  }
}

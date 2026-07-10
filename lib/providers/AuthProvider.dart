import 'package:app_machin/models/Auth.dart';
import 'package:app_machin/services/AuthApi.dart';
import 'package:app_machin/services/NotificationApi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  final NotificationApi _notificationApi = NotificationApi();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage = null;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && _token != null) {
        await _notificationApi.registerToken(_token, fcmToken);
        debugPrint("FCM token registered successfully on the server.");
      }
    } catch (e) {
      debugPrint("Failed to register FCM token: $e");
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authData = await _authApi.login(username, password);
      if (authData != null) {
        _user = authData.user;
        _token = authData.accessToken;
        _isLoading = false;
        notifyListeners();
        // Register push token after successful login
        _registerFcmToken();
        return true;
      } else {
        _errorMessage = "Usuario o contraseña incorrectos.";
      }
    } catch (e) {
      _errorMessage = "Error de conexión con el servidor.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authData = await _authApi.register(username, email, password);
      if (authData != null) {
        _user = authData.user;
        _token = authData.accessToken;
        _isLoading = false;
        notifyListeners();
        // Register push token after successful registration
        _registerFcmToken();
        return true;
      } else {
        _errorMessage = "Datos inválidos o el usuario ya existe.";
      }
    } catch (e) {
      _errorMessage = "Error de conexión con el servidor.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}

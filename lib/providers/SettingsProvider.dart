import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _highContrastMode = false;
  bool _audioAssistant = false;

  bool get highContrastMode => _highContrastMode;
  bool get audioAssistant => _audioAssistant;

  set highContrastMode(bool value) {
    _highContrastMode = value;
    notifyListeners();
  }

  set audioAssistant(bool value) {
    _audioAssistant = value;
    notifyListeners();
  }
}

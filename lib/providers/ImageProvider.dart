import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSearchProvider extends ChangeNotifier {
  XFile? _selectedImage;

  XFile? get selectedImage => _selectedImage;

  void setSelectedImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<bool> pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    setSelectedImage(photo);
    return photo != null;
  }

  Future<bool> pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setSelectedImage(image);
    return image != null;
  }

  void clearSelectedImage() {
    setSelectedImage(null);
  }
}

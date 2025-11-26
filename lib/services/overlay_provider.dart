import 'package:flutter/material.dart';

class OverlayProvider extends ChangeNotifier {
  bool isVisible = false;

  void toggleOverlay() {
    isVisible = !isVisible;
    notifyListeners();
  }
}

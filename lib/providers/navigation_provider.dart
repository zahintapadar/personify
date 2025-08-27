import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateToTests() {
    setIndex(2); // Tests tab is at index 2
  }

  void navigateToHome() {
    setIndex(0);
  }

  void navigateToDiscover() {
    setIndex(1);
  }

  void navigateToProfile() {
    setIndex(3);
  }
}

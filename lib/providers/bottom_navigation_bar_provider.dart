import 'package:flutter/material.dart';

class BottomNavigationBarProvider extends ChangeNotifier {
  int _selectedIndex = 1;

  int get selectedIndex => _selectedIndex;

  void navigateTo(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

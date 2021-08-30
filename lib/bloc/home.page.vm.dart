import 'package:flutter/material.dart';

class HomePageVm with ChangeNotifier {
  HomePageVm();

  int _currentPage = 0;
  bool _isExpanded = false;

  set currentPage(int newPage) {
    _currentPage = newPage;
    notifyListeners();
  }

  int get currentPage => _currentPage;

  set isExpanded(bool isExpanded) {
    _isExpanded = isExpanded;
    notifyListeners();
  }

  bool get isExpanded => _isExpanded;
}

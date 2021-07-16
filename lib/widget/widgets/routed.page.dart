import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutedPage extends StatelessWidget {
  final Widget child;

  RoutedPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => child), );
  }
}

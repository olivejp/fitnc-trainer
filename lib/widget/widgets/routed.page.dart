import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutedPage extends StatelessWidget {
  const RoutedPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<Widget>(builder: (BuildContext context) => child), );
  }
}

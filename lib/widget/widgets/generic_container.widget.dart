import 'package:flutter/material.dart';

class GenericContainerWidget extends StatelessWidget {
  final Widget child;

  GenericContainerWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/background.jpg'), fit: BoxFit.cover)),
      child: this.child,
    );
  }
}

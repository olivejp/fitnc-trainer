import 'package:flutter/material.dart';

class GenericContainerWidget extends StatelessWidget {
  final Widget child;
  final double opacity;

  GenericContainerWidget({required this.child, this.opacity = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/background.jpg'), fit: BoxFit.cover)),
      child: Container(
        child: this.child,
        decoration: BoxDecoration(color: Color(Colors.white.withOpacity(this.opacity).value)),
      ),
    );
  }
}

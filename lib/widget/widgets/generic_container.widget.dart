import 'package:flutter/material.dart';

class GenericContainerWidget extends StatelessWidget {
  const GenericContainerWidget({required this.child, this.opacity = 0.0});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(Colors.white.withOpacity(opacity).value),
        ),
        child: child,
      ),
    );
  }
}

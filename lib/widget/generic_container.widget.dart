import 'package:flutter/material.dart';

class GenericContainerWidget extends StatelessWidget {
  final Widget child;

  GenericContainerWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage("https://s3.envato.com/files/189120872/0Q7A7108.jpg"), fit: BoxFit.cover)),
      child: this.child,
    );
  }
}

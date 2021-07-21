import 'package:flutter/material.dart';

class GenericUpdateWidget extends StatelessWidget {
  final Widget child;
  final double maximumWidth;
  final double opacity;

  GenericUpdateWidget({required this.child, this.maximumWidth = 800, this.opacity=0.8});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double limit = constraints.maxWidth;
        if (constraints.maxWidth > maximumWidth) {
          limit = maximumWidth;
        }
        return Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.expand(width: limit),
                    child: Container(
                        decoration: BoxDecoration(color: Color(Colors.white.withOpacity(this.opacity).value)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: SingleChildScrollView(child: child),
                        )),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

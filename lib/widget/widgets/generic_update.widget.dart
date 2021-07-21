import 'package:flutter/material.dart';

class GenericUpdateWidget extends StatelessWidget {

  const GenericUpdateWidget({required this.child, this.maximumWidth = 800, this.opacity=0.8});

  final Widget child;
  final double maximumWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
                        decoration: BoxDecoration(color: Color(Colors.white.withOpacity(opacity).value)),
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

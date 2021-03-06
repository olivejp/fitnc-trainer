import 'package:flutter/material.dart';

class GenericUpdateWidget extends StatelessWidget {

  const GenericUpdateWidget({required this.child, this.maximumWidth = double.infinity, this.opacity=0.8});

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
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints.expand(width: limit),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: SingleChildScrollView(child: child),
                    ),
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

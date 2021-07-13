import 'package:flutter/material.dart';

class GenericUpdateWidget extends StatelessWidget {
  final Widget child;
  final double maximumWidth;

  GenericUpdateWidget({required this.child, this.maximumWidth = 800});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double limit = constraints.maxWidth;
        if (constraints.maxWidth > maximumWidth) {
          limit = maximumWidth;
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LimitedBox(
                    maxWidth: limit,
                    child: SingleChildScrollView(
                      child: Container(
                          decoration: BoxDecoration(color: Color(Colors.white.withOpacity(0.8).value), borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                            child: child,
                          )),
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

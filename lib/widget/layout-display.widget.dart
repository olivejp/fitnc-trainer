
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutDisplayNotifier extends StatefulWidget {
  const LayoutDisplayNotifier({
    Key? key,
    required this.child,
    this.desktopSize = 1280,
    this.tabletSize = 800,
  }) : super(key: key);
  final int desktopSize;
  final int tabletSize;
  final Widget child;

  @override
  State<LayoutDisplayNotifier> createState() => _LayoutDisplayNotifierState();
}

class _LayoutDisplayNotifierState extends State<LayoutDisplayNotifier> {
  final DisplayTypeService displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        /// Mise à jour du displayType selon la largeur de l'écran.
        DisplayType displayType = DisplayType.desktop;
        if (constraints.maxWidth >= widget.desktopSize) {
          displayType = DisplayType.desktop;
        } else if (constraints.maxWidth >= widget.tabletSize && constraints.maxWidth <= widget.desktopSize - 1) {
          displayType = DisplayType.tablet;
        } else {
          displayType = DisplayType.mobile;
        }
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          displayTypeController.changeDisplay(displayType);
        });

        return widget.child;
      },
    );
  }
}

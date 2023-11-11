import 'dart:developer' as developer;

import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///
/// Ce Widget permet de notifier à traver le service DisplayTypeService
/// Si l'écran est un desktop, une tablette ou un mobile.
///
/// Pour notifier tous les composants enfants d'un changement de résolution il faut s'injecter le service
/// DisplayTypeService et écouter l'observable displayType.
///
class LayoutNotifier extends StatefulWidget {
  const LayoutNotifier({
    super.key,
    required this.child,
    this.desktopSize = 1280,
    this.tabletSize = 800,
  });
  final int desktopSize;
  final int tabletSize;
  final Widget child;

  @override
  State<LayoutNotifier> createState() => _LayoutNotifierState();
}

class _LayoutNotifierState extends State<LayoutNotifier> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        // Mise à jour du displayType selon la largeur de l'écran.
        DisplayType displayType = DisplayType.desktop;

        // Calcul de la nouvelle taille de l'écran.
        if (constraints.maxWidth >= widget.desktopSize) {
          displayType = DisplayType.desktop;
        } else if (constraints.maxWidth >= widget.tabletSize && constraints.maxWidth <= widget.desktopSize - 1) {
          displayType = DisplayType.tablet;
        } else {
          displayType = DisplayType.mobile;
        }

        // Notification au service que la taille de l'écran a changé.
        WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
          developer.log('displayType is now : $displayType');
          Provider.of<DisplayTypeNotifier>(context, listen: false).changeDisplay(displayType);
        });

        return widget.child;
      },
    );
  }
}

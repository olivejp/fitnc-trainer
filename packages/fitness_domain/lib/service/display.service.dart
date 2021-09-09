import 'package:get/get.dart';

/// Enumération des différents types d'affichage possibles
enum DisplayType { mobile, tablet, desktop }

/// Notifier qui permet de savoir quel est l'affichage courant
class DisplayTypeService extends GetxService {
  Rx<DisplayType> displayType = DisplayType.mobile.obs;

  void changeDisplay(DisplayType newDisplayType) {
    displayType.value = newDisplayType;
  }
}
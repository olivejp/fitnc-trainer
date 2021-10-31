import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

class FirebaseInitFunctionsService extends GetxService {
  FirebaseInitFunctionsService({this.emulate = false, this.region});

  final bool emulate;
  final String? region;

  FirebaseFunctions? _instance;

  ///
  /// Retourne l'instance FirebaseFunctions en cours.
  ///
  FirebaseFunctions instance() {
    if (_instance == null) {
      throw Exception('No instance of FirebaseFunctions available.');
    }
    return _instance!;
  }

  ///
  /// A l'initialisation du service
  /// On spécifie la région, si elle a été renseignée.
  /// si le dev mode est activé, on va se brancher sur l'émulator.
  ///
  @override
  void onInit() {
    super.onInit();

    getInstanceFromRegion(region);

    if (emulate) {
      developer.log(
        '[WARNING] Application launched with emulate mode : Firebase Functions emulator will be used.',
        level: 100,
      );

      instance().useFunctionsEmulator('localhost', 5001);
    }
  }

  ///
  /// Permet de spécifier la région du noeud Firebase Functions.
  /// Si aucune région spécifiée 'us-central1' sera utilisée.
  ///
  void getInstanceFromRegion(String? region) {
    if (region != null) {
      _instance = FirebaseFunctions.instanceFor(region: region);
    } else {
      _instance = FirebaseFunctions.instance;
    }
  }
}

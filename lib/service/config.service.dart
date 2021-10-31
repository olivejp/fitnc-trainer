import 'package:get/get.dart';

///
/// Service permettant de récupérer de la configuration au démarrage de l'application.
/// Si vous voulez récupérer une nouvelle valeur, il faut la rajouter ici.
///
class ConfigService extends GetxService {
  final Map<String, dynamic> mapConfig = <String, dynamic>{};
  static const String emulatorsCommandLineArgument = 'EMULATORS';
  static const String profileCommandLineArgument = 'PROFILE';

  dynamic get(String key) {
    return mapConfig[key];
  }

  bool emulateStorage(){
    return _getEmulators().contains('STORAGE');
  }

  bool emulateAuth(){
    return _getEmulators().contains('AUTH');
  }

  bool emulateFunctions(){
    return _getEmulators().contains('FUNCTIONS');
  }

  bool emulateFirestore(){
    return _getEmulators().contains('FIRESTORE');
  }

  ///
  /// Si l'application a été lancée avec le paramètre :  --dart-define="PROFILE=DEV"
  /// Alors on est en mode développement.
  ///
  bool isDevMode() {
    return get(profileCommandLineArgument) == 'DEV';
  }

  @override
  void onInit() {
    super.onInit();
    mapConfig.putIfAbsent(
      profileCommandLineArgument,
      () => const String.fromEnvironment(profileCommandLineArgument),
    );

    mapConfig.putIfAbsent(
      emulatorsCommandLineArgument,
          () => const String.fromEnvironment(emulatorsCommandLineArgument),
    );
  }

  String _getEmulators(){
    return (get(emulatorsCommandLineArgument) as String).toUpperCase();
  }
}

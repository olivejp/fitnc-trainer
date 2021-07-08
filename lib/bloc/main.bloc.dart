import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_trainer/service/auth.service.dart';

class MainBloc {
  static MainBloc? _instance;

  final AuthService authService = AuthService.getInstance();

  MainBloc._();

  static MainBloc getInstance() {
    if (_instance == null) {
      _instance = MainBloc._();
    }
    return _instance!;
  }

  // Future builder wich initiate the Firebase framework.
  Future<dynamic> initThridParty() {
    return Firebase.initializeApp()
        .catchError((error) => print(
            'Erreur lors de l' 'initialisation de Firebase : ' +
                error.toString()));
  }

  Future<bool> isConnected() {
    return authService.isConnected();
  }

  Stream<User?> streamUser() {
    return authService.userStream;
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

///
/// Widget qui permet l'initialisation de l'application Firebase.
/// Si l'application Firebase a bien été initialisé, on va injecter les
/// services dépendants dans GetX.
///
class FirebaseInitWidget extends StatelessWidget {
  const FirebaseInitWidget({
    Key? key,
    required this.child,
    required this.onSuccess,
    this.onError,
  }) : super(key: key);
  final Widget child;
  final void Function() onSuccess;
  final void Function()? onError;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(),
      builder: (_, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          onSuccess();
          return child;
        }
        if (snapshot.hasError) {
          if (onError != null) {
            onError!();
          }
          return const Scaffold(
            body: Center(
              child: Text('Firebase initialization failed.'),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_trainer/constants.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/service/firebase.service.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/widgets/auth.widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseWidget extends StatelessWidget {
  const FirebaseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = Provider.of<FirebaseService>(context);
    return FutureBuilder<FirebaseApp>(
      future: firebaseService.initialize(),
      builder: (_, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          return const AuthWidget();
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("L'application Firebase n'a pas été démarrée correctement."),
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

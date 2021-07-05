import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/widget/add_workout.page.dart';
import 'package:fitnc_trainer/widget/login.page.dart';
import 'package:fitnc_trainer/widget/my-home-page.widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import 'bloc/main.bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainBloc bloc = MainBloc.getInstance();
  final AuthService authService = AuthService.getInstance();
  final appTitle = 'Fitness Nc';

  @override
  Widget build(BuildContext context) {
    // Listen for user update.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      authService.updateUser(user);
    });

    return MaterialApp(
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.amber),
        routes: {'/add_workout': (context) => AddWorkoutPage()},
        home: FutureBuilder(
            future: bloc.initThridParty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError) {
                return StreamBuilder(
                    stream: bloc.streamUser(),
                    builder: (context, snapshot) {
                      return FutureBuilder<bool>(
                          future: bloc.isConnected(),
                          builder: (context, snapshot) => snapshot.data == true
                              ? MyHomePage('Fitness Nc')
                              : LoginPage(namePage: 'Connexion'));
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                      'Erreur lors de l' 'initialisation de l' 'application.'),
                );
              }
              return LoadingBouncingGrid.circle();
            }));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';

import 'bloc/main.bloc.dart';
import 'domain/workout.domain.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainBloc bloc = MainBloc.getInstance();
  final AuthService authService = AuthService.getInstance();
  final appTitle = 'Fitness Nc';

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      authService.updateUser(user);
    });

    return MaterialApp(
        title: appTitle,
        theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
            primarySwatch: Colors.amber,
            floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.white),
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.amber, size: 30),
              backgroundColor: Colors.black87,
              toolbarHeight: 50,
              centerTitle: true,
            )),
        routes: {
          '/add_workout': (context) => WorkoutUpdatePage(
                workout: Workout(),
              ),
          '/add_abonne': (context) => AbonneUpdatePage(
                abonne: null,
              ),
          '/add_exercice': (context) => ExerciceUpdatePage(
                exercice: null,
              )
        },
        home: FutureBuilder(
            future: bloc.initThridParty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                return StreamBuilder(
                    stream: bloc.streamUser(),
                    builder: (context, snapshot) {
                      return FutureBuilder<bool>(
                          future: bloc.isConnected(),
                          builder: (context, snapshot) => snapshot.data == true ? MyHomePage('Fitness Nc') : LoginPage(namePage: 'Connexion'));
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur lors de l' 'initialisation de l' 'application.'),
                );
              }
              return LoadingBouncingGrid.circle();
            }));
  }
}

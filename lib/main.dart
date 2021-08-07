import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
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
  final String appTitle = 'Fitness Nc';

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      authService.updateUser(user);
    });

    return OKToast(
      position: ToastPosition.bottom,
      child: MaterialApp(
          title: appTitle,
          theme: ThemeData(
            navigationRailTheme: NavigationRailThemeData(
                backgroundColor: const Color(0xff385c79),
                selectedIconTheme: const IconThemeData(color: Colors.amber),
                unselectedIconTheme: const IconThemeData(color: Colors.white),
                selectedLabelTextStyle: GoogleFonts.workSansTextTheme().headline1!.copyWith(color: Colors.amber, fontSize: 18),
                unselectedLabelTextStyle: GoogleFonts.workSansTextTheme().headline1!.copyWith(color: const Color(0xff8a9ca8), fontSize: 18)),
            textTheme: TextTheme(
              headline1: GoogleFonts.alfaSlabOne(color: Color(0xff385c79), fontSize: 35, fontWeight: FontWeight.bold),
              headline2: GoogleFonts.alfaSlabOne(color: Colors.amber, fontSize: 25),
              subtitle1: GoogleFonts.roboto(color: Colors.white, fontSize: 18),
              subtitle2: GoogleFonts.roboto(color: Colors.amber, fontSize: 18),
            ),
            fixTextFieldOutlineLabel: true,
            inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
            primarySwatch: Colors.amber,
            floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.white),
          ),
          routes: {
            '/sign_up': (BuildContext context) => SignUpPage(
                  namePage: 'Création de compte',
                  callback: (UserCredential userCredential) => Navigator.pop(context),
                ),
            '/add_workout': (BuildContext context) => WorkoutUpdatePage(
                  workout: Workout(),
                ),
            '/add_abonne': (BuildContext context) => AbonneUpdatePage(),
            '/add_exercice': (BuildContext context) => ExerciceUpdatePage()
          },
          home: FutureBuilder<dynamic>(
              future: bloc.initThridParty(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                  return StreamBuilder<User?>(
                      stream: bloc.streamUser(),
                      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                        return FutureBuilder<bool>(
                            future: bloc.isConnected(),
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) =>
                                snapshot.data == true ? MyHomePage(appTitle) : LoginPage(namePage: 'Connexion'));
                      });
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Erreur lors de l'initialisation de l' 'application."),
                  );
                }
                return LoadingRotating.square(
                  backgroundColor: Theme.of(context).primaryColor,
                );
              })),
    );
  }
}

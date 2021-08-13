import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';

import 'bloc/main.bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainBloc bloc = MainBloc.getInstance();
  final AuthService authService = AuthService.getInstance();
  final String appTitle = 'Fitness Nc';

  @override
  Widget build(BuildContext context) {
    // On écoute les changement de l'utilisateur.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      authService.updateUser(user);
    });


    return OKToast(
      position: ToastPosition.bottom,
      child: MaterialApp(
          title: appTitle,
          theme: ThemeData(
            navigationRailTheme: NavigationRailThemeData(
                backgroundColor: FitnessNcColors.blue100,
                selectedIconTheme: const IconThemeData(color: FitnessNcColors.orange500),
                unselectedIconTheme: const IconThemeData(color: FitnessNcColors.blue800),
                selectedLabelTextStyle: GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.orange500, fontSize: 18, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.blue600, fontSize: 18)),
            textTheme: TextTheme(
              headline1:
                  GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.blue600, fontSize: 35, fontWeight: FontWeight.bold),
              headline2: GoogleFonts.alfaSlabOneTextTheme().headline2!.copyWith(color: FitnessNcColors.orange500, fontSize: 25),
              headline3: GoogleFonts.workSansTextTheme().headline3!.copyWith(color: FitnessNcColors.blue800, fontSize: 18),
              headline5: GoogleFonts.workSansTextTheme().headline5!.copyWith(color: FitnessNcColors.black900Alpha011, fontSize: 50),
              headline6: GoogleFonts.workSansTextTheme().headline6!.copyWith(color: FitnessNcColors.black900, fontSize: 15),
              subtitle1: GoogleFonts.workSansTextTheme().subtitle1!.copyWith(color: FitnessNcColors.blue800, fontSize: 15),
              subtitle2: GoogleFonts.roboto(color: FitnessNcColors.orange500, fontSize: 18),
            ),
            fixTextFieldOutlineLabel: true,
            inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
            primarySwatch: Colors.amber,
            floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: FitnessNcColors.white50),
          ),
          routes: {
            '/login': (BuildContext context) => LoginPage(
                  callback: (UserCredential userCredential) => Navigator.of(context).pushNamed('/'),
                ),
            '/sign_up': (BuildContext context) => SignUpPage(
                  callback: (UserCredential userCredential) => Navigator.pop(context),
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
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                              return snapshot.data == true
                                  ? MyHomePage(appTitle)
                                  : LoginPage(
                                      callback: (UserCredential userCredential) => Navigator.of(context).pushNamed('/'),
                                    );
                            });
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

class FitnessConstants {
  static const double textFormFieldHeight = 60;
}

class FitnessNcColors {
  static const Color white50 = Color(0xFFFFFFFF);

  static const Color black800 = Color(0xFF121212);
  static const Color black900 = Color(0xFF000000);

  static const Color blue50 = Color(0xFFEEF0F2);
  static const Color blue100 = Color(0xFFD2DBE0);
  static const Color blue200 = Color(0xFFADBBC4);
  static const Color blue300 = Color(0xFF8CA2AE);
  static const Color blue600 = Color(0xFF4A6572);
  static const Color blue700 = Color(0xFF344955);
  static const Color blue800 = Color(0xFF232F34);

  static const Color orange300 = Color(0xFFFBD790);
  static const Color orange400 = Color(0xFFF9BE64);
  static const Color orange500 = Color(0xFFF9AA33);

  static const Color red200 = Color(0xFFCF7779);
  static const Color red400 = Color(0xFFFF4C5D);

  static const Color white50Alpha060 = Color(0x99FFFFFF);

  static const Color blue50Alpha060 = Color(0x99EEF0F2);

  static const Color black900Alpha020 = Color(0x33000000);
  static const Color black900Alpha011 = Color(0x1D000000);
  static const Color black900Alpha087 = Color(0xDE000000);
  static const Color black900Alpha060 = Color(0x99000000);

  static const Color greyLabel = Color(0xFFAEAEAE);
  static const Color darkBottomAppBarBackground = Color(0xFF2D2D2D);
  static const Color darkDrawerBackground = Color(0xFF353535);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkChipBackground = Color(0xFF2A2A2A);
  static const Color lightChipBackground = Color(0xFFE5E5E5);
}

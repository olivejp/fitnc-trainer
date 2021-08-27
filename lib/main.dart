import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/service/firebase.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:fitnc_trainer/widget/widgets/firebase.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'constants.dart';

/// Enumération des différents types d'affichage possibles
enum DisplayType { mobile, tablet, desktop }

/// Notifier qui permet de savoir quel est l'affichage courant
class DisplayTypeNotifier with ChangeNotifier {
  DisplayType displayType = DisplayType.mobile;

  void changeDisplay(DisplayType newDisplayType) {
    displayType = newDisplayType;
    notifyListeners();
  }
}

void main() {
  runApp(MultiProvider(providers: <SingleChildWidget>[
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<FirebaseService>(create: (_) => FirebaseService()),
    Provider<ExerciceService>(create: (BuildContext context) => ExerciceService(context)),
    ChangeNotifierProvider<DisplayTypeNotifier>(create: (_) => DisplayTypeNotifier())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DisplayTypeNotifier displayTypeNotifier = Provider.of<DisplayTypeNotifier>(context, listen: false);

    return OKToast(
      position: ToastPosition.bottom,
      child: MaterialApp(
          title: FitnessConstants.appTitle,
          theme: ThemeData(
            primarySwatch: Colors.amber,
            fixTextFieldOutlineLabel: true,
            navigationRailTheme: NavigationRailThemeData(
                backgroundColor: FitnessNcColors.blue100,
                selectedIconTheme: const IconThemeData(color: FitnessNcColors.orange500),
                unselectedIconTheme: const IconThemeData(color: FitnessNcColors.blue800),
                selectedLabelTextStyle:
                    GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.orange500, fontSize: 18, fontWeight: FontWeight.bold),
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
            inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
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
          },
          home: LayoutBuilder(
            builder: (_, BoxConstraints constraints) {
              DisplayType displayType = DisplayType.desktop;
              if (constraints.maxWidth >= 1280) {
                displayType = DisplayType.desktop;
              } else if (constraints.maxWidth >= 800 && constraints.maxWidth <= 1279) {
                displayType = DisplayType.tablet;
              } else {
                displayType = DisplayType.mobile;
              }
              WidgetsBinding.instance?.addPostFrameCallback((Duration timeStamp) {
                displayTypeNotifier.changeDisplay(displayType);
              });
              return const FirebaseWidget();
            },
          )),
    );
  }
}

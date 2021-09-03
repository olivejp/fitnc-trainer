import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/service/firebase-storage.service.dart';
import 'package:fitnc_trainer/service/firebase.service.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitnc_trainer/widget/login/sign-up.page.dart';
import 'package:fitnc_trainer/widget/widgets/firebase.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

import 'constants/constants.dart';

/// Enumération des différents types d'affichage possibles
enum DisplayType { mobile, tablet, desktop }

/// Notifier qui permet de savoir quel est l'affichage courant
class DisplayTypeController extends GetxController {
  Rx<DisplayType> displayType = DisplayType.mobile.obs;

  void changeDisplay(DisplayType newDisplayType) {
    displayType.value = newDisplayType;
  }
}

void main() {
  initServices();
  runApp(MyApp());
}

void initServices() {
  Get.put(AuthService());
  Get.put(FirebaseService());
  Get.put(FirebaseStorageService());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      child: GetMaterialApp(
          title: FitnessConstants.appTitle,
          theme: getThemeData(),
          routes: {
            '/login': (BuildContext context) => LoginPage(
                  callback: (UserCredential userCredential) => Navigator.of(context).pushNamed('/'),
                ),
            '/sign_up': (BuildContext context) => SignUpPage(
                  callback: (UserCredential userCredential) => Navigator.pop(context),
                ),
          },
          home: LayoutDisplayNotifier(builder: (DisplayTypeController displayTypeController) => const FirebaseWidget(), )),
    );
  }

  ThemeData getThemeData() {
    return ThemeData(
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
        headline1: GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.blue600, fontSize: 35, fontWeight: FontWeight.bold),
        headline2: GoogleFonts.alfaSlabOneTextTheme().headline2!.copyWith(color: FitnessNcColors.orange500, fontSize: 25),
        headline3: GoogleFonts.workSansTextTheme().headline3!.copyWith(color: FitnessNcColors.blue800, fontSize: 18),
        headline5: GoogleFonts.workSansTextTheme().headline5!.copyWith(color: FitnessNcColors.black900Alpha011, fontSize: 50),
        headline6: GoogleFonts.workSansTextTheme().headline6!.copyWith(color: FitnessNcColors.black900, fontSize: 15),
        subtitle1: GoogleFonts.workSansTextTheme().subtitle1!.copyWith(color: FitnessNcColors.blue800, fontSize: 15),
        subtitle2: GoogleFonts.roboto(color: FitnessNcColors.orange500, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: FitnessNcColors.white50),
    );
  }
}

class LayoutDisplayNotifier extends StatefulWidget {
  const LayoutDisplayNotifier({Key? key, required this.builder, this.desktopSize = 1280, this.tabletSize = 800,}) : super(key: key);
  final int desktopSize;
  final int tabletSize;
  final Widget Function(DisplayTypeController displayTypeController) builder;

  @override
  State<LayoutDisplayNotifier> createState() => _LayoutDisplayNotifierState();
}

class _LayoutDisplayNotifierState extends State<LayoutDisplayNotifier> {
  final DisplayTypeController displayTypeController = Get.put(DisplayTypeController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        /// Mise à jour du displayType selon la largeur de l'écran.
        DisplayType displayType = DisplayType.desktop;
        if (constraints.maxWidth >= widget.desktopSize) {
          displayType = DisplayType.desktop;
        } else if (constraints.maxWidth >= widget.tabletSize && constraints.maxWidth <= widget.desktopSize - 1) {
          displayType = DisplayType.tablet;
        } else {
          displayType = DisplayType.mobile;
        }
        displayTypeController.changeDisplay(displayType);
        return widget.builder(displayTypeController);
      },
    );
  }
}

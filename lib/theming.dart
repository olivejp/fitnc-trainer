import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Theming {
  static ThemeData getThemeData() {
    return ThemeData(
      colorScheme: const ColorScheme(
        surface: Colors.amber,
        primary: Colors.amber,
        secondary: Colors.amberAccent,
        onSurface: Colors.amber,
        primaryVariant: Colors.yellow,
        onPrimary: Colors.amber,
        background: Colors.grey,
        error: Colors.red,
        onError: Colors.red,
        onBackground: Colors.grey,
        brightness: Brightness.light,
        onSecondary: Colors.amberAccent,
        secondaryVariant: Colors.yellowAccent,
      ),
      primarySwatch: Colors.amber,
      navigationRailTheme: NavigationRailThemeData(
          backgroundColor: FitnessNcColors.blue100,
          selectedIconTheme: const IconThemeData(color: FitnessNcColors.orange500),
          unselectedIconTheme: const IconThemeData(color: FitnessNcColors.blue800),
          selectedLabelTextStyle: GoogleFonts.workSansTextTheme()
              .headline1!
              .copyWith(color: FitnessNcColors.orange500, fontSize: 18, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle:
              GoogleFonts.workSansTextTheme().headline1!.copyWith(color: FitnessNcColors.blue600, fontSize: 18)),
      textTheme: TextTheme(
        headline1: GoogleFonts.workSansTextTheme()
            .headline1!
            .copyWith(color: FitnessNcColors.blue600, fontSize: 35, fontWeight: FontWeight.bold),
        headline2:
            GoogleFonts.alfaSlabOneTextTheme().headline2!.copyWith(color: FitnessNcColors.orange500, fontSize: 25),
        headline3: GoogleFonts.workSansTextTheme().headline3!.copyWith(color: FitnessNcColors.blue800, fontSize: 18),
        headline5:
            GoogleFonts.workSansTextTheme().headline5!.copyWith(color: FitnessNcColors.black900Alpha011, fontSize: 50),
        headline6: GoogleFonts.workSansTextTheme().headline6!.copyWith(color: FitnessNcColors.black900, fontSize: 15),
        subtitle1: GoogleFonts.workSansTextTheme().subtitle1!.copyWith(color: FitnessNcColors.blue800, fontSize: 15),
        subtitle2: GoogleFonts.roboto(color: FitnessNcColors.orange500, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: FitnessNcColors.white50),
    );
  }
}

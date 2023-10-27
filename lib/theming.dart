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
        onPrimary: Colors.amber,
        background: Colors.grey,
        error: Colors.red,
        onError: Colors.red,
        onBackground: Colors.grey,
        brightness: Brightness.light,
        onSecondary: Colors.amberAccent,
      ),
      primarySwatch: Colors.amber,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: FitnessNcColors.blue100,
        selectedIconTheme: const IconThemeData(color: FitnessNcColors.orange500),
        unselectedIconTheme: const IconThemeData(color: FitnessNcColors.blue800),
        selectedLabelTextStyle: GoogleFonts.workSansTextTheme()
            .displayLarge!
            .copyWith(color: FitnessNcColors.orange500, fontSize: 18, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle:
            GoogleFonts.workSansTextTheme().displayLarge!.copyWith(color: FitnessNcColors.blue600, fontSize: 18),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.workSansTextTheme()
            .displayLarge!
            .copyWith(color: FitnessNcColors.blue600, fontSize: 35, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.permanentMarkerTextTheme()
            .displayMedium!
            .copyWith(color: FitnessNcColors.orange500, fontSize: 35),
        displaySmall:
            GoogleFonts.workSansTextTheme().displaySmall!.copyWith(color: FitnessNcColors.blue800, fontSize: 18),
        headlineSmall: GoogleFonts.workSansTextTheme()
            .headlineSmall!
            .copyWith(color: FitnessNcColors.black900Alpha011, fontSize: 50),
        titleLarge: GoogleFonts.workSansTextTheme().titleLarge!.copyWith(color: FitnessNcColors.black900, fontSize: 15),
        titleMedium:
            GoogleFonts.workSansTextTheme().titleMedium!.copyWith(color: FitnessNcColors.blue800, fontSize: 15),
        titleSmall: GoogleFonts.roboto(color: FitnessNcColors.orange500, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: FitnessNcColors.white50),
    );
  }
}

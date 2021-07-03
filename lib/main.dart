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
  final appTitle = 'Les tribus de la Province Nord de la Nouvelle Calédonie';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        routes: {'/add_workout': (context) => AddWorkoutPage()},
        home: FutureBuilder(
            future: bloc.initThridParty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError) {
                return StreamBuilder(
                    stream: bloc.streamUser(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return MyHomePage('FitNc');
                      }
                      return LoginPage(namePage: 'Connexion');
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

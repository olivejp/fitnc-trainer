import 'dart:ui';

import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'calendar.page.dart';
import 'programme/programme.page.dart';
import 'workout/workout.page.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage(this.title);

  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();

  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      bloc.isExpanded = true;
      if (constraints.maxWidth <= 1024) {
        bloc.isExpanded = false;
      }
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Drawer(bloc: bloc),
            Expanded(
              child: GenericContainerWidget(
                opacity: 0.5,
                child: StreamBuilder<Pages>(
                    stream: bloc.currentPageObs,
                    builder: (BuildContext context, AsyncSnapshot<Pages> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == Pages.pageProgramme) {
                          return ProgrammePage();
                        }
                        if (snapshot.data == Pages.pageWorkout) {
                          return WorkoutPage();
                        }
                        if (snapshot.data == Pages.pageExercice) {
                          return ExercicePage();
                        }
                        if (snapshot.data == Pages.pageCalendar) {
                          return CalendarPage();
                        }
                        throw "Aucune page trouvée pour l'index ${snapshot.data}";
                      }
                      return Container();
                    }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class Drawer extends StatefulWidget {
  const Drawer({required this.bloc});

  final MyHomePageBloc bloc;

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> with SingleTickerProviderStateMixin {
  late ValueNotifier<bool> _isExtended;
  late ValueNotifier<int> _selectedIndex;

  @override
  void initState() {
    super.initState();
    _isExtended = ValueNotifier<bool>(widget.bloc.isExpanded);
    _selectedIndex = ValueNotifier<int>(0);

    widget.bloc.currentIsExpanded.listen((bool event) {
      _isExtended.value = event;
    });
  }

  @override
  void dispose() {
    _isExtended.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Icon iconProgramme = Icon(Icons.account_tree);
    const Icon iconWorkout = Icon(Icons.sports_volleyball);
    const Icon iconExercice = Icon(Icons.sports_handball);

    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isExtended,
          builder: (BuildContext context, bool isExtended, Widget? child) {
            return NavigationRail(
              backgroundColor: const Color(0xff385c79),
              extended: isExtended,
              selectedIndex: _selectedIndex.value,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(onPressed: () => _isExtended.value = !_isExtended.value, icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
                ],
              ),
              unselectedIconTheme: IconThemeData(color: Colors.white),
              selectedIconTheme: IconThemeData(color: Colors.amber),
              onDestinationSelected: (int value) => _selectedIndex.value = value,
              unselectedLabelTextStyle: TextStyle(color: Colors.white, fontSize: 18,),
              selectedLabelTextStyle: TextStyle(color: Colors.amber, fontSize: 18,),
              destinations: [
                NavigationRailDestination(
                  label: Text('Programme'),
                  icon: Material(
                    key: ValueKey('fit-programme'),
                    color: Colors.transparent,
                    child: iconProgramme,
                  ),
                ),
                NavigationRailDestination(
                  label: Text('Workout'),
                  icon: Material(
                    key: ValueKey('fit-workout'),
                    color: Colors.transparent,
                    child: iconWorkout,
                  ),
                ),
                NavigationRailDestination(
                  label: Text('Exercice'),
                  icon: Material(
                    key: ValueKey('fit-exercice'),
                    color: Colors.transparent,
                    child: iconExercice,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

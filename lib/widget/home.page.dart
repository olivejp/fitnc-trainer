import 'dart:js';

import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calendar.page.dart';
import 'programme/programme.page.dart';
import 'workout/workout.page.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage(this.title);

  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppBar appbar = AppBar(
      title: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            Icons.sports_volleyball,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          Text(
            title,
            style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 20),
          ),
        ],
      ),
      actions: [
        StreamBuilder<bool>(
            stream: bloc.currentDisplayObs,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return Switch(
                value: snapshot.hasData ? snapshot.data! : false,
                onChanged: (bool value) => bloc.toggleDisplay(),
              );
            }),
        IconButton(
            onPressed: () => bloc.logout(),
            tooltip: 'Se déconnecter',
            icon: Icon(
              Icons.person,
              size: 30,
              color: Theme.of(context).primaryColor,
            )),
      ],
    );
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      bool isExpanded = true;
      if (constraints.maxWidth <= 1024) {
        isExpanded = false;
      }
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Drawer(isExpanded: isExpanded, bloc: bloc),
            Expanded(
              child: getMainPage(),
            ),
          ],
        ),
      );
    });
  }

  /// Retourne le widget correspondant à la page proncipale.
  Widget getMainPage() {
    return GenericContainerWidget(
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
    );
  }
}

class Drawer extends StatefulWidget {
  final bool isExpanded;
  final MyHomePageBloc bloc;

  const Drawer({required this.isExpanded, required this.bloc});

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const BoxDecoration decoration = BoxDecoration(color: Color(0xff385c79));
    const Duration duration = Duration(milliseconds: 300);
    const Widget textProgramme = Text('Programme', overflow: TextOverflow.clip);
    const Widget textWorkout = Text('Workout', overflow: TextOverflow.clip);
    const Widget textExercice = Text('Exercice', overflow: TextOverflow.clip);
    const Widget textCalendrier = Text('Calendrier', overflow: TextOverflow.clip);
    const Widget textDisconnect = Text('Se déconnecter', overflow: TextOverflow.clip);

    return AnimatedContainer(
      width: widget.isExpanded ? 200 : 80,
      decoration: decoration,
      duration: duration,
      child: ListTileTheme(
        iconColor: Colors.white,
        textColor: Colors.white,
        child: StreamBuilder<Pages>(
            stream: widget.bloc.currentPageObs,
            builder: (BuildContext context, AsyncSnapshot<Pages> snapshot) {
              return Column(
                children: <Widget>[
                  Flexible(
                    child: ListTileTheme(
                      minVerticalPadding: 15,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      child: IconTheme(
                        data: const IconThemeData(size: 25),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () => widget.bloc.changePage(Pages.pageProgramme),
                              title: textProgramme,
                              leading: const Icon(Icons.account_tree),
                              selected: snapshot.data == Pages.pageProgramme,
                            ),
                            ListTile(
                              onTap: () => widget.bloc.changePage(Pages.pageWorkout),
                              title: textWorkout,
                              leading: const Icon(Icons.sports_volleyball),
                              selected: snapshot.data == Pages.pageWorkout,
                            ),
                            ListTile(
                              onTap: () => widget.bloc.changePage(Pages.pageExercice),
                              title: textExercice,
                              leading: const Icon(Icons.sports_handball),
                              selected: snapshot.data == Pages.pageExercice,
                            ),
                            ListTile(
                              onTap: () => widget.bloc.changePage(Pages.pageCalendar),
                              title: textCalendrier,
                              leading: const Icon(Icons.calendar_today_rounded),
                              selected: snapshot.data == Pages.pageCalendar,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      const Divider(height: 2.0),
                      ListTile(
                        onTap: () => widget.bloc.logout(),
                        minVerticalPadding: 20,
                        title: textDisconnect,
                        leading: const Icon(Icons.do_disturb_outlined),
                      ),
                    ],
                  ))
                ],
              );
            }),
      ),
    );
  }
}

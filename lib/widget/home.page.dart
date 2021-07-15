import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.create.page.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.create.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

import 'calendar.page.dart';
import 'programme/programme.create.page.dart';
import 'programme/programme.page.dart';
import 'workout/workout.page.dart';

class MyHomePage extends StatelessWidget {
  static final int PAGE_WORKOUT = 0;
  static final int PAGE_EXERCICE = 1;
  static final int PAGE_CALENDAR = 2;
  static final int PAGE_PROGRAMME = 3;
  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();
  final String title;

  MyHomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget body;
      if (constraints.maxWidth > 900) {
        body = Row(
          children: [
            getLeftDrawer(),
            Expanded(child: getMainPage()),
          ],
        );
      } else {
        body = getMainPage();
      }

      Widget bottomAppBar;
      if (constraints.maxWidth > 900) {
        bottomAppBar = BottomAppBar();
      } else {
        bottomAppBar = StreamBuilder<int>(
            stream: bloc.currentPageObs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return BottomNavigationBar(
                  unselectedItemColor: Color(Colors.grey.value),
                  items: [
                    BottomNavigationBarItem(
                      label: 'Workout',
                      icon: Icon(Icons.sports_volleyball),
                    ),
                    BottomNavigationBarItem(
                      label: 'Exercices',
                      icon: Icon(Icons.sports_handball_outlined),
                    )
                  ],
                  onTap: (value) => bloc.changePage(value),
                  currentIndex: snapshot.data!,
                  backgroundColor: Color(Colors.black87.value),
                );
              } else {
                return Container();
              }
            });
      }

      return Scaffold(
        appBar: AppBar(
          title: Wrap(
            children: [
              Icon(
                Icons.sports_volleyball,
                color: Color(Colors.amber.value),
              ),
              Text(
                this.title,
                style: GoogleFonts.alfaSlabOne(color: Color(Colors.amber.value), fontSize: 35),
              ),
            ],
          ),
          actions: [
            StreamBuilder<bool>(
                stream: bloc.currentDisplayObs,
                builder: (context, snapshot) {
                  return Switch(
                    value: snapshot.hasData ? snapshot.data! : false,
                    onChanged: (value) => bloc.toggleDisplay(),
                  );
                }),
            IconButton(
                onPressed: () => bloc.logout(),
                tooltip: 'Se déconnecter',
                icon: Icon(
                  Icons.person,
                  size: 30,
                  color: Color(Colors.amber.value),
                )),
          ],
        ),
        body: body,
        bottomNavigationBar: bottomAppBar,
        floatingActionButton: StreamBuilder(
          stream: bloc.currentPageObs,
          builder: (context, snapshot) {
            if (snapshot.data == PAGE_PROGRAMME) {
              return FloatingActionButton.extended(
                onPressed: () => ProgrammeCreatePage.showCreate(context),
                label: Text(
                  'Créer un programme',
                  style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 25.0,
                ),
              );
            }
            if (snapshot.data == PAGE_WORKOUT) {
              return FloatingActionButton.extended(
                onPressed: () => WorkoutCreatePage.showCreate(context),
                label: Text(
                  'Créer un workout',
                  style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 25.0,
                ),
              );
            }
            if (snapshot.data == PAGE_EXERCICE) {
              return FloatingActionButton.extended(
                onPressed: () => ExerciceCreatePage.showCreate(context),
                label: Text(
                  'Créer un exercice',
                  style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 20.0,
                ),
              );
            }
            if (snapshot.data == PAGE_CALENDAR) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_exercice');
                },
                label: Text(
                  'Ajouter un exercice',
                  style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 20.0,
                ),
              );
            }
            return Container();
          },
        ),
      );
    });
  }

  StreamBuilder<int> getMainPage() {
    return StreamBuilder<int>(
      stream: bloc.currentPageObs,
      builder: (context, snapshot) {
        if (snapshot.data == PAGE_PROGRAMME) {
          return ProgrammePage();
        }
        if (snapshot.data == PAGE_WORKOUT) {
          return WorkoutPage();
        }
        if (snapshot.data == PAGE_EXERCICE) {
          return ExercicePage();
        }
        if (snapshot.data == PAGE_CALENDAR) {
          return CalendarPage();
        }
        return Text('Aie');
      },
    );
  }

  Widget getLeftDrawer() {
    return LimitedBox(
      maxWidth: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          boxShadow: [],
        ),
        child: ListTileTheme(
          iconColor: Color(Colors.white.value),
          textColor: Color(Colors.white.value),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: StreamBuilder<int>(
              stream: bloc.currentPageObs,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => bloc.changePage(PAGE_PROGRAMME),
                            minVerticalPadding: 20,
                            title: Text('Programme'),
                            leading: Icon(Icons.account_tree),
                            selected: snapshot.data == PAGE_PROGRAMME,
                          ),
                          Divider(
                            height: 2,
                          ),
                          ListTile(
                            onTap: () => bloc.changePage(PAGE_WORKOUT),
                            minVerticalPadding: 20,
                            title: Text('Workout'),
                            leading: Icon(Icons.sports_volleyball),
                            selected: snapshot.data == PAGE_WORKOUT,
                          ),

                          Divider(
                            height: 2,
                          ),
                          ListTile(
                            onTap: () => bloc.changePage(PAGE_EXERCICE),
                            minVerticalPadding: 20,
                            title: Text('Exercice'),
                            leading: Icon(Icons.sports_handball),
                            selected: snapshot.data == PAGE_EXERCICE,
                          ),
                          Divider(
                            height: 2,
                          ),
                          ListTile(
                            onTap: () => bloc.changePage(PAGE_CALENDAR),
                            minVerticalPadding: 20,
                            title: Text('Calendrier'),
                            leading: Icon(Icons.calendar_today_rounded),
                            selected: snapshot.data == PAGE_CALENDAR,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Divider(
                          height: 2.0,
                        ),
                        ListTile(
                          onTap: () => bloc.logout(),
                          minVerticalPadding: 20,
                          title: Text('Se déconnecter'),
                          trailing: Icon(Icons.do_disturb_outlined),
                        ),
                      ],
                    ))
                  ],
                );
              }),
        ),
      ),
    );
  }
}

import 'package:fitnc_trainer/bloc/my-home-page.bloc.dart';
import 'package:fitnc_trainer/widget/abonne.page.dart';
import 'package:fitnc_trainer/widget/workout.page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatelessWidget {
  static final int PAGE_WORKOUT = 0;
  static final int PAGE_ABONNE = 1;
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
            Flexible(
              flex: 1,
              child: getLeftDrawer(),
            ),
            Flexible(
              flex: 5,
              child: getMainPage(),
            ),
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
                      label: 'Abonnes',
                      icon: Icon(Icons.group),
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
                style: GoogleFonts.alfaSlabOne(
                    color: Color(Colors.amber.value), fontSize: 35),
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
            if (snapshot.data == PAGE_WORKOUT) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_workout');
                },
                label: Text(
                  'Ajouter un workout',
                  style: GoogleFonts.roboto(
                      fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 25.0,
                ),
              );
            }
            if (snapshot.data == PAGE_ABONNE) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_abonne');
                },
                label: Text(
                  'Ajouter un abonné',
                  style: GoogleFonts.roboto(
                      fontSize: 15, color: Color(Colors.white.value)),
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
      builder: (context, snapshot) {
        if (snapshot.data == PAGE_WORKOUT) {
          return WorkoutPage();
        }
        if (snapshot.data == PAGE_ABONNE) {
          return AbonnePage();
        }
        return Text('Aie');
      },
      stream: bloc.currentPageObs,
    );
  }

  Container getLeftDrawer() {
    return Container(
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
                  ListTile(
                    onTap: () => bloc.changePage(PAGE_WORKOUT),
                    subtitle: Text('Gérer vos entraînements'),
                    title: Text('Workout'),
                    trailing: Icon(Icons.sports_volleyball),
                    selected: snapshot.data == PAGE_WORKOUT,
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => bloc.changePage(PAGE_ABONNE),
                    subtitle: Text('Gérer vos abonnés'),
                    title: Text('Abonnés'),
                    trailing: Icon(Icons.group),
                    selected: snapshot.data == PAGE_ABONNE,
                  ),
                ],
              );
            }),
      ),
    );
  }
}

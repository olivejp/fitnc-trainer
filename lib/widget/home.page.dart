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
      return Scaffold(
        appBar: AppBar(
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.sports_volleyball,
                color: Color(Colors.amber.value),
                size: 20,
              ),
              Text(
                this.title,
                style: GoogleFonts.alfaSlabOne(color: Color(Colors.amber.value), fontSize: 20),
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
        body: Row(
          children: [
            getDrawer(constraints),
            Expanded(child: getMainPage()),
          ],
        ),
      );
    });
  }

  Widget getMainPage() {
    return GenericContainerWidget(
      opacity: 0.8,
      child: StreamBuilder<int>(
          stream: bloc.currentPageObs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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
            }
            return Container();
          }),
    );
  }

  Widget getDrawer(BoxConstraints constraints) {
    double maxWidth = 200;
    bool isExpanded = true;
    if (constraints.maxWidth <= 1024) {
      maxWidth = 60;
      isExpanded = false;
    }

    return LimitedBox(
      maxWidth: maxWidth,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
        ),
        child: ListTileTheme(
          iconColor: Color(Colors.white.value),
          textColor: Color(Colors.white.value),
          child: StreamBuilder<int>(
              stream: bloc.currentPageObs,
              builder: (context, snapshot) {
                if (isExpanded) {
                  return Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: ListTileTheme(
                          minVerticalPadding: 15,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          child: IconTheme(
                            data: IconThemeData(size: 18),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () => bloc.changePage(PAGE_PROGRAMME),
                                  title: Text('Programme'),
                                  leading: Icon(Icons.account_tree),
                                  selected: snapshot.data == PAGE_PROGRAMME,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(PAGE_WORKOUT),
                                  title: Text('Workout'),
                                  leading: Icon(Icons.sports_volleyball),
                                  selected: snapshot.data == PAGE_WORKOUT,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(PAGE_EXERCICE),
                                  title: Text('Exercice'),
                                  leading: Icon(Icons.sports_handball),
                                  selected: snapshot.data == PAGE_EXERCICE,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(PAGE_CALENDAR),
                                  title: Text('Calendrier'),
                                  leading: Icon(Icons.calendar_today_rounded),
                                  selected: snapshot.data == PAGE_CALENDAR,
                                ),
                              ],
                            ),
                          ),
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
                            leading: Icon(Icons.do_disturb_outlined),
                          ),
                        ],
                      ))
                    ],
                  );
                } else {
                  return IconTheme(
                    data: IconThemeData(color: Colors.amber, size: 25),
                    child: Column(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(onPressed: () => bloc.changePage(PAGE_PROGRAMME), icon: Icon(Icons.account_tree)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(onPressed: () => bloc.changePage(PAGE_WORKOUT), icon: Icon(Icons.sports_volleyball)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(onPressed: () => bloc.changePage(PAGE_EXERCICE), icon: Icon(Icons.sports_handball)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(onPressed: () => bloc.changePage(PAGE_CALENDAR), icon: Icon(Icons.calendar_today_rounded)),
                                ),
                              ],
                            )),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: IconButton(onPressed: () => bloc.logout(), icon: Icon(Icons.do_disturb_outlined)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}

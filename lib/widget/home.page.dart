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

  static const int pageWorkout = 0;
  static const int pageExercice = 1;
  static const int pageCalendar = 2;
  static const int pageProgramme = 3;

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
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            getDrawer(constraints),
            Expanded(child: getMainPage(),),
          ],
        ),
      );
    });
  }

  /// Retourne le widget correspondant à la page proncipale.
  Widget getMainPage() {
    return GenericContainerWidget(
      opacity: 0.5,
      child: StreamBuilder<int>(
          stream: bloc.currentPageObs,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == pageProgramme) {
                return ProgrammePage();
              }
              if (snapshot.data == pageWorkout) {
                return WorkoutPage();
              }
              if (snapshot.data == pageExercice) {
                return ExercicePage();
              }
              if (snapshot.data == pageCalendar) {
                return CalendarPage();
              }
              throw "Aucune page trouvée pour l'index ${snapshot.data}";
            }
            return Container();
          }),
    );
  }

  /// Retourn un widget correspondant au Drawer.
  Widget getDrawer(BoxConstraints constraints) {
    double maxWidth = 200;
    bool isExpanded = true;
    if (constraints.maxWidth <= 1024) {
      maxWidth = 80;
      isExpanded = false;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff385c79),
      ),
      child: ListTileTheme(
        iconColor: Colors.white,
        textColor: Colors.white,
        child: StreamBuilder<int>(
            stream: bloc.currentPageObs,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return AnimatedCrossFade(
                crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
                firstChild: SizedBox(
                  width: maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        flex: 1,
                        child: ListTileTheme(
                          minVerticalPadding: 15,
                          iconColor: Colors.white,
                          textColor: Colors.white,
                          child: IconTheme(
                            data: const IconThemeData(size: 18),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () => bloc.changePage(pageProgramme),
                                  title: Text('Programme'),
                                  leading: Icon(Icons.account_tree),
                                  selected: snapshot.data == pageProgramme,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(pageWorkout),
                                  title: Text('Workout'),
                                  leading: Icon(Icons.sports_volleyball),
                                  selected: snapshot.data == pageWorkout,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(pageExercice),
                                  title: Text('Exercice'),
                                  leading: Icon(Icons.sports_handball),
                                  selected: snapshot.data == pageExercice,
                                ),
                                ListTile(
                                  onTap: () => bloc.changePage(pageCalendar),
                                  title: Text('Calendrier'),
                                  leading: Icon(Icons.calendar_today_rounded),
                                  selected: snapshot.data == pageCalendar,
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
                          Divider(height: 2.0),
                          ListTile(
                            onTap: () => bloc.logout(),
                            minVerticalPadding: 20,
                            title: Text('Se déconnecter'),
                            leading: Icon(Icons.do_disturb_outlined),
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
                secondChild: SizedBox(
                  width: maxWidth,
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white, size: 25),
                    child: Column(
                        mainAxisSize : MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(
                                    onPressed: () => bloc.changePage(pageProgramme),
                                    icon: Icon(Icons.account_tree),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(
                                    onPressed: () => bloc.changePage(pageWorkout),
                                    icon: Icon(Icons.sports_volleyball),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(
                                    onPressed: () => bloc.changePage(pageExercice),
                                    icon: Icon(Icons.sports_handball),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: IconButton(
                                    onPressed: () => bloc.changePage(pageCalendar),
                                    icon: Icon(Icons.calendar_today_rounded),
                                  ),
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
                  ),
                ),
              );
              // if (isExpanded) {
              //   return Column(
              //     children: [
              //       Flexible(
              //         flex: 1,
              //         child: ListTileTheme(
              //           minVerticalPadding: 15,
              //           iconColor: Colors.white,
              //           textColor: Colors.white,
              //           child: IconTheme(
              //             data: const IconThemeData(size: 18),
              //             child: Column(
              //               children: [
              //                 ListTile(
              //                   onTap: () => bloc.changePage(pageProgramme),
              //                   title: Text('Programme'),
              //                   leading: Icon(Icons.account_tree),
              //                   selected: snapshot.data == pageProgramme,
              //                 ),
              //                 ListTile(
              //                   onTap: () => bloc.changePage(pageWorkout),
              //                   title: Text('Workout'),
              //                   leading: Icon(Icons.sports_volleyball),
              //                   selected: snapshot.data == pageWorkout,
              //                 ),
              //                 ListTile(
              //                   onTap: () => bloc.changePage(pageExercice),
              //                   title: Text('Exercice'),
              //                   leading: Icon(Icons.sports_handball),
              //                   selected: snapshot.data == pageExercice,
              //                 ),
              //                 ListTile(
              //                   onTap: () => bloc.changePage(pageCalendar),
              //                   title: Text('Calendrier'),
              //                   leading: Icon(Icons.calendar_today_rounded),
              //                   selected: snapshot.data == pageCalendar,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       Flexible(
              //           child: Column(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //           Divider(height: 2.0),
              //           ListTile(
              //             onTap: () => bloc.logout(),
              //             minVerticalPadding: 20,
              //             title: Text('Se déconnecter'),
              //             leading: Icon(Icons.do_disturb_outlined),
              //           ),
              //         ],
              //       ))
              //     ],
              //   );
              // } else {
              //   return IconTheme(
              //     data: const IconThemeData(color: Colors.white, size: 25),
              //     child: Column(
              //       children: <Widget>[
              //         Flexible(
              //             flex: 1,
              //             child: Column(
              //               children: [
              //                 Padding(
              //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: IconButton(
              //                     onPressed: () => bloc.changePage(pageProgramme),
              //                     icon: Icon(Icons.account_tree),
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: IconButton(
              //                     onPressed: () => bloc.changePage(pageWorkout),
              //                     icon: Icon(Icons.sports_volleyball),
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: IconButton(
              //                     onPressed: () => bloc.changePage(pageExercice),
              //                     icon: Icon(Icons.sports_handball),
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: IconButton(
              //                     onPressed: () => bloc.changePage(pageCalendar),
              //                     icon: Icon(Icons.calendar_today_rounded),
              //                   ),
              //                 ),
              //               ],
              //             )),
              //         Flexible(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.end,
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: IconButton(onPressed: () => bloc.logout(), icon: Icon(Icons.do_disturb_outlined)),
              //               ),
              //             ],
              //           ),
              //         )
              //       ],
              //     ),
              //   );
              // }
            }),
      ),
    );
  }
}

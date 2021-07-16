import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.create.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:page_transition/page_transition.dart';

class WorkoutPage extends StatefulWidget {
  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();

  WorkoutPage({Key? key}) : super(key: key);

  @override
  _WorkoutPageState createState() {
    return new _WorkoutPageState();
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  _WorkoutPageState();

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
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
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(
                        'Workouts',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      )),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Recherche...',
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Workout?>>(
                stream: widget.bloc.getStreamWorkout(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                      return Center(child: Text('Aucun workout trouvé.'));
                    } else {
                      List<Workout?> listWorkout = snapshot.data!;
                      return StreamBuilder<bool>(
                          stream: widget.homePageBloc.currentDisplayObs,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data != null && snapshot.data == true) {
                                return getListView(listWorkout);
                              } else {
                                return getGridView(listWorkout);
                              }
                            }
                            return Container();
                          });
                    }
                  }
                  return LoadingBouncingGrid.circle();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGridView(List<Workout?> listWorkout) {
    return LayoutBuilder(builder: (context, constraints) {
      int nbColumns = 1;
      if (constraints.maxWidth > 1200) {
        nbColumns = 6;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 3;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 2;
      }

      return GridView.count(
        padding: const EdgeInsets.all(10.0),
        childAspectRatio: 13 / 9,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listWorkout.map((workout) {
          if (workout != null) {
            return InkWell(
                splashColor: Color(Colors.amber.value),
                hoverColor: Color(Colors.amber.value),
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.push(
                    context,
                    PageTransition(
                        duration: Duration.zero,
                        reverseDuration: Duration.zero,
                        type: PageTransitionType.fade,
                        child: WorkoutUpdatePage(workout: workout))),
                child: getGridCard(workout));
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  Card getGridCard(Workout workout) {
    Widget firstChild;
    if (workout.imageUrl != null) {
      firstChild = Image.network(workout.imageUrl!, fit: BoxFit.cover);
    } else {
      firstChild = Container(decoration: BoxDecoration(color: Color(Colors.amber.value)));
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: firstChild),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(workout.name, style: TextStyle(fontSize: 15)),
                ),
                getDeleteButton(context, workout)
              ],
            ),
            flex: 1,
          ),
        ],
      ),
      elevation: 2,
    );
  }

  ListView getListView(List<Workout?> listWorkout) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(height: 2.0),
        itemCount: listWorkout.length,
        itemBuilder: (context, index) {
          Workout workout = listWorkout[index] as Workout;
          Widget leading = (workout.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(workout.imageUrl!)) : CircleAvatar();
          Widget subtitle = workout.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((workout.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(workout.name),
            subtitle: subtitle,
            trailing: Wrap(children: [getDeleteButton(context, workout)]),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      duration: Duration.zero,
                      reverseDuration: Duration.zero,
                      type: PageTransitionType.fade,
                      child: WorkoutUpdatePage(workout: workout)));
            },
          );
        });
  }

  IconButton getDeleteButton(BuildContext context, Workout workout) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Etes vous sûr de vouloir supprimer ce workout?'),
            actions: [
              TextButton(onPressed: () => deleteWorkout(workout, context), child: Text('Oui')),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
            ],
          ),
        );
      },
      icon: Icon(Icons.delete, color: Colors.amber, size: 24),
    );
  }

  void deleteWorkout(Workout workout, BuildContext context) {
    widget.bloc.deleteWorkout(workout).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

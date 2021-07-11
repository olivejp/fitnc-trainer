import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/my-home-page.bloc.dart';
import 'package:fitnc_trainer/bloc/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/widget/workout_update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

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
    return StreamBuilder<List<Workout?>>(
      stream: widget.bloc.getStreamWorkout(),
      builder: (context, snapshot) {
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
          // return getListView(snapshot.data);
        }
      },
    );
  }

  Widget getGridView(List<Workout?> listWorkout) {
    return LayoutBuilder(builder: (context, constraints) {
      int nbColumns = 1;
      if (constraints.maxWidth > 1200) {
        nbColumns = 5;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 3;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 2;
      }

      return GridView.count(
        padding: const EdgeInsets.all(20.0),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        crossAxisCount: nbColumns,
        children: listWorkout.map((workout) {
          Widget leading = widget.bloc.firestorageService.getAvatarThumbnail(widget.bloc.getUrl(workout!), workout.imageUrl);

          Widget description = workout.description != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    workout.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Container();

          Widget subtitle = workout.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((workout.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          if (workout != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutUpdatePage(
                            workout: workout,
                          ))),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                      leading: leading,
                      title: Text(workout.name),
                      subtitle: subtitle,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: description,
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        getDeleteButton(context, workout),
                      ],
                    ),
                  ],
                ),
                elevation: 2,
              ),
            );
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  ListView getListView(List<Workout?> listWorkout) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: listWorkout.length,
        itemBuilder: (context, index) {
          Workout workout = listWorkout[index] as Workout;
          Widget leading = widget.bloc.firestorageService.getAvatarThumbnail(widget.bloc.getUrl(workout), workout.imageUrl);

          Widget subtitle = workout.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((workout.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(workout.name),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, workout)],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutUpdatePage(
                            workout: workout,
                          )));
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
      icon: Icon(
        Icons.delete,
        color: Color(Colors.amber.value),
        size: 24,
      ),
    );
  }

  void deleteWorkout(Workout workout, BuildContext context) {
    widget.bloc.deleteWorkout(workout).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

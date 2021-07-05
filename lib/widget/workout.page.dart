import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/add_workout.bloc.dart';
import 'package:fitnc_trainer/bloc/my-home-page.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WorkoutPage extends StatefulWidget {
  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final AddWorkoutBloc bloc = AddWorkoutBloc.getInstance();

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
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: StreamBuilder<List<Workout?>>(
        stream: widget.bloc.getStreamWorkout(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              (snapshot.hasData && snapshot.data!.isEmpty)) {
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
      ),
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
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        crossAxisCount: nbColumns,
        children: listWorkout.map((workout) {
          Widget image = workout?.imageUrl != null
              ? Image.network(workout!.imageUrl!, fit: BoxFit.fitWidth)
              : Expanded(
                  child: Container(
                      decoration:
                          BoxDecoration(color: Color(Colors.amber.value))));

          Widget description = workout?.description != null
              ? Text(workout!.description!)
              : Container();

          Widget subtitle = workout?.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                  (workout!.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          if (workout != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => updateWorkout(context, workout),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.sports_volleyball,
                        color: Color(Colors.amber.value),
                      ),
                      title: Text(workout.name),
                      subtitle: subtitle,
                    ),
                    Padding(padding: EdgeInsets.all(16.0), child: description),
                    ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        getDeleteButton(context, workout),
                      ],
                    ),
                    image,
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
        itemCount: listWorkout != null ? listWorkout.length : 0,
        itemBuilder: (context, index) {
          Workout workout = listWorkout[index] as Workout;
          Widget leading = (workout.imageUrl != null)
              ? CircleAvatar(foregroundImage: NetworkImage(workout.imageUrl!))
              : CircleAvatar();

          Widget subtitle = workout.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                  (workout.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            leading: leading,
            title: Text(workout.name),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, workout)],
            ),
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
              TextButton(
                  onPressed: () => deleteWorkout(workout, context),
                  child: Text('Oui')),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'))
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

  void updateWorkout(BuildContext context, Workout workout) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Modifier le workout'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 500, maxWidth: 1200),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Nom',
                              hintStyle: GoogleFonts.roboto(fontSize: 20)),
                          onChanged: (value) => workout.name = value,
                          initialValue: workout.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez rentrer un nom pour ce workout';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Description',
                              hintStyle: GoogleFonts.roboto(fontSize: 20)),
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 20,
                          maxLength: 2000,
                          onChanged: (value) => workout.description = value,
                          initialValue: workout.description,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez rentrer un nom pour ce workout';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      child: Text('Modifier'),
                      onPressed: () {
                        widget.bloc.update(workout);
                        Navigator.pop(context);
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      child: Text('Annuler'),
                      onPressed: () => Navigator.pop(context)),
                )
              ],
            ));
  }

  void deleteWorkout(Workout workout, BuildContext context) {
    widget.bloc
        .deleteWorkout(workout)
        .then((value) => Navigator.pop(context))
        .catchError((error) => print(error.toString()));
  }
}

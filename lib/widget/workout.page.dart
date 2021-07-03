import 'package:fitnc_trainer/bloc/add_workout.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  final AddWorkoutBloc bloc = AddWorkoutBloc.getInstance();

  WorkoutPage({Key key}) : super(key: key);

  @override
  _WorkoutPageState createState() {
    return new _WorkoutPageState();
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  _WorkoutPageState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: StreamBuilder<List<Workout>>(
        stream: widget.bloc.getStreamWorkout(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text('Aucun workout trouvé.'));
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Workout workout = snapshot.data[index];
                  return ListTile(
                    title: Text(workout.name),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Supprimer',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    'Etes vous sûr de vouloir supprimer ce Workout?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        widget.bloc
                                            .deleteWorkout(workout)
                                            .then((value) =>
                                                Navigator.pop(context))
                                            .catchError((error) =>
                                                print(error.toString()));
                                      },
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
                            color: Color(Colors.red.value),
                            size: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Mettre à jour',
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Modifier le Workout'),
                                      content: ListTile(
                                        title: TextFormField(
                                          onChanged: (value) =>
                                              workout.name = value,
                                          initialValue: workout.name,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez rentrer un nom pour ce Workout';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              widget.bloc.update(workout);
                                              Navigator.pop(context);
                                            },
                                            child: Text('Modifier'))
                                      ],
                                    ));
                          },
                          icon: Icon(
                            Icons.file_copy_outlined,
                            color: Color(Colors.blue.value),
                            size: 24,
                          ),
                        )
                      ],
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}

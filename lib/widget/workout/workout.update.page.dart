import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutUpdatePage extends StatefulWidget {
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();
  final Workout workout;

  WorkoutUpdatePage({Key? key, required this.workout}) : super(key: key) {
    bloc.init(workout);
  }

  @override
  _WorkoutUpdatePageState createState() {
    return new _WorkoutUpdatePageState();
  }
}

class _WorkoutUpdatePageState extends State<WorkoutUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _WorkoutUpdatePageState();

  @override
  Widget build(BuildContext context) {
    WorkoutUpdateBloc bloc = widget.bloc;
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: ButtonBar(children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.clear),
            tooltip: 'Annuler',
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                bloc.saveWorkout().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            child: Icon(Icons.check),
          ),
        ]),
        body: GenericUpdateWidget(
            maximumWidth: 1680,
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StorageStreamImageWidget(
                          onSaved: (storagePair) => bloc.setStoragePair(storagePair),
                          streamInitialStoragePair: bloc.obsStoragePair,
                          onDeleted: (storagePair) => bloc.setStoragePair(null),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                initialValue: bloc.getWorkout()?.name,
                                autofocus: true,
                                onChanged: (value) => bloc.setName(value),
                                decoration: InputDecoration(helperText: 'Nom du workout'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le nom du workout est obligatoire.';
                                  }
                                  return null;
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<String>(
                      decoration: InputDecoration(helperText: 'Type d\'entrainement'),
                      icon: Icon(Icons.timer),
                      onChanged: (String? value) => bloc.setTimerType(value),
                      value: bloc.getWorkout()?.timerType,
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            'Aucun type de timer',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          value: null,
                        ),
                        DropdownMenuItem(
                          child: Text('AMRAP'),
                          value: 'AMRAP',
                        ),
                        DropdownMenuItem(
                          child: Text('EMOM'),
                          value: 'EMOM',
                        ),
                        DropdownMenuItem(
                          child: Text('For Time'),
                          value: 'For Time',
                        ),
                      ]),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      initialValue: bloc.getWorkout()?.description,
                      maxLength: 2000,
                      minLines: 5,
                      maxLines: 20,
                      onChanged: (value) => bloc.setDescription(value),
                      decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Instructions (optionel)'),
                    ),
                  ),
                  LimitedBox(
                    maxWidth: 1200,
                    maxHeight: 500,
                    child: Row(
                      children: [
                        Expanded(
                          child: WorkoutSetPage(
                            workout: widget.workout,
                          ),
                        ),
                      ],
                    ),
                  )
                ]))));
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: [
        Tab(
          child: Column(
            children: [
              Icon(
                Icons.file_copy,
                color: Color(Colors.amber.value),
              ),
              Text(
                'Description',
                style: TextStyle(color: Colors.amber),
              )
            ],
          ),
        ),
        Tab(
          child: Column(
            children: [
              Icon(
                Icons.sports_volleyball,
                color: Colors.amber,
              ),
              Text(
                'Exercices',
                style: TextStyle(color: (Colors.amber)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget getSecondPanel() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shadowColor: Colors.black,
              clipBehavior: Clip.antiAlias,
              color: Color(Colors.white.value).withOpacity(0.85),
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamDropdownButton<Exercice>(
                          dropdownKey: widget.bloc.dropdownKey,
                          onChanged: (exerciceSelected) => widget.bloc.setExercice(exerciceSelected),
                          icon: Icon(Icons.arrow_downward),
                          initialValue: null,
                          stream: widget.bloc.trainersService.getExerciceStreamDropdownMenuItem(),
                        ),
                        StreamBuilder(
                          stream: widget.bloc.obsTypeExercice,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                if (snapshot.data == 'REPS_WEIGHT') {
                                  return getRepsWeightDisplay(context);
                                }
                                if (snapshot.data == 'REPS_ONLY') {
                                  return getRepsOnlyDisplay();
                                }
                                if (snapshot.data == 'TIME') {
                                  return getTimeDisplay();
                                }
                              }
                            }
                            return Container();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: TextFormField(
                            key: widget.bloc.consigneKey,
                            minLines: 5,
                            maxLines: 20,
                            initialValue: null,
                            autofocus: true,
                            onChanged: (value) => widget.bloc.setConsigne(value),
                            decoration: InputDecoration(helperText: 'Consigne - optionel', border: OutlineInputBorder()),
                          ),
                        )
                      ],
                    ),
                    Column(children: [
                      FloatingActionButton.extended(
                        onPressed: () => widget.bloc.saveSet(),
                        label: Text('Ajouter exercice'),
                        icon: Icon(Icons.add),
                      )
                    ])
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shadowColor: Colors.black,
              clipBehavior: Clip.antiAlias,
              color: Color(Colors.white.value).withOpacity(0.85),
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: StreamBuilder<List<WorkoutSet?>>(
                stream: widget.bloc.listenToWorkoutStep(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    List<WorkoutSet?> listSet = snapshot.data!;
                    return Column(
                      children: listSet
                          .map((set) => ListTile(
                                title: Text(set!.uidExercice!),
                              ))
                          .toList(),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row getTimeDisplay() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
              initialValue: '',
              autofocus: true,
              onChanged: (value) => print(value),
              decoration: InputDecoration(helperText: 'Temps'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merci de renseigner le temps.';
                }
                return null;
              }),
        ),
      ],
    );
  }

  Row getRepsOnlyDisplay() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
              initialValue: '',
              autofocus: true,
              onChanged: (value) => print(value),
              decoration: InputDecoration(helperText: 'Reps'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merci de renseigner le nombre de répétition.';
                }
                return null;
              }),
        ),
      ],
    );
  }

  Column getRepsWeightDisplay(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => widget.bloc.addLine(),
              child: Text('Ajouter un set'),
            ),
          ],
        ),
        StreamBuilder<List<Line>?>(
          stream: widget.bloc.obsLines,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                shrinkWrap: true,
                itemCount: widget.bloc.set.lines.length,
                itemBuilder: (context, index) {
                  Line re = widget.bloc.set.lines.elementAt(index);
                  return Row(
                    key: ObjectKey(re),
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            initialValue: re.reps,
                            decoration: InputDecoration(helperText: 'Répétitions'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            initialValue: re.weight,
                            decoration: InputDecoration(helperText: 'Poids'),
                          ),
                        ),
                      ),
                      IconButton(onPressed: () => widget.bloc.deleteLine(re), icon: Icon(Icons.delete)),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  );
                },
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  AlertDialog getRepsWeightDialog(BuildContext context) {
    widget.bloc.setRepsWeightType('SETS');
    return AlertDialog(
      title: Text('Ajouter un set'),
      content: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: '',
                autofocus: true,
                onChanged: (value) => widget.bloc.setRepsWeightReps(value),
                decoration: InputDecoration(helperText: 'Reps'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merci de renseigner le nombre de répétition.';
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: '',
                autofocus: true,
                onChanged: (value) => widget.bloc.setRepsWeightWeight(value),
                decoration: InputDecoration(helperText: 'Weight'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merci de renseigner le poids.';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  widget.bloc.addLine();
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              widget.bloc.addLine();
              Navigator.pop(context);
            },
            child: Text('OK')),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
      ],
    );
  }

  AlertDialog getReposDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un depos'),
      content: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: '',
              autofocus: true,
              onChanged: (value) => widget.bloc.line.reps = value,
              decoration: InputDecoration(helperText: 'Repos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merci de renseigner le nombre de secondes de repos.';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                widget.bloc.addLine();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              widget.bloc.addLine();
              Navigator.pop(context);
            },
            child: Text('OK')),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
      ],
    );
  }
}

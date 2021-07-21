import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutUpdatePage extends StatefulWidget {
  WorkoutUpdatePage({Key? key, required this.workout}) : super(key: key) {
    bloc.init(workout);
  }

  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();
  final Workout workout;

  @override
  _WorkoutUpdatePageState createState() {
    return _WorkoutUpdatePageState();
  }
}

class _WorkoutUpdatePageState extends State<WorkoutUpdatePage> {
  _WorkoutUpdatePageState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final WorkoutUpdateBloc bloc = widget.bloc;
    return Scaffold(
        floatingActionButton: ButtonBar(children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Annuler',
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                bloc.saveWorkout().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            child: const Icon(Icons.check),
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
                        StorageFutureImageWidget(
                          onSaved: (file) => bloc.setStorageFile(file),
                          futureInitialStorageFile: bloc.getFutureStorageFile(),
                          onDeleted: (file) => bloc.setStorageFile(null),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(helperText: 'Type d\'entrainement', constraints: BoxConstraints(maxHeight: 72)),
                                icon: const Icon(Icons.arrow_downward),
                                onChanged: (String? value) => bloc.setTimerType(value),
                                value: bloc.getWorkout()?.timerType,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'Aucun type d\'entraînement',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'AMRAP',
                                    child: Text('AMRAP'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'EMOM',
                                    child: Text('EMOM'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'For Time',
                                    child: Text('For Time'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'CIRCUIT',
                                    child: Text('Circuit'),
                                  ),
                                ]),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: TextFormField(
                      initialValue: bloc.getWorkout()?.description,
                      maxLength: 2000,
                      minLines: 5,
                      maxLines: 20,
                      onChanged: (value) => bloc.setDescription(value),
                      decoration: InputDecoration(helperText: 'Instructions (optionel)'),
                    ),
                  ),
                  LimitedBox(
                    maxWidth: 1200,
                    maxHeight: 600,
                    child: Row(
                      children: [
                        Expanded(
                          child: WorkoutSetPage(workout: widget.workout),
                        ),
                      ],
                    ),
                  )
                ]))));
  }
}

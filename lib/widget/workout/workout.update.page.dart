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

  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.instance();
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
    final List<DropdownMenuItem<String>> typesWorkout = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        child: Text(
          "Aucun type d'entraînement",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      const DropdownMenuItem<String>(
        value: 'AMRAP',
        child: Text('AMRAP'),
      ),
      const DropdownMenuItem<String>(
        value: 'EMOM',
        child: Text('EMOM'),
      ),
      const DropdownMenuItem<String>(
        value: 'For Time',
        child: Text('For Time'),
      ),
      const DropdownMenuItem<String>(
        value: 'CIRCUIT',
        child: Text('Circuit'),
      ),
    ];
    return Scaffold(
        floatingActionButton: ButtonBar(children: <Widget>[
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Annuler',
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                bloc.saveWorkout().then((_) => Navigator.pop(context));
              }
            },
            child: const Icon(Icons.check),
          ),
        ]),
        body: GenericUpdateWidget(
            maximumWidth: 2000,
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        StorageFutureImageWidget(
                          onSaved: (StorageFile? file) => bloc.storageFile = file,
                          onDeleted: (_) => bloc.storageFile = null,
                          futureInitialStorageFile: bloc.getStorageFile(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                initialValue: bloc.getWorkout()?.name,
                                autofocus: true,
                                onChanged: (String value) => bloc.name = value,
                                decoration: const InputDecoration(helperText: 'Nom du workout'),
                                validator: (String? value) {
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
                                decoration: const InputDecoration(helperText: "Type d'entrainement", constraints: BoxConstraints(maxHeight: 72)),
                                icon: const Icon(Icons.arrow_downward),
                                onChanged: (String? value) => bloc.timerType = value,
                                value: bloc.getWorkout()?.timerType,
                                items: typesWorkout),
                          ),
                        )
                      ],
                    ),
                  ),
                  TextFormField(
                    initialValue: bloc.getWorkout()?.description,
                    maxLength: 2000,
                    minLines: 5,
                    maxLines: 20,
                    onChanged: (String value) => bloc.description = value,
                    decoration: const InputDecoration(helperText: 'Instructions (optionel)'),
                  ),
                  LimitedBox(
                    maxWidth: 2000,
                    maxHeight: 600,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: WorkoutSetPage(workout: widget.workout),
                        ),
                      ],
                    ),
                  )
                ]))));
  }
}

import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class WorkoutUpdatePage extends StatefulWidget {
  WorkoutUpdatePage({Key? key, required this.workout}) : super(key: key);

  final Workout workout;
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.instance();

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
    // Initialisation du bloc.
    widget.bloc.init(widget.workout);

    final List<Widget> buttons = <Widget>[
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.bloc.saveWorkout().then((_) => showToast('Workout sauvegardé', backgroundColor: Colors.green)).catchError(
                (Object? error) {
                  showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent);
                },
              );
            }
          },
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('Enregistrer', style: TextStyle(color: Colors.white))),
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          label: const Text('Fermer', style: TextStyle(color: Colors.white))),
    ];

    final WorkoutUpdateBloc bloc = widget.bloc;
    final List<DropdownMenuItem<String>> typesWorkout = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: 'none',
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
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ButtonBar(children: buttons),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      StorageFutureImageWidget(
                        onSaved: (StorageFile? file) => bloc.storageFile = file,
                        onDeleted: (_) => bloc.storageFile = null,
                        futureInitialStorageFile: bloc.getStorageFile(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: FitnessDecorationTextFormField(
                              initialValue: bloc.getWorkout()?.name,
                              autofocus: true,
                              onChanged: (String value) => bloc.name = value,
                              labelText: 'Nom du workout',
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
                              decoration: const InputDecoration(
                                hintText: "Type d'entrainement",
                                labelText: "Type d'entrainement",
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                constraints: BoxConstraints(
                                  maxHeight: FitnessConstants.textFormFieldHeight,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_downward),
                              onChanged: (String? value) => bloc.timerType = value,
                              value: bloc.getWorkout()?.timerType,
                              items: typesWorkout),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            TextFormField(
              initialValue: bloc.getWorkout()?.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (String value) => bloc.description = value,
              decoration: const InputDecoration(labelText: 'Instructions', hintText: 'Optionnel'),
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
          ])),
    );
  }
}

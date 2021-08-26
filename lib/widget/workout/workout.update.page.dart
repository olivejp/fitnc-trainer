import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../../constants.dart';

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

    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: FitnessNcColors.blue100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                      child: StorageFutureImageWidget(
                        radius: 80,
                        onSaved: (StorageFile? file) => bloc.storageFile = file,
                        onDeleted: (_) => bloc.storageFile = null,
                        futureInitialStorageFile: bloc.getStorageFile(),
                      ),
                    ),
                    FitnessDecorationTextFormField(
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
                    DropdownButtonFormField<String>(
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
                    TextFormField(
                      initialValue: bloc.getWorkout()?.description,
                      maxLength: 2000,
                      minLines: 10,
                      maxLines: 10,
                      onChanged: (String value) => bloc.description = value,
                      decoration: const InputDecoration(labelText: 'Instructions', hintText: 'Optionnel'),
                    ),
                    ButtonBar(
                      children: buttons,
                      alignment: MainAxisAlignment.start,
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(height: 800, child: WorkoutComposePage(workout: widget.workout)),
          ),
        ],
      ),
    );
  }
}

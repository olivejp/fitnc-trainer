import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import '../../constants/constants.dart';

class WorkoutUpdatePage extends StatefulWidget {
  const WorkoutUpdatePage({Key? key, required this.workout}) : super(key: key);

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
    final WorkoutService workoutService = Get.find();

    // Initialisation du controller.
    workoutService.init(widget.workout);

    final List<Widget> buttons = <Widget>[
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              workoutService.saveWorkout().then((_) => showToast('Workout sauvegardé', backgroundColor: Colors.green)).catchError(
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
              decoration: const BoxDecoration(
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
                        onSaved: (StorageFile? file) => workoutService.storageFile = file,
                        onDeleted: (_) => workoutService.storageFile = null,
                        future: workoutService.getStorageFile(),
                      ),
                    ),
                    FitnessDecorationTextFormField(
                        initialValue: workoutService.getWorkout()?.name,
                        autofocus: true,
                        onChanged: (String value) => workoutService.name = value,
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
                        onChanged: (String? value) => workoutService.timerType = value,
                        value: workoutService.getWorkout()?.timerType,
                        items: typesWorkout),
                    TextFormField(
                      initialValue: workoutService.getWorkout()?.description,
                      maxLength: 2000,
                      minLines: 10,
                      maxLines: 10,
                      onChanged: (String value) => workoutService.description = value,
                      decoration: const InputDecoration(labelText: 'Instructions', hintText: 'Optionnel'),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: buttons,
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(height: 800, child: WorkoutSetPage(workout: widget.workout)),
          ),
        ],
      ),
    );
  }
}

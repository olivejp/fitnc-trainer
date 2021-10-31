import 'package:fitnc_trainer/controller/workout/workout.controller.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

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

  final WorkoutController controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Initialisation du mixin.
    controller.init(widget.workout);

    final List<Widget> buttons = <Widget>[
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              controller.saveWorkout().then((_) => showToast('Workout sauvegardé', backgroundColor: Colors.green)).catchError(
                (Object? error) {
                  showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent);
                  return Future<ToastFuture>.error(error.toString());
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                          child: Obx(
                            () => StorageImageWidget(
                              radius: 80,
                              onSaved: (StorageFile? file) => controller.setStorageFile(file),
                              onDeleted: () => controller.setStorageFile(null),
                              storageFile: controller.workout.value.storageFile,
                              imageUrl: controller.workout.value.imageUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FitnessDecorationTextFormField(
                        initialValue: controller.workout.value.name,
                        autofocus: true,
                        onChanged: (String value) => controller.name = value,
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
                        onChanged: (String? value) => controller.timerType = value,
                        value: controller.workout.value.timerType,
                        items: typesWorkout),
                    Obx(() {
                      print(controller.workout.value.timerType);
                      if (['AMRAP', 'EMOM'].contains(controller.workout.value.timerType)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            ],
                            initialValue: controller.workout.value.totalTime?.toString(),
                            onChanged: (String value) => controller.totalTime = value,
                            decoration: InputDecoration(
                              labelText: 'Temps total (en minutes)',
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                    TextFormField(
                      initialValue: controller.workout.value.description,
                      maxLength: 2000,
                      minLines: 10,
                      maxLines: 10,
                      onChanged: (String value) => controller.description = value,
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
          Obx(() {
            if (controller.isWorkoutSaved.value) {
              return Flexible(
                flex: 2,
                child: SizedBox(height: 800, child: WorkoutSetPage(workout: widget.workout)),
              );
            } else {
              return Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_volleyball_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 60,
                    ),
                    Center(
                      child: Text('Remplissez les informations nécessaires pour la création d\'un workout.'),
                    )
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}

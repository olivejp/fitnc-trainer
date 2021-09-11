import 'package:fitnc_trainer/controller/workout/workout.controller.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutCreatePage {
  static void showCreate(BuildContext context) {
    final WorkoutController controller = Get.find();
    controller.init(null);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: WorkoutCreateForm(
            formKey: formKey,
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: <Widget>[
            FloatingActionButton(
              tooltip: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: 'Créer',
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  controller.saveWorkout().then((_) => Navigator.of(context).pop());
                }
              },
              child: const Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }
}

class WorkoutCreateForm extends StatelessWidget {
  WorkoutCreateForm({Key? key, required this.formKey}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final WorkoutController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 800),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Obx(
                    () => StorageImageWidget(
                      imageUrl: controller.workout.value.imageUrl,
                      storageFile: controller.workout.value.storageFile,
                      onSaved: (StorageFile? storagePair) => controller.setStorageFile(storagePair),
                      onDeleted: () => controller.setStorageFile(null),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                          initialValue: controller.workout.value.name,
                          autofocus: true,
                          onChanged: (String value) => controller.name = value,
                          decoration: const InputDecoration(labelText: 'Nom du workout'),
                          validator: (String? value) {
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
                decoration: const InputDecoration(labelText: "Type d'entrainement", hintText: "Type d'entrainement"),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Le type d'entrainement est obligatoire.";
                  }
                  return null;
                },
                icon: const Icon(Icons.arrow_downward),
                onChanged: (String? value) => controller.timerType = value,
                value: controller.workout.value.timerType,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'none',
                    child: Text(
                      "Aucun type d'entraînement",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'AMRAP',
                    child: Text('AMRAP'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'EMOM',
                    child: Text('EMOM'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'For Time',
                    child: Text('For Time'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'CIRCUIT',
                    child: Text('Circuit'),
                  ),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: controller.workout.value.description,
                maxLength: 2000,
                minLines: 5,
                maxLines: 20,
                onChanged: (String value) => controller.description = value,
                decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionnel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

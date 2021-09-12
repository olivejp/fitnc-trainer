import 'package:fitness_domain/constants.dart';
import 'package:fitnc_trainer/controller/programme/programme.controller.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ProgrammeCreatePage {
  static void showCreate(BuildContext context) {
    final ProgrammeController controller = Get.find();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    controller.init(null);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: Form(
              key: _formKey,
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
                            onSaved: controller.setStoragePair,
                            onDeleted: () => controller.setStoragePair(null),
                            storageFile: controller.programme.value.storageFile,
                            imageUrl: controller.programme.value.imageUrl,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                      initialValue: controller.programme.value.name,
                                      autofocus: true,
                                      onChanged: (String value) => controller.name = value,
                                      decoration: const InputDecoration(labelText: 'Nom'),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Merci de renseigner le nom du programme.';
                                        }
                                        return null;
                                      }),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ParamDropdownButton(
                                        paramName: 'number_weeks',
                                        initialValue: controller.programme.value.numberWeeks,
                                        decoration: const InputDecoration(
                                            labelText: 'Nombre de semaine',
                                            constraints: BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight)),
                                        onChanged: (String? value) => controller.changeNumberWeek(value)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    initialValue: controller.programme.value.description,
                    maxLength: 2000,
                    minLines: 5,
                    maxLines: 20,
                    onChanged: (String? value) => controller.description = value,
                    decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionnel'),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            FloatingActionButton(
              tooltip: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: 'Créer',
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  controller.save().then((_) => Navigator.of(context).pop());
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

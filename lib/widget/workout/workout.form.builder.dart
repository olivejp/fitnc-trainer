import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutFormBuilder {
  static Widget getForm(GlobalKey<FormState> _formKey, WorkoutUpdateBloc bloc) {
    return ConstrainedBox(
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
                  StorageFutureImageWidget(
                    onSaved: (StorageFile? storagePair) => bloc.storageFile = storagePair,
                    onDeleted: (StorageFile? storagePair) => bloc.storageFile = null,
                    futureInitialStorageFile: bloc.getStorageFile(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                          initialValue: bloc.getWorkout()?.name,
                          autofocus: true,
                          onChanged: (String value) => bloc.name = value,
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
                onChanged: (String? value) => bloc.timerType = value,
                value: bloc.getWorkout()?.timerType,
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
                initialValue: bloc.getWorkout()?.description,
                maxLength: 2000,
                minLines: 5,
                maxLines: 20,
                onChanged: (String value) => bloc.description = value,
                decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionnel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

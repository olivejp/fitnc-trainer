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
                          onChanged: (String value) => bloc.setName(value),
                          decoration: const InputDecoration(helperText: 'Nom du workout'),
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
                decoration: const InputDecoration(helperText: 'Type d\'entrainement'),
                icon: const Icon(Icons.arrow_downward),
                onChanged: (String? value) => bloc.setTimerType(value),
                value: bloc.getWorkout()?.timerType,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    child: Text(
                      'Aucun type d\'entraînement',
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
                  DropdownMenuItem(
                    child: Text('Circuit'),
                    value: 'CIRCUIT',
                  ),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: bloc.getWorkout()?.description,
                maxLength: 2000,
                minLines: 5,
                maxLines: 20,
                onChanged: (String value) => bloc.setDescription(value),
                decoration: const InputDecoration(helperText: 'Description (optionel)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

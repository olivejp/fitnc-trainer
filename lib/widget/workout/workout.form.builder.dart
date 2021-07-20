import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutFormBuilder {
  static Widget getForm(GlobalKey<FormState> _formKey, WorkoutUpdateBloc bloc) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 800),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StorageFutureImageWidget(
                    onSaved: (storagePair) => bloc.setStorageFile(storagePair),
                    onDeleted: (storagePair) => bloc.setStorageFile(null),
                    futureInitialStorageFile: bloc.getFutureStorageFile(),
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
                ],
              ),
            ),
            DropdownButtonFormField<String>(
                decoration: InputDecoration(helperText: 'Type d\'entrainement'),
                icon: Icon(Icons.arrow_downward),
                onChanged: (String? value) => bloc.setTimerType(value),
                value: bloc.getWorkout()?.timerType,
                items: [
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
                onChanged: (value) => bloc.setDescription(value),
                decoration: InputDecoration(helperText: 'Description (optionel)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

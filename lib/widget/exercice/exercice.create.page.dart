import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'exercice.form.builder.dart';

class ExerciceCreatePage {
  static void showCreate(BuildContext context) {
    final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bloc.init(null);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ExerciceFormBuilder.getForm(_formKey, bloc),
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
                if (_formKey.currentState?.validate() == true) {
                  bloc.saveExercice().then((_) => Navigator.of(context).pop());
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

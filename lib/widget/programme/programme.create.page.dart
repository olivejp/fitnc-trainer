import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'programme.form.builder.dart';

class ProgrammeCreatePage {
  static showCreate(BuildContext context) {
    ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();
    bloc.init(null);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ProgrammeFormBuilder.getForm(_formKey, bloc),
          actionsPadding: EdgeInsets.all(20),
          actions: [
            FloatingActionButton(
              tooltip: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: 'Créer',
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  bloc.saveProgramme().then((value) => Navigator.of(context).pop());
                }
              },
              child: Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }
}

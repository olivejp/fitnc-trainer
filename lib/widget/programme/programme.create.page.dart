import 'package:fitnc_trainer/bloc/programme/programme.vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'programme.form.builder.dart';

class ProgrammeCreatePage {
  static void showCreate(BuildContext context) {
    final ProgrammeVm bloc = Provider.of<ProgrammeVm>(context);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bloc.init(null);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ProgrammeFormBuilder.getForm(_formKey, bloc),
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
                  bloc.save().then((_) => Navigator.of(context).pop());
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

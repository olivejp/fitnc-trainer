import 'package:fitnc_trainer/bloc/abonne/abonne_update.vm.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AbonneCreatePage {
  static void showCreate(BuildContext context) {
    final AbonneUpdateVm bloc = Provider.of<AbonneUpdateVm>(context);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bloc.init(null);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const AbonneUpdatePage(),
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
                  bloc.saveAbonne().then((_) => Navigator.of(context).pop());
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

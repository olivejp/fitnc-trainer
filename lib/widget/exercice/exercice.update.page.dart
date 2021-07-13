import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.form.builder.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExerciceUpdatePage extends StatefulWidget {
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();

  ExerciceUpdatePage({Key? key, Exercice? exercice}) : super(key: key) {
    bloc.init(exercice);
  }

  @override
  _ExerciceUpdatePageState createState() {
    return new _ExerciceUpdatePageState();
  }
}

class _ExerciceUpdatePageState extends State<ExerciceUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _ExerciceUpdatePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: ButtonBar(children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.clear),
            tooltip: 'Annuler',
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                widget.bloc.saveExercice().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            child: Icon(Icons.check),
            tooltip: 'Valider',
          )
        ]),
        body: GenericContainerWidget(
            child: GenericUpdateWidget(
          child: ExerciceFormBuilder.getForm(_formKey, widget.bloc),
        )));
  }
}

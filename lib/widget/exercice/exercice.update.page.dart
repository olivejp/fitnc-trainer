import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.form.builder.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExerciceUpdatePage extends StatefulWidget {
  ExerciceUpdatePage({Key? key, Exercice? exercice}) : super(key: key) {
    bloc.init(exercice);
  }

  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();

  @override
  _ExerciceUpdatePageState createState() {
    return _ExerciceUpdatePageState();
  }
}

class _ExerciceUpdatePageState extends State<ExerciceUpdatePage> {
  _ExerciceUpdatePageState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GenericUpdateWidget(
          child: ExerciceFormBuilder.getForm(context, _formKey, widget.bloc),
        ));
  }
}

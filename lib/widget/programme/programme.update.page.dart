import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/widget/programme/programme.form.builder.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgrammeUpdatePage extends StatefulWidget {
  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();

  ProgrammeUpdatePage({Key? key, Programme? programme}) : super(key: key) {
    bloc.init(programme);
  }

  @override
  _ProgrammeUpdatePageState createState() {
    return new _ProgrammeUpdatePageState();
  }
}

class _ProgrammeUpdatePageState extends State<ProgrammeUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _ProgrammeUpdatePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: ButtonBar(children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.clear),
            tooltip: 'Annuler',
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                widget.bloc.saveProgramme().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            child: Icon(Icons.check),
            tooltip: 'Valider',
          )
        ]),
        body: GenericUpdateWidget(
          child: ProgrammeFormBuilder.getForm(_formKey, widget.bloc),
        ));
  }
}

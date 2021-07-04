import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/bloc/add_workout.bloc.dart';
import 'package:flutter/material.dart';

class AddWorkoutPage extends StatefulWidget {
  final AddWorkoutBloc bloc = AddWorkoutBloc.getInstance();

  AddWorkoutPage({Key? key}) : super(key: key);

  @override
  _AddWorkoutPageState createState() {
    return new _AddWorkoutPageState();
  }
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _AddWorkoutPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Workout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          Flexible(
            child: Container(),
            flex: 1,
          ),
          Flexible(
            flex: 5,
            child: Form(
                key: _formKey,
                child: Card(
                  shadowColor: Color(Colors.deepPurple.shade900.value),
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(children: [
                        TextFormField(
                            autofocus: true,
                            onChanged: (value) => widget.bloc.changeName(value),
                            decoration: InputDecoration(hintText: 'Nom'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le nom du workout.';
                              }
                              return null;
                            }),
                        TextFormField(
                          onChanged: (value) => widget.bloc.changeName(value),
                          decoration: InputDecoration(
                              hintText: 'Description (optionel)'),
                        ),
                        TextButton(
                          child: Text('Selectionner une image'),
                          onPressed: () {
                            FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'jpg',
                                  'png',
                                  'gif'
                                ]).then((result) {
                              if (result != null) {
                                widget.bloc.setImage(result.files.first.bytes, result.files.first.name);
                              }
                            });
                          },
                        )
                      ]),
                    ),
                  ),
                )),
          ),
          Flexible(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.bloc
                .addWorkout()
                .then((value) => Navigator.pop(context))
                .catchError((error) => print(error.toString()));
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

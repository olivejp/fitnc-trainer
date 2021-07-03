import 'package:fitnc_trainer/bloc/add_workout.bloc.dart';
import 'package:flutter/material.dart';

class AddWorkoutPage extends StatefulWidget {
  AddWorkoutBloc bloc = AddWorkoutBloc.getInstance();

  AddWorkoutPage({Key key}) : super(key: key);

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
      body: Form(
        key: _formKey,
        child: Center(
          child: TextFormField(
              onChanged: (value) => widget.bloc.changeName(value),
              decoration: InputDecoration(hintText: 'Nom du workout'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merci de renseigner le nom du workout.';
                }
                return null;
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
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

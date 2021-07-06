import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutUpdatePage extends StatefulWidget {
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();

  final double containerHeight = 240;

  WorkoutUpdatePage({Key? key, Workout? workout}) : super(key: key) {
    bloc.init(workout);
  }

  @override
  _WorkoutUpdatePageState createState() {
    return new _WorkoutUpdatePageState();
  }
}

class _WorkoutUpdatePageState extends State<WorkoutUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _WorkoutUpdatePageState();

  @override
  Widget build(BuildContext context) {
    String appBarTitle =
    widget.bloc.getWorkout()?.uid != null ? widget.bloc.getWorkout()!.name : 'Nouveau workout';
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle,
              style: Theme.of(context)
                  .appBarTheme
                  .titleTextStyle
                  ?.copyWith(fontSize: 30)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: Theme.of(context).appBarTheme.iconTheme?.size,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double leftAndRightPadding = 5;
          double topAndBottomPadding = 5;

          if (constraints.maxWidth > 600) {
            leftAndRightPadding = 25;
            topAndBottomPadding = 10;
          }

          if (constraints.maxWidth > 800) {
            leftAndRightPadding = 100;
            topAndBottomPadding = 25;
          }

          if (constraints.maxWidth > 1200) {
            leftAndRightPadding = 200;
            topAndBottomPadding = 50;
          }

          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://s3.envato.com/files/189120872/0Q7A7108.jpg"),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: EdgeInsets.only(
                  left: leftAndRightPadding,
                  right: leftAndRightPadding,
                  top: topAndBottomPadding,
                  bottom: topAndBottomPadding),
              child: Card(
                shadowColor: Color(Colors.black.value),
                clipBehavior: Clip.antiAlias,
                color: Color(Colors.white.value).withOpacity(0.85),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            StreamBuilder<Uint8List?>(
                                stream: widget.bloc.selectedImageObs,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Ink.image(
                                            image: MemoryImage(snapshot.data!),
                                            fit: BoxFit.cover,
                                            height: widget.containerHeight,
                                          ),
                                          ButtonBar(
                                            children: [
                                              IconButton(
                                                  onPressed: () =>
                                                      callPhotoPicker(),
                                                  icon: Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                    color: Theme.of(context)
                                                        .floatingActionButtonTheme
                                                        .foregroundColor,
                                                  )),
                                              IconButton(
                                                  onPressed: () =>
                                                      deletePhoto(),
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: 40,
                                                    color: Theme.of(context)
                                                        .floatingActionButtonTheme
                                                        .foregroundColor,
                                                  )),
                                            ],
                                            alignment: MainAxisAlignment.center,
                                          ),
                                        ]);
                                  } else {
                                    return Container(
                                      height: widget.containerHeight,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.amber,
                                              Colors.amberAccent
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomLeft),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: IconButton(
                                                onPressed: () =>
                                                    callPhotoPicker(),
                                                icon: Icon(
                                                  Icons.add_a_photo,
                                                  size: 40,
                                                  color: Theme.of(context)
                                                      .floatingActionButtonTheme
                                                      .foregroundColor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                        Stack(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                      initialValue: widget.bloc.getWorkout()?.name,
                                      autofocus: true,
                                      onChanged: (value) =>
                                          widget.bloc.changeName(value),
                                      decoration:
                                          InputDecoration(hintText: 'Nom'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Merci de renseigner le nom du workout.';
                                        }
                                        return null;
                                      }),
                                  TextFormField(
                                    initialValue: widget.bloc.getWorkout()?.description,
                                    maxLength: 2000,
                                    minLines: 5,
                                    maxLines: 20,
                                    onChanged: (value) =>
                                        widget.bloc.changeDescription(value),
                                    decoration: InputDecoration(
                                        alignLabelWithHint: true,
                                        hintText: 'Description (optionel)'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                        right: 20,
                        bottom: 20,
                        child: FloatingActionButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              widget.bloc
                                  .saveWorkout()
                                  .then((value) => Navigator.pop(context))
                                  .catchError(
                                      (error) => print(error.toString()));
                            }
                          },
                          child: Icon(Icons.check),
                        )),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  void deletePhoto() {
    widget.bloc.setImage(null, null);
  }

  void callPhotoPicker() {
    FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'gif']).then((result) {
      if (result != null) {
        widget.bloc.setImage(result.files.first.bytes, result.files.first.name);
      }
    });
  }
}

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    String appBarTitle = widget.bloc.getWorkout()?.uid != null ? widget.bloc.getWorkout()!.name : 'Nouveau workout';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                widget.bloc.saveWorkout().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            child: Icon(Icons.check),
          ),
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Column(
                    children: [
                      Icon(
                        Icons.file_copy,
                        color: Color(Colors.amber.value),
                      ),
                      Text(
                        'Description',
                        style: TextStyle(color: Color(Colors.amber.value)),
                      )
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_volleyball,
                        color: Color(Colors.amber.value),
                      ),
                      Text(
                        'Exercices',
                        style: TextStyle(color: Color(Colors.amber.value)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            title: Text(appBarTitle, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 30)),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: Theme.of(context).appBarTheme.iconTheme?.size,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration:
                BoxDecoration(image: DecorationImage(image: NetworkImage("https://s3.envato.com/files/189120872/0Q7A7108.jpg"), fit: BoxFit.cover)),
            child: TabBarView(
              children: [
                getFirstPanel(),
                getSecondPanel(),
              ],
            ),
          )),
    );
  }

  LayoutBuilder getFirstPanel() {
    return LayoutBuilder(builder: (context, constraints) {
      double leftAndRightPadding = 5;
      double topAndBottomPadding = 5;

      if (constraints.maxWidth > 600) {
        leftAndRightPadding = 10;
        topAndBottomPadding = 10;
      }

      if (constraints.maxWidth > 800) {
        leftAndRightPadding = 25;
        topAndBottomPadding = 25;
      }

      if (constraints.maxWidth > 1200) {
        leftAndRightPadding = 50;
        topAndBottomPadding = 50;
      }

      return Padding(
        padding: EdgeInsets.only(left: leftAndRightPadding, right: leftAndRightPadding, top: topAndBottomPadding, bottom: topAndBottomPadding),
        child: Card(
          shadowColor: Color(Colors.black.value),
          clipBehavior: Clip.antiAlias,
          color: Color(Colors.white.value).withOpacity(0.85),
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamBuilder<Uint8List?>(
                              stream: widget.bloc.selectedImageObs,
                              builder: (context, snapshot) {
                                ImageProvider? provider;
                                if (snapshot.hasData && snapshot.data != null) {
                                  provider = MemoryImage(snapshot.data!);
                                }

                                return InkWell(
                                  child: CircleAvatar(
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        color: Color(Colors.white.value),
                                      ),
                                      radius: 50,
                                      foregroundImage: provider,
                                      backgroundColor: Color(Colors.amber.value)),
                                  onTap: callPhotoPicker,
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                );
                              }),
                          IconButton(
                              tooltip: 'Supprimer la photo',
                              onPressed: () => deletePhoto(),
                              icon: Icon(
                                Icons.delete,
                                color: Color(Colors.amber.value),
                              )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextFormField(
                                  initialValue: widget.bloc.getWorkout()?.name,
                                  autofocus: true,
                                  onChanged: (value) => widget.bloc.changeName(value),
                                  decoration: InputDecoration(helperText: 'Nom'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Merci de renseigner le nom du workout.';
                                    }
                                    return null;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: TextFormField(
                                  maxLength: 10,
                                  initialValue: widget.bloc.getWorkout()?.dateDebut != null ? widget.bloc.getWorkout()?.dateDebut.toString() : '',
                                  onChanged: (value) => widget.bloc.changeDateDebut(value),
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    if (value?.length != null && value!.length >= 8) {
                                      DateTime time;
                                      DateTime today = DateTime.now();
                                      try {
                                        time = DateFormat('dd/MM/yyyy').parseStrict(value);
                                      } on Exception catch (e) {
                                        return 'Date incorrecte. Format accepté dd/mm/aaaa.';
                                      }
                                      if (time.isAfter(today)) {
                                        return 'Date supérieure à la date du jour';
                                      }
                                      return null;
                                    }
                                  },
                                  decoration:
                                      InputDecoration(suffixIcon: Icon(Icons.event_note), hintText: 'dd/mm/aaaa', helperText: 'Date de début'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  maxLength: 10,
                                  initialValue: widget.bloc.getWorkout()?.dateFin != null ? widget.bloc.getWorkout()?.dateFin.toString() : '',
                                  onChanged: (value) => widget.bloc.changeDateFin(value),
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    if (value?.length != null && value!.length >= 8) {
                                      DateTime time;
                                      DateTime today = DateTime.now();
                                      try {
                                        time = DateFormat('dd/MM/yyyy').parseStrict(value);
                                      } on Exception catch (e) {
                                        return 'Date incorrecte. Format accepté dd/mm/aaaa.';
                                      }
                                      if (time.isAfter(today)) {
                                        return 'Date supérieure à la date du jour';
                                      }
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(suffixIcon: Icon(Icons.event_note), hintText: 'dd/mm/aaaa', helperText: 'Date de fin'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        initialValue: widget.bloc.getWorkout()?.description,
                        maxLength: 2000,
                        minLines: 5,
                        maxLines: 20,
                        onChanged: (value) => widget.bloc.changeDescription(value),
                        decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Description (optionel)'),
                      ),
                      DropdownButtonFormField<String>(
                          icon: Icon(Icons.timer),
                          onChanged: (String? value) => widget.bloc.changeTimerType(value),
                          value: widget.bloc.getWorkout()?.timerType,
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                'Aucun type de timer',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              value: null,
                            ),
                            DropdownMenuItem(
                              child: Text('AMRAP'),
                              value: 'AMRAP',
                            ),
                            DropdownMenuItem(
                              child: Text('EMOM'),
                              value: 'EMOM',
                            ),
                            DropdownMenuItem(
                              child: Text('For Time'),
                              value: 'For Time',
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Row getSecondPanel() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shadowColor: Color(Colors.black.value),
              clipBehavior: Clip.antiAlias,
              color: Color(Colors.white.value).withOpacity(0.85),
              elevation: 5.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Draggable<String>(
                    child: ListTile(title: Text('Bdule')),
                    feedback: Card(child: Text('Feedback')),
                    data: 'Bdule',
                    childWhenDragging: Text('Bdule en plein drag'),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DragTarget<String>(
              onWillAccept: (data) {
                print(data);
                return true;
              },
              onAccept: (data) {
                print(data);
              },
              onLeave: (data) {
                print(data);
              },
              builder: (context, candidateData, rejectedData) => Card(
                shadowColor: Color(Colors.black.value),
                clipBehavior: Clip.antiAlias,
                color: Color(Colors.white.value).withOpacity(0.85),
                elevation: 5.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void deletePhoto() {
    widget.bloc.setImage(null, null);
  }

  void callPhotoPicker() {
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'gif']).then((result) {
      if (result != null) {
        widget.bloc.setImage(result.files.first.bytes, result.files.first.name);
      }
    });
  }
}

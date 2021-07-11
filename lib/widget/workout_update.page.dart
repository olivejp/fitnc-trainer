import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/widget/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutUpdatePage extends StatefulWidget {
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();

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
            bottom: getTabBar(),
            title: Text(appBarTitle, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 30)),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: Theme.of(context).appBarTheme.iconTheme?.size,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: GenericContainerWidget(
            child: TabBarView(
              children: [
                GenericUpdateWidget(child: getFirstPanel()),
                getSecondPanel(),
              ],
            ),
          )),
    );
  }

  TabBar getTabBar() {
    return TabBar(
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
    );
  }

  Widget getFirstPanel() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StorageImageWidget(
                onSaved: (storagePair) => widget.bloc.setStoragePair(storagePair),
                initialUrl: widget.bloc.getWorkout()?.imageUrl,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: TextFormField(
                      initialValue: widget.bloc.getWorkout()?.name,
                      autofocus: true,
                      onChanged: (value) => widget.bloc.setName(value),
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
          TextFormField(
            initialValue: widget.bloc.getWorkout()?.description,
            maxLength: 2000,
            minLines: 5,
            maxLines: 20,
            onChanged: (value) => widget.bloc.setDescription(value),
            decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Description (optionel)'),
          ),
          DropdownButtonFormField<String>(
              icon: Icon(Icons.timer),
              onChanged: (String? value) => widget.bloc.setTimerType(value),
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
    );
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
}

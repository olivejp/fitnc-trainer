import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/widget/programme/programme.form.builder.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animations/loading_animations.dart';

class ProgrammeUpdatePage extends StatefulWidget {
  ProgrammeUpdatePage({Key? key, Programme? programme}) : super(key: key) {
    bloc.init(programme);
  }

  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();

  @override
  _ProgrammeUpdatePageState createState() {
    return _ProgrammeUpdatePageState();
  }
}

class _ProgrammeUpdatePageState extends State<ProgrammeUpdatePage> {
  _ProgrammeUpdatePageState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: ButtonBar(children: [
          FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Annuler',
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                widget.bloc.saveProgramme().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
              }
            },
            tooltip: 'Valider',
            child: Icon(Icons.check),
          )
        ]),
        body: GenericUpdateWidget(
          maximumWidth: 2680,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StorageStreamImageWidget(
                          onSaved: (StorageFile? storagePair) => widget.bloc.setStoragePair(storagePair),
                          streamInitialStorageFile: widget.bloc.obsStoragePair,
                          onDeleted: (StorageFile? storagePair) => widget.bloc.setStoragePair(null),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                                initialValue: widget.bloc.programme.name,
                                autofocus: true,
                                onChanged: (String value) => widget.bloc.name = value,
                                decoration: const InputDecoration(helperText: 'Nom'),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Merci de renseigner le nom du programme.';
                                  }
                                  return null;
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    initialValue: widget.bloc.programme.description,
                    maxLength: 2000,
                    minLines: 5,
                    maxLines: 20,
                    onChanged: (String value) => widget.bloc.description  = value,
                    decoration: const InputDecoration(helperText: 'Description (optionel)'),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 600),
                    child: Row(
                      children: [
                        Expanded(child: ProgrammeRightPanel()),
                        Expanded(child: ProgrammeLeftPanel()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class ProgrammeLeftPanel extends StatelessWidget {
  static final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Workout?>>(
      stream: bloc.trainersService.listenToWorkout(),
      builder: (BuildContext context, AsyncSnapshot<List<Workout?>> snapshot) {
        if (snapshot.hasData) {
          final List<Workout?> list = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 2.0),
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Draggable<Workout>(
                  feedback: SizedBox(
                    width: 200,
                    height: 100,
                    child: Text(list[index]!.name),
                  ),
                  data: list[index],
                  child: const Icon(Icons.view_headline),
                ),
                title: Text(list[index]!.name),
              );
            },
          );
        }
        return LoadingBouncingGrid.circle();
      },
    );
  }
}

class ProgrammeRightPanel extends StatelessWidget {
  static final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkoutScheduleDto>>(
      stream: bloc.workoutScheduleObs,
      builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
        if (snapshot.hasData) {
          final List<WorkoutScheduleDto> listWorkout = snapshot.data!;
          return DragTarget<Workout>(
            onWillAccept: (Workout? data) => data is Workout,
            onAccept: (Workout workout) => bloc.addWorkoutSchedule(workout),
            builder: (BuildContext context, List<Workout?> candidateData, List rejectedData) {
              return ListView.separated(
                itemCount: listWorkout.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 2),
                itemBuilder: (BuildContext context, int index) {
                  final WorkoutScheduleDto workout = listWorkout.elementAt(index);
                  return ListTile(
                    title: Text(workout.nameWorkout!),
                  );
                },
              );
            },
          );
        } else {
          return LoadingBouncingGrid.circle();
        }
      },
    );
  }
}

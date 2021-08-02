import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
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
            child: const Icon(Icons.check),
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
                            child: Row(
                              children: [
                                Expanded(
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                    ),
                                    child: ParamDropdownButton(
                                        paramName: 'number_weeks',
                                        decoration: const InputDecoration(
                                          hintText: 'Nombre de semaine',
                                          helperText: 'Nombre de semaine',
                                        ),
                                        initialValue: widget.bloc.programme.numberWeeks,
                                        onChanged: (String? value) => widget.bloc.numberWeeks = value),
                                  ),
                                )
                              ],
                            ),
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
                    onChanged: (String value) => widget.bloc.description = value,
                    decoration: const InputDecoration(helperText: 'Description (optionel)'),
                  ),
                  Row(
                    children: [
                      Expanded(child: WorkoutSchedulePanel()),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class WorkoutChoicePanel extends StatelessWidget {
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

class WorkoutSchedulePanel extends StatelessWidget {
  static final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();
  static final TextStyle columnTextStyle = GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final List<DataColumn> listHeadersColumn = <DataColumn>[
      const DataColumn(label: Text(''), numeric: true),
      const DataColumn(
          label: Text(
        'Lundi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Mardi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Mercredi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Jeudi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Vendredi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Samedi',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Dimanche',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      )),
    ];

    final Widget titlePlannification = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('Plannification'),
        ),
      ],
    );

    return FutureBuilder<List<DropdownMenuItem<Workout>>>(
        future: bloc.getWorkoutDropdownItems(),
        builder: (BuildContext context, AsyncSnapshot<List<DropdownMenuItem<Workout>>> snapshot) {
          if (snapshot.hasData) {
            List<DropdownMenuItem<Workout>> listAvailableWorkout = snapshot.data!;
            return StreamBuilder<List<WorkoutScheduleDto>>(
              stream: bloc.workoutScheduleObs,
              builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
                if (snapshot.hasData) {
                  final List<WorkoutScheduleDto> listScheduledWorkouts = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 100),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titlePlannification,
                          SingleChildScrollView(
                            child: DataTable(
                              columns: listHeadersColumn,
                              dataTextStyle: GoogleFonts.roboto(fontSize: 10, color: Colors.grey),
                              rows: getListDataRows(context, 8, listScheduledWorkouts, listAvailableWorkout),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return LoadingBouncingGrid.circle();
                }
              },
            );
          } else {
            return LoadingBouncingGrid.circle();
          }
        });
  }

  DataCell getDataCell(
      BuildContext context, int dayIndex, List<WorkoutScheduleDto> listAppointment, List<DropdownMenuItem<Workout>> listAvailableWorkout) {
    final List<WorkoutScheduleDto> list = listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();

    void onDataCellTap() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Card(
              child: DropdownButtonFormField<Workout>(
                items: listAvailableWorkout,
                onChanged: (Workout? value) {
                  if (value != null) {
                    bloc.addWorkoutSchedule(value, dayIndex);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      );
    }

    if (list.isNotEmpty) {
      return DataCell(Column(children: list.map((e) => Text(e.nameWorkout!)).toList()), showEditIcon: true, onTap: onDataCellTap);
    } else {
      return DataCell(Text(''), showEditIcon: true, onTap: onDataCellTap);
    }
  }

  DataRow getDataRow(
      BuildContext context, int weekIndex, List<WorkoutScheduleDto> listAppointment, List<DropdownMenuItem<Workout>> listAvailableWorkout) {
    final List<DataCell> list = <DataCell>[];
    final int index = weekIndex + 1;
    list.add(DataCell(Text('$index')));
    for (int i = 0; i < 7; i++) {
      final int dayIndex = (7 * weekIndex) + i;
      list.add(getDataCell(context, dayIndex, listAppointment, listAvailableWorkout));
    }
    return DataRow(cells: list);
  }

  List<DataRow> getListDataRows(
      BuildContext context, int numberWeeks, List<WorkoutScheduleDto> listAppointment, List<DropdownMenuItem<Workout>> listAvailableWorkout) {
    final List<DataRow> list = <DataRow>[];
    for (int i = 0; i < numberWeeks; i++) {
      list.add(getDataRow(context, i, listAppointment, listAvailableWorkout));
    }
    return list;
  }
}

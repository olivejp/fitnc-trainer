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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart' as sf;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProgrammeUpdatePage extends StatefulWidget {
  ProgrammeUpdatePage({Key? key, Programme? programme}) : super(key: key) {
    bloc.init(programme);
  }

  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();

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
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
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
                SizedBox(
                  height: 800,
                  child: WorkoutSchedulePanel(),
                )
              ],
            ),
          ),
        ));
  }
}

class WorkoutChoicePanel extends StatelessWidget {
  static final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();

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
                    child: Text(list[index]!.name!),
                  ),
                  data: list[index],
                  child: const Icon(Icons.view_headline),
                ),
                title: Text(list[index]!.name!),
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
  static final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();
  static final TextStyle columnTextStyle = GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold);
  static final List<String> columnNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  @override
  Widget build(BuildContext context) {
    final List<sf.GridColumn> listHeadersColumn = columnNames
        .map((String columnName) => sf.GridColumn(
            columnName: columnName,
            label: Center(
                child: Text(
              columnName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ))))
        .toList();

    return FutureBuilder<List<DropdownMenuItem<Workout>>>(
        future: bloc.getWorkoutDropdownItems(),
        builder: (BuildContext context, AsyncSnapshot<List<DropdownMenuItem<Workout>>> snapshot) {
          if (snapshot.hasData) {
            final List<DropdownMenuItem<Workout>> listAvailableWorkout = snapshot.data!;
            return StreamBuilder<List<WorkoutScheduleDto>>(
              stream: bloc.workoutScheduleObs,
              builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
                if (snapshot.hasData) {
                  final List<WorkoutScheduleDto> listScheduledWorkouts = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 125),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      padding: const EdgeInsets.all(1),
                      child: sf.SfDataGrid(
                        highlightRowOnHover: false,
                        headerGridLinesVisibility: GridLinesVisibility.both,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 50,
                        frozenRowsCount: 20,
                        frozenColumnsCount: 20,
                        navigationMode: GridNavigationMode.cell,
                        gridLinesVisibility: GridLinesVisibility.both,
                        selectionMode: SelectionMode.single,
                        columns: listHeadersColumn,
                        rowHeight: 150,
                        source: WorkoutDataSource(
                            context: context,
                            numberWeeks: 8,
                            listAppointment: listScheduledWorkouts,
                            listAvailableWorkout: listAvailableWorkout,
                            columnNames: columnNames,
                            bloc: bloc),
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
}

class DataCellData {
  DataCellData({required this.list, required this.dayIndex});

  List<WorkoutScheduleDto> list;
  int dayIndex;
}

class WorkoutDataSource extends sf.DataGridSource {
  WorkoutDataSource(
      {required this.bloc,
      required this.context,
      required this.numberWeeks,
      required this.listAppointment,
      required this.listAvailableWorkout,
      required this.columnNames}) {
    _workoutData = getListDataRows(numberWeeks, listAppointment);
  }

  ProgrammeUpdateBloc bloc;
  BuildContext context;
  int numberWeeks;
  List<WorkoutScheduleDto> listAppointment;
  List<DropdownMenuItem<Workout>> listAvailableWorkout;
  List<DataGridRow> _workoutData = <DataGridRow>[];
  List<String> columnNames;

  sf.DataGridCell<DataCellData> getDataCell(String columnName, int dayIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<WorkoutScheduleDto> list = listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();
    final DataCellData data = DataCellData(list: list, dayIndex: dayIndex);
    return sf.DataGridCell<DataCellData>(value: data, columnName: columnName);
  }

  sf.DataGridRow getDataRow(int weekIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<sf.DataGridCell<DataCellData>> list = <sf.DataGridCell<DataCellData>>[];
    for (int i = 0; i < 7; i++) {
      final int dayIndex = (7 * weekIndex) + i;
      list.add(getDataCell(columnNames[i], dayIndex, listAppointment));
    }
    return sf.DataGridRow(cells: list);
  }

  List<sf.DataGridRow> getListDataRows(int numberWeeks, List<WorkoutScheduleDto> listAppointment) {
    final List<sf.DataGridRow> list = <sf.DataGridRow>[];
    for (int i = 0; i < numberWeeks; i++) {
      list.add(getDataRow(i, listAppointment));
    }
    return list;
  }

  @override
  List<DataGridRow> get rows => _workoutData;

  @override
  sf.DataGridRowAdapter? buildRow(DataGridRow row) {
    return sf.DataGridRowAdapter(
        cells: row.getCells().map((sf.DataGridCell listCell) {
      final DataCellData dataCell = listCell.value as DataCellData;
      final List<WorkoutScheduleDto> listWorkout = dataCell.list;
      return Stack(
        alignment: Alignment.center,
        children: [
          Text('${dataCell.dayIndex + 1}'),
          Column(
            children: listWorkout
                .map((WorkoutScheduleDto dto) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(dto.imageUrlWorkout!),
                      ),
                      title: Text(dto.nameWorkout!),
                      trailing: IconButton(
                        onPressed: () => bloc.deleteWorkoutSchedule(dto),
                        icon: const Icon(Icons.close),
                      ),
                    ))
                .toList(),
          )
        ],
      );
    }).toList());
  }
}

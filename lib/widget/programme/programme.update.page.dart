import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
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
import 'package:oktoast/oktoast.dart';
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
    final List<Widget> buttons = <Widget>[];
    if (widget.bloc.programme.available == null || widget.bloc.programme.available == false) {
      buttons.add(TextButton.icon(
        style: TextButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.bloc.validateProgramme().then((_) => Navigator.pop(context));
          }
        },
        label: const Text('Publier', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.public, color: Colors.white),
      ));
    }
    buttons.addAll(<Widget>[
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue100),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.bloc.saveProgramme().then(
                    (_) => showToast('Exercice sauvegardé', backgroundColor: Colors.green),
              )
                  .catchError(
                    (_) => showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent),
              );
            }
          },
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('Enregistrer', style: TextStyle(color: Colors.white))),
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue100),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          label: const Text('Fermer', style: TextStyle(color: Colors.white))),
    ]);

    return Scaffold(
        body: GenericUpdateWidget(
          maximumWidth: 1200,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ButtonBar(children: buttons),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          StorageStreamImageWidget(
                            onSaved: (StorageFile? storagePair) => widget.bloc.setStoragePair(storagePair),
                            streamInitialStorageFile: widget.bloc.obsStoragePair,
                            onDeleted: (StorageFile? storagePair) => widget.bloc.setStoragePair(null),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: FitnessDecorationTextFormField(
                                            initialValue: widget.bloc.programme.name,
                                            autofocus: true,
                                            onChanged: (String value) => widget.bloc.name = value,
                                            labelText: 'Nom',
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
                                                  labelText: 'Nombre de semaine',
                                                  constraints: BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                                              initialValue: widget.bloc.programme.numberWeeks,
                                              onChanged: (String? value) => widget.bloc.numberWeeks = value),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                  decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionel'),
                ),
                WorkoutSchedulePanel()
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
              final Workout? workout = list.elementAt(index);
              return ListTile(
                leading: Draggable<Workout>(
                  feedback: SizedBox(
                    width: 200,
                    height: 50,
                    child: Card(
                        child: ListTile(
                      title: Text(list[index]!.name!),
                      leading: (workout?.imageUrl != null)
                          ? CircleAvatar(backgroundImage: NetworkImage(workout!.imageUrl!), radius: 10)
                          : CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10),
                    )),
                  ),
                  data: list[index],
                  child: const MouseRegion(
                    child: Icon(Icons.view_headline),
                    cursor: SystemMouseCursors.grab,
                  ),
                ),
                title: Row(
                  children: <Widget>[
                    if (workout?.imageUrl != null)
                      CircleAvatar(backgroundImage: NetworkImage(workout!.imageUrl!), radius: 10)
                    else
                      CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(list[index]!.name!),
                    ),
                  ],
                ),
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
  static final List<String> columnNames = <String>['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  @override
  Widget build(BuildContext context) {
    final List<sf.GridColumn> listHeadersColumn = columnNames
        .map((String columnName) => sf.GridColumn(
            columnName: columnName,
            label: Center(
                child: Text(
              columnName,
              style: Theme.of(context).textTheme.headline3,
            ))))
        .toList();

    /// Méthode permettant d'afficher l'affectation des Workouts à une date.
    void popupDayDetails(sf.DataGridCellTapDetails details, List<WorkoutScheduleDto> listAppointment) {
      final int columnIndex = details.rowColumnIndex.columnIndex;
      final int rowIndex = details.rowColumnIndex.rowIndex;
      final int dayIndex = ((rowIndex - 1) * 7) + columnIndex + 1;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final List<WorkoutScheduleDto> list = listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();
          return AlertDialog(
            title: Text('Jour $dayIndex'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Sortir')),
            ],
            content: PopupDayDetail(bloc: bloc, dayIndex: dayIndex, list: list),
          );
        },
      );
    }

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
                  return SizedBox(
                    height: 800,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 125),
                      child: ValueListenableBuilder<int>(
                        valueListenable: bloc.vnNumberWeek,
                        builder: (BuildContext context, int nbWeeks, Widget? child) => Container(
                          // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          padding: const EdgeInsets.all(1),
                          child: sf.SfDataGrid(
                            onCellTap: (sf.DataGridCellTapDetails details) => popupDayDetails(details, listScheduledWorkouts),
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
                                numberWeeks: nbWeeks,
                                listAppointment: listScheduledWorkouts,
                                listAvailableWorkout: listAvailableWorkout,
                                columnNames: columnNames,
                                bloc: bloc),
                          ),
                        ),
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

class PopupDayDetail extends StatelessWidget {
  const PopupDayDetail({
    Key? key,
    required this.bloc,
    required this.dayIndex,
    required this.list,
  }) : super(key: key);

  final ProgrammeUpdateBloc bloc;
  final int dayIndex;
  final List<WorkoutScheduleDto> list;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 800,
      width: 600,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DragTarget<Workout>(
                  onAccept: (Workout workout) => bloc.addWorkoutSchedule(workout, dayIndex - 1),
                  onWillAccept: (Workout? data) => data is Workout,
                  builder: (BuildContext context, List<Workout?> candidateData, List<Object?> rejectedData) {
                    return Container(
                      decoration:
                          BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        children: <Widget>[
                          const Text('Glisser ici les workout de la journée.'),
                          StreamBuilder<List<WorkoutScheduleDto>>(
                              initialData: list,
                              stream: bloc.workoutScheduleObs,
                              builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
                                if (snapshot.hasData) {
                                  final List<WorkoutScheduleDto> listWorkout =
                                      snapshot.data!.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex - 1).toList();
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context, int index) {
                                      final WorkoutScheduleDto dto = listWorkout.elementAt(index);
                                      return ListTile(
                                        leading: (dto.imageUrlWorkout != null)
                                            ? CircleAvatar(backgroundImage: NetworkImage(dto.imageUrlWorkout!), radius: 10)
                                            : CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10),
                                        title: Text(dto.nameWorkout!),
                                        trailing: IconButton(
                                          onPressed: () => bloc.deleteWorkoutSchedule(dto),
                                          icon: const Icon(Icons.close),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 2.0),
                                    itemCount: listWorkout.length,
                                  );
                                } else {
                                  return LoadingBouncingGrid.circle();
                                }
                              }),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: WorkoutChoicePanel()),
            ),
          ),
        ],
      ),
    );
  }
}

///
/// Data d'une cellule
/// Une cellule a toujours un dayIndex mais aussi une liste des Workout à effectuer pour ce jour.
class DataCellData {
  DataCellData({required this.list, required this.dayIndex});

  List<WorkoutScheduleDto> list;
  int dayIndex;
}

///
/// DataSource du GridData
///
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

  /// Méthode pour générer une DataCell.
  sf.DataGridCell<DataCellData> getDataCell(String columnName, int dayIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<WorkoutScheduleDto> list = listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();
    final DataCellData data = DataCellData(list: list, dayIndex: dayIndex);
    return sf.DataGridCell<DataCellData>(value: data, columnName: columnName);
  }

  /// Méthode pour générer une DataRow.
  sf.DataGridRow getDataRow(int weekIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<sf.DataGridCell<DataCellData>> list = <sf.DataGridCell<DataCellData>>[];
    for (int i = 0; i < 7; i++) {
      final int dayIndex = (7 * weekIndex) + i;
      list.add(getDataCell(columnNames[i], dayIndex, listAppointment));
    }
    return sf.DataGridRow(cells: list);
  }

  /// Méthode pour générer toutes les DataRow du tableau.
  List<sf.DataGridRow> getListDataRows(int numberWeeks, List<WorkoutScheduleDto> listAppointment) {
    final List<sf.DataGridRow> list = <sf.DataGridRow>[];
    for (int i = 0; i < numberWeeks; i++) {
      list.add(getDataRow(i, listAppointment));
    }
    return list;
  }

  @override
  List<DataGridRow> get rows => _workoutData;

  /// Méthode permettant de dessiner une ligne du tableau.
  @override
  sf.DataGridRowAdapter? buildRow(DataGridRow row) {
    return sf.DataGridRowAdapter(
        cells: row.getCells().map((sf.DataGridCell listCell) {
      final DataCellData dataCell = listCell.value as DataCellData;
      final ScrollController _controller = ScrollController();
      final List<WorkoutScheduleDto> listWorkout = dataCell.list;
      final List<Widget> listListTile = listWorkout
          .map((WorkoutScheduleDto dto) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    if (dto.imageUrlWorkout != null)
                      CircleAvatar(backgroundImage: NetworkImage(dto.imageUrlWorkout!), radius: 10)
                    else
                      CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(dto.nameWorkout!),
                    )
                  ],
                ),
              ))
          .toList();
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              '${dataCell.dayIndex + 1}',
              style: Theme.of(context).textTheme.headline5,
            ),
            Scrollbar(
              controller: _controller,
              isAlwaysShown: true,
              child: ListView(
                controller: _controller,
                children: listListTile,
              ),
            )
          ],
        ),
      );
    }).toList());
  }
}

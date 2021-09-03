import 'package:fitnc_trainer/bloc/programme/programme.controller.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart' as sf;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../constants/constants.dart';

class ProgrammeUpdatePage extends StatelessWidget {
  ProgrammeUpdatePage({Key? key, required this.programme}) : super(key: key);

  final Programme programme;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[];
    final ProgrammeController controller = Get.put(ProgrammeController());

    controller.init(programme);

    if (controller.programme.available == true) {
      buttons.add(TextButton.icon(
        style: TextButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.unpublish().then((_) => Navigator.pop(context));
          }
        },
        label: const Text('Dépublier', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.public, color: Colors.white),
      ));
    }
    if (controller.programme.available == null || controller.programme.available == false) {
      buttons.add(TextButton.icon(
        style: TextButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.publish().then((_) => Navigator.pop(context));
          }
        },
        label: const Text('Publier', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.public, color: Colors.white),
      ));
    }
    buttons.addAll(<Widget>[
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              controller
                  .save()
                  .then(
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
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          label: const Text('Fermer', style: TextStyle(color: Colors.white))),
    ]);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  StorageStreamImageWidget(
                    onSaved: (StorageFile? storagePair) => controller.setStoragePair(storagePair),
                    streamInitialStorageFile: controller.obsStoragePair,
                    onDeleted: (StorageFile? storagePair) => controller.setStoragePair(null),
                  ),
                  Flexible(
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: FitnessDecorationTextFormField(
                                              initialValue: controller.programme.name,
                                              autofocus: true,
                                              onChanged: (String value) => controller.name = value,
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
                                                initialValue: controller.programme.numberWeeks,
                                                onChanged: (String? value) => controller.changeNumberWeek(value)),
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
                ],
              ),
            ),
            TextFormField(
              initialValue: controller.programme.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (String value) => controller.description = value,
              decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionel'),
            ),
            WorkoutSchedulePanel()
          ],
        ),
      ),
    );
  }
}

class _WorkoutChoicePanel extends StatelessWidget {
  final TrainersService trainersService = Get.find();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Workout?>>(
      stream: trainersService.listenToWorkout(),
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
                      title: Text(list[index]!.name),
                      leading: (workout?.imageUrl != null)
                          ? CircleAvatar(backgroundImage: NetworkImage(workout!.imageUrl!), radius: 10)
                          : CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10),
                    )),
                  ),
                  data: list[index],
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Icon(Icons.view_headline),
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
                      child: Text(list[index]!.name),
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
  static final TextStyle columnTextStyle = GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold);
  static final List<String> columnNames = <String>['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final ProgrammeController controller = Get.find();

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
            content: PopupDayDetail(dayIndex: dayIndex, list: list),
          );
        },
      );
    }

    return FutureBuilder<List<DropdownMenuItem<Workout>>>(
        future: controller.getWorkoutDropdownItems(),
        builder: (BuildContext context, AsyncSnapshot<List<DropdownMenuItem<Workout>>> snapshot) {
          if (snapshot.hasData) {
            final List<DropdownMenuItem<Workout>> listAvailableWorkout = snapshot.data!;
            return StreamBuilder<List<WorkoutScheduleDto>>(
              stream: controller.workoutScheduleObs,
              builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
                if (snapshot.hasData) {
                  final List<WorkoutScheduleDto> listScheduledWorkouts = snapshot.data!;
                  return SizedBox(
                    height: 800,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 125),
                      child: Container(
                        // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        padding: const EdgeInsets.all(1),
                        child: Obx(() => sf.SfDataGrid(
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
                              source: _WorkoutDataSource(
                                  context: context,
                                  numberWeeks: controller.numberWeekInt.value,
                                  listAppointment: listScheduledWorkouts,
                                  listAvailableWorkout: listAvailableWorkout,
                                  columnNames: columnNames),
                            )),
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
    required this.dayIndex,
    required this.list,
  }) : super(key: key);

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
              child: _WorkoutSelectedPanel(dayIndex: dayIndex, list: list),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: _WorkoutChoicePanel()),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutSelectedPanel extends StatelessWidget {
  _WorkoutSelectedPanel({
    Key? key,
    required this.dayIndex,
    required this.list,
  }) : super(key: key);

  final ProgrammeController controller = Get.find();
  final int dayIndex;
  final List<WorkoutScheduleDto> list;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Workout>(
        onAccept: (Workout workout) => controller.addWorkoutSchedule(workout, dayIndex - 1),
        onWillAccept: (Workout? data) => data is Workout,
        builder: (BuildContext context, List<Workout?> candidateData, List<Object?> rejectedData) {
          return Container(
            decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Column(
              children: <Widget>[
                const Text('Glisser ici les workout de la journée.'),
                StreamBuilder<List<WorkoutScheduleDto>>(
                    initialData: list,
                    stream: controller.workoutScheduleObs,
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
                                onPressed: () => controller.deleteWorkoutSchedule(dto),
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
        });
  }
}

///
/// Data d'une cellule
/// Une cellule a toujours un dayIndex mais aussi une liste des Workout à effectuer pour ce jour.
class _DataCellData {
  _DataCellData({required this.list, required this.dayIndex});

  List<WorkoutScheduleDto> list;
  int dayIndex;
}

///
/// DataSource du GridData
///
class _WorkoutDataSource extends sf.DataGridSource {
  _WorkoutDataSource(
      {required this.context,
      required this.numberWeeks,
      required this.listAppointment,
      required this.listAvailableWorkout,
      required this.columnNames}) {
    _workoutData = getListDataRows(numberWeeks, listAppointment);
  }

  BuildContext context;
  int numberWeeks;
  List<WorkoutScheduleDto> listAppointment;
  List<DropdownMenuItem<Workout>> listAvailableWorkout;
  List<DataGridRow> _workoutData = <DataGridRow>[];
  List<String> columnNames;

  /// Méthode pour générer une DataCell.
  sf.DataGridCell<_DataCellData> getDataCell(String columnName, int dayIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<WorkoutScheduleDto> list = listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();
    final _DataCellData data = _DataCellData(list: list, dayIndex: dayIndex);
    return sf.DataGridCell<_DataCellData>(value: data, columnName: columnName);
  }

  /// Méthode pour générer une DataRow.
  sf.DataGridRow getDataRow(int weekIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<sf.DataGridCell<_DataCellData>> list = <sf.DataGridCell<_DataCellData>>[];
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
      final _DataCellData dataCell = listCell.value as _DataCellData;
      final ScrollController _controller = ScrollController();
      final List<WorkoutScheduleDto> listWorkout = dataCell.list;
      final List<Widget> listListTile = listWorkout
          .map((WorkoutScheduleDto dto) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    if (dto.imageUrlWorkout != null)
                      Expanded(child: CircleAvatar(backgroundImage: NetworkImage(dto.imageUrlWorkout!), radius: 10))
                    else
                      Expanded(child: CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10)),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(dto.nameWorkout!),
                      ),
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

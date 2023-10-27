import 'package:fitnc_trainer/controller/programme/programme.controller.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.dto.dart';
import 'package:fitness_domain/widget/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart' as sf;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProgramUpdatePage extends StatelessWidget {
  ProgramUpdatePage({Key? key, required this.programme}) : super(key: key);

  final Programme programme;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProgrammeController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[];

    controller.init(programme);

    if (controller.isPublished()) {
      buttons.add(TextButton.icon(
        style: TextButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.unpublish().then((_) => Navigator.pop(context));
          }
        },
        label: Text('unpublish'.tr, style: const TextStyle(color: Colors.white)),
        icon: const Icon(Icons.public_off, color: Colors.white),
      ));
    } else {
      buttons.add(TextButton.icon(
        style: TextButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.publish().then((_) => Navigator.pop(context));
          }
        },
        label: Text('publish'.tr, style: const TextStyle(color: Colors.white)),
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
                    (_) => showToast('exerciseSaved'.tr, backgroundColor: Colors.green),
                  )
                  .catchError(
                    (_) => showToast('errorWhileSaving'.tr, backgroundColor: Colors.redAccent),
                  );
            }
          },
          icon: const Icon(Icons.save, color: Colors.white),
          label: Text('save'.tr, style: const TextStyle(color: Colors.white))),
      TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          label: Text('close'.tr, style: const TextStyle(color: Colors.white))),
    ]);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  Obx(
                    () => StorageImageWidget(
                      imageUrl: controller.programme.value.imageUrl,
                      storageFile: controller.programme.value.storageFile,
                      onSaved: controller.setStoragePair,
                      onDeleted: () => controller.setStoragePair(null),
                    ),
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
                                              initialValue: controller.programme.value.name,
                                              autofocus: true,
                                              onChanged: (String value) => controller.name = value,
                                              labelText: 'name'.tr,
                                              validator: (String? value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'fillName'.tr;
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
                                                decoration: InputDecoration(
                                                    labelText: 'weekNumber'.tr,
                                                    constraints: const BoxConstraints(
                                                        maxHeight: FitnessConstants.textFormFieldHeight),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                                                initialValue: controller.programme.value.numberWeeks,
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
              initialValue: controller.programme.value.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (String value) => controller.description = value,
              decoration: InputDecoration(labelText: 'description'.tr, helperText: 'optional'.tr),
            ),
            Scrollbar(
              controller: _scrollController,
              child: WorkoutSchedulePanel(),
            )
          ],
        ),
      ),
    );
  }
}

class _WorkoutChoicePanel extends StatelessWidget {
  final TrainersService trainersService = Get.find();

  @override
  Widget build(_) {
    return StreamBuilder<List<Workout?>>(
      stream: trainersService.listenToWorkout(),
      builder: (_, AsyncSnapshot<List<Workout?>> snapshot) {
        if (snapshot.hasData) {
          final List<Workout?> list = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (_, __) => const Divider(height: 2.0),
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
  WorkoutSchedulePanel({Key? key}) : super(key: key);

  static final TextStyle columnTextStyle = GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold);
  static final List<String> columnNames = <String>[
    'monday'.tr,
    'tuesday'.tr,
    'wednesday'.tr,
    'thursday'.tr,
    'friday'.tr,
    'saturday'.tr,
    'sunday'.tr
  ];
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
    void onCellTap(sf.DataGridCellTapDetails details, List<WorkoutScheduleDto> listAppointment) {
      final int columnIndex = details.rowColumnIndex.columnIndex;
      final int rowIndex = details.rowColumnIndex.rowIndex;
      final int dayIndex = ((rowIndex - 1) * 7) + columnIndex + 1;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          final List<WorkoutScheduleDto> list =
              listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();

          return AlertCreateWorkout(dayIndex: dayIndex, list: list);
        },
      );
    }

    return StreamBuilder<List<WorkoutScheduleDto>>(
      stream: controller.workoutScheduleObs,
      builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
        if (snapshot.hasData) {
          final List<WorkoutScheduleDto> listScheduledWorkouts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 125),
            child: Obx(
              () => SizedBox(
                height: (controller.numberWeekInt.value * 150) + 55,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  padding: const EdgeInsets.all(1),
                  child: sf.SfDataGrid(
                    verticalScrollPhysics: const NeverScrollableScrollPhysics(),
                    onCellTap: (sf.DataGridCellTapDetails details) => onCellTap(details, listScheduledWorkouts),
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
                        columnNames: columnNames),
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
  }
}

class AlertCreateWorkout extends StatelessWidget {
  const AlertCreateWorkout({
    Key? key,
    required this.dayIndex,
    required this.list,
  }) : super(key: key);

  final int dayIndex;
  final List<WorkoutScheduleDto> list;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('dayNumber'.trParams(<String, String>{'number': dayIndex.toString()})),
      actions: <Widget>[
        TextButton(
            onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    contentPadding: const EdgeInsets.all(0),
                    content: SizedBox(
                      width: 1280,
                      child: WorkoutUpdatePage(
                        workout: Workout(),
                      ),
                    ),
                  ),
                ),
            child: Text('createWorkout'.tr)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('close'.tr),
        ),
      ],
      content: PopupDayDetail(dayIndex: dayIndex, list: list),
    );
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
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
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
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Column(
              children: <Widget>[
                Text('dragWorkoutHere'.tr),
                StreamBuilder<List<WorkoutScheduleDto>>(
                    initialData: list,
                    stream: controller.workoutScheduleObs,
                    builder: (BuildContext context, AsyncSnapshot<List<WorkoutScheduleDto>> snapshot) {
                      if (snapshot.hasData) {
                        final List<WorkoutScheduleDto> listWorkout = snapshot.data!
                            .where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex - 1)
                            .toList();
                        return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (_, int index) => WorkoutTile(
                            dto: listWorkout.elementAt(index),
                          ),
                          separatorBuilder: (_, __) => const Divider(height: 2.0),
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

class WorkoutTile extends StatelessWidget {
  WorkoutTile({Key? key, required this.dto}) : super(key: key);

  final WorkoutScheduleDto dto;
  final ProgrammeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
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
      {required this.context, required this.numberWeeks, required this.listAppointment, required this.columnNames}) {
    _workoutData = getListDataRows(numberWeeks, listAppointment);
  }

  BuildContext context;
  int numberWeeks;
  List<WorkoutScheduleDto> listAppointment;
  List<DataGridRow> _workoutData = <DataGridRow>[];
  List<String> columnNames;

  /// Méthode pour générer une DataCell.
  sf.DataGridCell<_DataCellData> getDataCell(
      String columnName, int dayIndex, List<WorkoutScheduleDto> listAppointment) {
    final List<WorkoutScheduleDto> list =
        listAppointment.where((WorkoutScheduleDto element) => element.dateSchedule == dayIndex).toList();
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
          .map((WorkoutScheduleDto dto) => _WorkoutDataSourceTile(context: context, workoutScheduleDto: dto))
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
              thumbVisibility: true,
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

class _WorkoutDataSourceTile extends StatelessWidget {
  const _WorkoutDataSourceTile({
    Key? key,
    required this.context,
    required this.workoutScheduleDto,
  }) : super(key: key);

  final BuildContext context;
  final WorkoutScheduleDto workoutScheduleDto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          if (workoutScheduleDto.imageUrlWorkout != null)
            Expanded(
                child: CircleAvatar(backgroundImage: NetworkImage(workoutScheduleDto.imageUrlWorkout!), radius: 10))
          else
            Expanded(child: CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 10)),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(workoutScheduleDto.nameWorkout!),
            ),
          )
        ],
      ),
    );
  }
}

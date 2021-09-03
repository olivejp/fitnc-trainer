import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../workout.set.bottom.panel.dart';

class _FitnessWorkoutDtoConstants {
  static const double repsMaxHeight = 25;
  static const double repsMaxWidth = 70;
  static const double weightMaxHeight = 25;
  static const double weightMaxWidth = 100;
  static const double crossMaxHeight = 25;
  static const double crossMaxWidth = 70;
}

class ListTileDto extends StatefulWidget {
  const ListTileDto({
    Key? key,
    required this.dto,
  }) : super(key: key);
  final WorkoutSetDto dto;

  @override
  State<ListTileDto> createState() => _ListTileDtoState();
}

class _ListTileDtoState extends State<ListTileDto> {
  late BehaviorSubject<List<Line>> streamLines = BehaviorSubject<List<Line>>.seeded(widget.dto.lines);

  final WorkoutSetBottomPanelController controller = Get.find();

  @override
  void dispose() {
    streamLines.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget leading = widget.dto.imageUrlExercice != null
        ? CircleAvatar(
            foregroundImage: NetworkImage(widget.dto.imageUrlExercice!),
            radius: 10,
          )
        : Icon(
            Icons.sports_volleyball,
            size: 10,
            color: Theme.of(context).primaryColor,
          );
    return ListTile(
      dense: true,
      minLeadingWidth: 20,
      leading: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Draggable<WorkoutSetDto>(
          data: widget.dto,
          feedback: SizedBox(
            width: 200,
            height: 80,
            child: Card(
              child: ListTile(
                  leading: CircleAvatar(foregroundImage: widget.dto.imageUrlExercice != null ? NetworkImage(widget.dto.imageUrlExercice!) : null),
                  title: Text(widget.dto.nameExercice!)),
            ),
          ),
          child: const Icon(Icons.view_headline),
        ),
      ),
      title: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: leading,
                    ),
                    Flexible(
                      child: Text(
                        widget.dto.nameExercice!,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        widget.dto.lines.add(Line());
                        streamLines.sink.add(widget.dto.lines);
                      },
                      child: const Text('Ajouter set')),
                  TextButton(onPressed: () => controller.deleteWorkoutSet(widget.dto), child: const Text('Retirer'))
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: StreamBuilder<List<Line>>(
                stream: streamLines,
                builder: (BuildContext context, AsyncSnapshot<List<Line>> snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.dto.lines.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _LineDisplay(dto: widget.dto, index: index, stream: streamLines);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _LineDisplay extends StatelessWidget {
  _LineDisplay({required this.dto, required this.index, required this.stream});

  final WorkoutSetDto dto;
  final int index;
  final Subject<List<Line>> stream;
  final WorkoutSetBottomPanelController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final List<Widget> listChildren = <Widget>[];
    final Line line = dto.lines.elementAt(index);
    final GlobalKey<FormFieldState<String>> restTimeKey = GlobalKey<FormFieldState<String>>();
    final GlobalKey iconButtonKey = GlobalKey();
    final GlobalKey lineKey = GlobalKey();

    late Widget returnedWidget;

    switch (dto.typeExercice) {
      case 'REPS_WEIGHT':
        returnedWidget = _RepsWeightLineBuilder(key: lineKey, line: line, dto: dto);
        break;
      case 'REPS_ONLY':
        returnedWidget = _RepsOnlyLineBuilder(key: lineKey, line: line, dto: dto);
        break;
      case 'TIME':
        returnedWidget = _TimeLineBuilder(key: lineKey, line: line, dto: dto);
        break;
      default:
        returnedWidget = Container();
    }
    listChildren.add(returnedWidget);

    final Widget reposDropdown = LimitedBox(
      maxHeight: 25,
      maxWidth: 100,
      child: TimerDropdownButton(
        key: restTimeKey,
        icon: const Icon(
          Icons.arrow_downward,
          size: 12,
        ),
        onlyName: true,
        insertNull: true,
        nullElement: 'Aucun repos',
        decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
        style: const TextStyle(fontSize: 12),
        initialValue: line.restTime,
        onChanged: (String? value) => controller.setRestTime(dto, line, value),
      ),
    );
    listChildren.add(reposDropdown);

    if (dto.lines.length > 1) {
      listChildren.add(IconButton(
          key: iconButtonKey,
          onPressed: () {
            if (dto.lines.length > 1) {
              dto.lines.removeAt(index);
              stream.sink.add(dto.lines);
              controller.updateWorkoutSet(dto);
            }
          },
          icon: const Icon(
            Icons.close,
            color: Colors.grey,
          )));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: listChildren,
    );
  }
}

/// Widget Line dans le cas d'un Time
class _TimeLineBuilder extends StatelessWidget {
  _TimeLineBuilder({Key? key, required this.line, required this.dto}) : super(key: key);

  final WorkoutSetDto dto;
  final Line line;
  final WorkoutSetBottomPanelController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormFieldState<String>> timeKey = GlobalKey<FormFieldState<String>>();
    return Row(
      children: <Widget>[
        LimitedBox(
          maxHeight: 25,
          maxWidth: 150,
          child: TimerDropdownButton(
            key: timeKey,
            icon: const Icon(
              Icons.arrow_downward,
              size: 12,
            ),
            onlyName: true,
            decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
            style: const TextStyle(fontSize: 12),
            hint: const Text('Temps', style: TextStyle(fontSize: 10)),
            initialValue: line.time,
            onChanged: (String? value) => controller.setTime(dto, line, value),
          ),
        ),
      ],
    );
  }
}

/// Widget Line dans le cas d'un Reps Only
class _RepsOnlyLineBuilder extends StatelessWidget {
  _RepsOnlyLineBuilder({Key? key, required this.dto, required this.line}) : super(key: key);

  final WorkoutSetDto dto;
  final Line line;
  final WorkoutSetBottomPanelController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize: 15);
    const TextStyle textStyleHint = TextStyle(fontSize: 12);
    return Row(
      children: <Widget>[
        LimitedBox(
          maxHeight: _FitnessWorkoutDtoConstants.repsMaxHeight,
          maxWidth: _FitnessWorkoutDtoConstants.repsMaxWidth,
          child: TextFormField(
            initialValue: line.reps,
            buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) => null,
            maxLength: 3,
            textAlignVertical: TextAlignVertical.bottom,
            style: textStyle,
            onChanged: (String value) => controller.setReps(dto, line, value),
            decoration: const InputDecoration(
              hintText: 'Reps',
              hintStyle: textStyleHint,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget Line dans le cas d'un Reps Weight
class _RepsWeightLineBuilder extends StatelessWidget {
  _RepsWeightLineBuilder({Key? key, required this.dto, required this.line}) : super(key: key);
  final WorkoutSetDto dto;
  final Line line;
  final WorkoutSetBottomPanelController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize: 15);
    const TextStyle textStyleHint = TextStyle(fontSize: 12);
    return Row(children: <Widget>[
      LimitedBox(
        maxHeight: _FitnessWorkoutDtoConstants.repsMaxHeight,
        maxWidth: _FitnessWorkoutDtoConstants.repsMaxWidth,
        child: TextFormField(
          initialValue: line.reps,
          buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) => null,
          maxLength: 3,
          textAlignVertical: TextAlignVertical.bottom,
          style: textStyle,
          onChanged: (String value) => controller.setReps(dto, line, value),
          decoration: const InputDecoration(
            hintText: 'Reps',
            hintStyle: textStyleHint,
          ),
        ),
      ),
      const LimitedBox(
        maxHeight: _FitnessWorkoutDtoConstants.crossMaxHeight,
        maxWidth: _FitnessWorkoutDtoConstants.crossMaxWidth,
        child: Text(' x '),
      ),
      LimitedBox(
        maxHeight: _FitnessWorkoutDtoConstants.weightMaxHeight,
        maxWidth: _FitnessWorkoutDtoConstants.weightMaxWidth,
        child: TextFormField(
          initialValue: line.weight,
          textAlignVertical: TextAlignVertical.bottom,
          style: textStyle,
          onChanged: (String value) => controller.setWeight(dto, line, value),
          decoration: const InputDecoration(
            hintText: 'Weight',
            hintStyle: textStyleHint,
          ),
        ),
      ),
    ]);
  }
}

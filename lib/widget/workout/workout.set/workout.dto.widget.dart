import 'dart:async';

import 'package:fitnc_trainer/bloc/workout/workout_set_left_panel.bloc.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ListTileDto extends StatefulWidget {
  const ListTileDto({
    Key? key,
    required this.bloc,
    required this.dto,
  }) : super(key: key);

  final WorkoutSetLeftPanelBloc bloc;
  final WorkoutSetDto dto;

  @override
  State<ListTileDto> createState() => _ListTileDtoState();
}

class _ListTileDtoState extends State<ListTileDto> {
  late BehaviorSubject<List<Line>> streamLines = BehaviorSubject<List<Line>>.seeded(widget.dto.lines);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 20,
      leading: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Draggable<WorkoutSetDto>(
          data: widget.dto,
          feedback: SizedBox(
            width: 200,
            height: 100,
            child: Text(widget.dto.nameExercice!),
          ),
          child: const Icon(Icons.view_headline),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.dto.nameExercice!,
                style: const TextStyle(fontSize: 14),
              ),
              TextButton(
                  onPressed: () {
                    widget.dto.lines.add(Line());
                    streamLines.sink.add(widget.dto.lines);
                  },
                  child: const Text('Ajouter set'))
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
                      return LineDisplay(dto: widget.dto, index: index, bloc: widget.bloc, stream: streamLines);
                    },
                  );
                }),
          ),
        ],
      ),
      trailing: IconButton(
        tooltip: "Supprimer l'exercice",
        onPressed: () => widget.bloc.deleteWorkoutSet(widget.dto),
        icon: const Icon(
          Icons.delete,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class LineDisplay extends StatelessWidget {
  const LineDisplay({required this.bloc, required this.dto, required this.index, required this.stream});

  final WorkoutSetLeftPanelBloc bloc;
  final WorkoutSetDto dto;
  final int index;
  final Subject<List<Line>> stream;

  @override
  Widget build(BuildContext context) {
    final Line line = dto.lines.elementAt(index);
    final Widget trailingWidget = dto.lines.length > 1
        ? IconButton(
            onPressed: () {
              if (dto.lines.length > 1) {
                dto.lines.removeAt(index);
                stream.sink.add(dto.lines);
                bloc.updateWorkoutSet(dto);
              }
            },
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
            ))
        : Container();
    Widget returnedWidget;
    final GlobalKey<FormFieldState<String>> restTimeKey = GlobalKey<FormFieldState<String>>();
    switch (dto.typeExercice) {
      case 'REPS_WEIGHT':
        returnedWidget = RepsWeightLineBuilder(bloc: bloc, line: line, dto: dto);
        break;
      case 'REPS_ONLY':
        returnedWidget = RepsOnlyLineBuilder(bloc: bloc, line: line, dto: dto);
        break;
      case 'TIME':
        returnedWidget = TimeLineBuilder(bloc: bloc, line: line, dto: dto);
        break;
      default:
        returnedWidget = Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        returnedWidget,
        LimitedBox(
          maxHeight: 25,
          maxWidth: 150,
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
            hint: const Text('Repos', style: TextStyle(fontSize: 10)),
            initialValue: line.restTime,
            onChanged: (String? value) => bloc.setRestTime(dto, line, value),
          ),
        ),
        trailingWidget
      ],
    );
  }
}

class TimeLineBuilder extends StatefulWidget {
  const TimeLineBuilder({Key? key, required this.bloc, required this.line, required this.dto}) : super(key: key);

  final WorkoutSetDto dto;
  final Line line;
  final WorkoutSetLeftPanelBloc bloc;

  @override
  State<TimeLineBuilder> createState() => _TimeLineBuilderState();
}

class _TimeLineBuilderState extends State<TimeLineBuilder> {
  final GlobalKey<FormFieldState<String>> timeKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
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
            initialValue: widget.line.time,
            onChanged: (String? value) => widget.bloc.setTime(widget.dto, widget.line, value),
          ),
        ),
      ],
    );
  }
}

class RepsOnlyLineBuilder extends StatefulWidget {
  const RepsOnlyLineBuilder({Key? key, required this.bloc, required this.dto, required this.line}) : super(key: key);

  final WorkoutSetLeftPanelBloc bloc;
  final WorkoutSetDto dto;
  final Line line;

  @override
  State<RepsOnlyLineBuilder> createState() => _RepsOnlyLineBuilderState();
}

class _RepsOnlyLineBuilderState extends State<RepsOnlyLineBuilder> {
  final GlobalKey<FormFieldState<String>> repsOnlyKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        LimitedBox(
          maxHeight: 25,
          maxWidth: 60,
          child: TextFormField(
            key: repsOnlyKey,
            maxLength: 3,
            initialValue: widget.line.reps,
            onChanged: (String value) => widget.bloc.setReps(widget.dto, widget.line, value),
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Reps',
              hintStyle: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class RepsWeightLineBuilder extends StatefulWidget {
  const RepsWeightLineBuilder({Key? key, required this.bloc, required this.dto, required this.line}) : super(key: key);

  final WorkoutSetLeftPanelBloc bloc;
  final WorkoutSetDto dto;
  final Line line;

  @override
  State<RepsWeightLineBuilder> createState() => _RepsWeightLineBuilderState();
}

class _RepsWeightLineBuilderState extends State<RepsWeightLineBuilder> {
  GlobalKey<FormFieldState<String>> repsKey = GlobalKey<FormFieldState<String>>();
  GlobalKey<FormFieldState<String>> weighKey = GlobalKey<FormFieldState<String>>();
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      LimitedBox(
        maxHeight: 25,
        maxWidth: 70,
        child: TextFormField(
          key: repsKey,
          initialValue: widget.line.reps,
          buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) => null,
          maxLength: 3,
          textAlignVertical: TextAlignVertical.bottom,
          style: const TextStyle(fontSize: 15),
          onChanged: (String value) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              widget.bloc.setReps(widget.dto, widget.line, value);
            });
          },
          decoration: const InputDecoration(
            hintText: 'Reps',
            hintStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
      const LimitedBox(
        maxHeight: 25,
        maxWidth: 70,
        child: Text(' x '),
      ),
      LimitedBox(
        maxHeight: 25,
        maxWidth: 100,
        child: TextFormField(
          key: weighKey,
          initialValue: widget.line.weight,
          textAlignVertical: TextAlignVertical.bottom,
          style: const TextStyle(fontSize: 15),
          onChanged: (String value) => widget.bloc.setWeight(widget.dto, widget.line, value),
          decoration: const InputDecoration(
            hintText: 'Weight',
            hintStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    ]);
  }
}
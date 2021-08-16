import 'package:dotted_border/dotted_border.dart';
import 'package:fitnc_trainer/bloc/workout/workout_set_left_panel.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/widget/workout/workout.set/workout.dto.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class WorkoutSetLeftPanel extends StatelessWidget {
  WorkoutSetLeftPanel({Key? key, required this.workout}) : super(key: key) {
    bloc.init(workout);
  }

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final WorkoutSetLeftPanelBloc bloc = WorkoutSetLeftPanelBloc.getInstance();
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: StreamBuilder<List<WorkoutSetDto>>(
          stream: bloc.obsListWorkoutSet,
          builder: (BuildContext context, AsyncSnapshot<List<WorkoutSetDto>> snapshot) {
            if (snapshot.hasData) {
              final List<WorkoutSetDto?> listWorkoutSetDto = snapshot.data!;
              final Widget liste = ListView.separated(
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 2),
                itemCount: listWorkoutSetDto.length,
                itemBuilder: (BuildContext context, int index) => DragTargetDto(dto: listWorkoutSetDto.elementAt(index)!, bloc: bloc),
              );
              final Widget mainColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Glisser ici les exercices du workout.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: liste),
                ],
              );
              return DragTarget<Exercice>(
                onWillAccept: (Exercice? exerciceToAccept) => exerciceToAccept is Exercice,
                onAccept: (Exercice exerciceDragged) => bloc.addWorkoutSet(exerciceDragged),
                builder: (BuildContext context, List<Exercice?> candidateData, List<dynamic> rejectedData) {
                  Color color = Colors.transparent;
                  if (candidateData.isNotEmpty) {
                    color = Theme.of(context).primaryColor;
                  }
                  return Container(
                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), border: Border.all(color: color, width: 4)),
                    child: mainColumn,
                  );
                },
              );
            } else {
              return LoadingRotating.square(
                backgroundColor: Theme.of(context).primaryColor,
              );
            }
          },
        ),
      ),
    );
  }
}

class DragTargetDto extends StatelessWidget {
  const DragTargetDto({required this.dto, required this.bloc});

  final WorkoutSetDto dto;
  final WorkoutSetLeftPanelBloc bloc;

  @override
  Widget build(BuildContext context) {
    final Widget upWidget = ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: DottedBorder(
        color: Theme.of(context).primaryColor,
        radius: const Radius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.arrow_circle_down,
                color: Theme.of(context).primaryColor,
              ),
              Center(child: Text('Déplacer ici', style: TextStyle(color: Theme.of(context).primaryColor))),
            ],
          ),
        ),
      ),
    );
    return DragTarget<WorkoutSetDto>(
      onWillAccept: (WorkoutSetDto? data) => data is WorkoutSetDto && data.uid != dto.uid,
      onAccept: (WorkoutSetDto data) => bloc.switchOrder(data, dto.order),
      builder: (BuildContext context, List<WorkoutSetDto?> candidateData, List<dynamic> rejectedData) {
        final Widget tile = ListTileDto(bloc: bloc, dto: dto);
        if (candidateData.isNotEmpty) {
          return Column(children: <Widget>[upWidget, tile]);
        } else {
          return tile;
        }
      },
    );
  }
}

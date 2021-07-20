import 'package:dotted_border/dotted_border.dart';
import 'package:fitnc_trainer/bloc/workout/workout.set.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class WorkoutSetLeftPanel extends StatelessWidget {
  final WorkoutSetPageBloc bloc = WorkoutSetPageBloc.getInstance();
  final Workout workout;
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  WorkoutSetLeftPanel({Key? key, required this.workout}) : super(key: key) {
    bloc.init(this.workout);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 10,
        child: StreamBuilder<List<WorkoutSetDto>>(
          stream: bloc.obsListWorkoutSet,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<WorkoutSetDto?> listWorkoutSetDto = snapshot.data!;
              return DragTarget<Exercice>(
                onWillAccept: (exerciceToAccept) => (exerciceToAccept is Exercice),
                onAccept: (exerciceDragged) => bloc.addWorkoutSet(exerciceDragged),
                builder: (context, candidateData, rejectedData) {
                  Color color = Colors.transparent;
                  if (candidateData.isNotEmpty) {
                    color = Colors.amber;
                  }
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)), border: Border.all(style: BorderStyle.solid, color: color, width: 4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Glisser ici les exercices du workout.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              TextButton(
                                  onPressed: () => print('hello'),
                                  child: Container(
                                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text('Ajouter repos', style: TextStyle(color: Colors.white)),
                                      )))
                            ],
                          ),
                        ),
                        Expanded(
                            child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(height: 2),
                          itemCount: listWorkoutSetDto.length,
                          itemBuilder: (context, index) => getListTile(listWorkoutSetDto.elementAt(index)!, listWorkoutSetDto),
                        )),
                      ],
                    ),
                  );
                },
              );
            } else {
              return LoadingFlipping.circle();
            }
          },
        ),
      ),
    );
  }

  Widget mapWorkoutSetDto(WorkoutSetDto dto) {
    Widget returnedWidget;
    final GlobalKey<FormFieldState> setsKey = GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> repsKey = GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> repsOnlyKey = GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> weighKey = GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> timeKey = GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> restTimeKey = GlobalKey<FormFieldState>();
    switch (dto.typeExercice) {
      case 'REPS_WEIGHT':
        returnedWidget = Row(children: [
          LimitedBox(
            maxHeight: 25,
            maxWidth: 70,
            child: TextFormField(
              key: repsKey,
              initialValue: dto.reps,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              maxLength: 3,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 15),
              onChanged: (value) => bloc.setReps(dto, value),
              decoration: InputDecoration(
                hintText: 'Reps',
                hintStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
          LimitedBox(
            maxHeight: 25,
            maxWidth: 70,
            child: Text(' x '),
          ),
          LimitedBox(
            maxHeight: 25,
            maxWidth: 100,
            child: TextFormField(
              key: weighKey,
              initialValue: dto.weight,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 15),
              onChanged: (value) => bloc.setWeight(dto, value),
              decoration: InputDecoration(
                hintText: 'Weight',
                hintStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ]);
        break;
      case 'REPS_ONLY':
        returnedWidget = Row(
          children: [
            LimitedBox(
              maxHeight: 25,
              maxWidth: 60,
              child: TextFormField(
                key: repsOnlyKey,
                maxLength: 3,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Reps',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        );
        break;
      case 'TIME':
        returnedWidget = Row(
          children: [
            LimitedBox(
              maxHeight: 25,
              maxWidth: 150,
              child: ParamDropdownButton(
                key: timeKey,
                icon: Icon(
                  Icons.arrow_downward,
                  size: 12,
                ),
                onlyValue: true,
                decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
                style: TextStyle(fontSize: 12),
                hint: Text('Temps', style: TextStyle(fontSize: 10)),
                paramName: 'combo_time',
                initialValue: dto.time,
                onChanged: (value) => bloc.setTime(dto, value),
              ),
            ),
          ],
        );
        break;
      default:
        returnedWidget = Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LimitedBox(
          maxHeight: 25,
          maxWidth: 70,
          child: TextFormField(
            key: setsKey,
            initialValue: dto.sets,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            maxLength: 3,
            maxLines: 1,
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyle(fontSize: 15),
            onChanged: (value) => bloc.setSets(dto, value),
            decoration: InputDecoration(
              hintText: 'Sets',
              hintStyle: TextStyle(fontSize: 12),
            ),
          ),
        ),
        returnedWidget,
        LimitedBox(
          maxHeight: 25,
          maxWidth: 150,
          child: TimerDropdownButton(
            key: restTimeKey,
            icon: Icon(
              Icons.arrow_downward,
              size: 12,
            ),
            onlyName: true,
            insertNull: true,
            nullElement: 'Aucun repos',
            decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
            style: TextStyle(fontSize: 12),
            hint: Text('Repos', style: TextStyle(fontSize: 10)),
            initialValue: dto.restTime,
            onChanged: (value) => bloc.setRestTime(dto, value),
          ),
        )
      ],
    );
  }

  Widget getListTile(WorkoutSetDto dto, List<WorkoutSetDto?> listWorkout) {
    return DragTarget<WorkoutSetDto>(
      onWillAccept: (data) => (data is WorkoutSetDto && data.uid != dto.uid),
      onAccept: (data) => bloc.switchOrder(data, dto.order),
      builder: (context, candidateData, rejectedData) {
        Widget upWidget = ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: DottedBorder(
            color: Colors.amber,
            strokeWidth: 1,
            radius: Radius.circular(5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.arrow_circle_down,
                    color: Colors.amber.shade300,
                  ),
                  Center(
                      child: Text(
                    'Déplacer ici',
                    style: TextStyle(color: Colors.amber.shade300),
                  )),
                ],
              ),
            ),
          ),
        );
        Widget tile = ListTile(
          leading: Draggable<WorkoutSetDto>(
            child: Icon(Icons.view_headline),
            data: dto,
            feedback: SizedBox(
              child: Text(dto.nameExercice!),
              width: 200,
              height: 100,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dto.nameExercice!),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: mapWorkoutSetDto(dto),
              ),
            ],
          ),
          trailing: IconButton(onPressed: () => bloc.deleteWorkoutSet(dto), icon: Icon(Icons.delete)),
        );
        if (candidateData.isNotEmpty) {
          return Column(
            children: [upWidget, tile],
          );
        } else {
          return tile;
        }
      },
    );
  }
}

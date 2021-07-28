import 'package:dotted_border/dotted_border.dart';
import 'package:fitnc_trainer/bloc/workout/workout_set_left_panel.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 10,
        child: StreamBuilder<List<WorkoutSetDto>>(
          stream: bloc.obsListWorkoutSet,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<WorkoutSetDto?> listWorkoutSetDto = snapshot.data!;
              final Widget liste = ListView.separated(
                separatorBuilder: (context, index) => const Divider(height: 2),
                itemCount: listWorkoutSetDto.length,
                itemBuilder: (context, index) => getListTile(context, listWorkoutSetDto.elementAt(index)!, listWorkoutSetDto),
              );
              final Widget mainColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Glisser ici les exercices du workout.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        TextButton(
                            onPressed: () => print('hello'),
                            child: Container(
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text('Ajouter repos', style: TextStyle(color: Colors.white)),
                                )))
                      ],
                    ),
                  ),
                  Expanded(child: liste),
                ],
              );
              return DragTarget<Exercice>(
                onWillAccept: (exerciceToAccept) => (exerciceToAccept is Exercice),
                onAccept: (exerciceDragged) => bloc.addWorkoutSet(exerciceDragged),
                builder: (context, candidateData, rejectedData) {
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
              return LoadingRotating.square(backgroundColor: Theme.of(context).primaryColor,);
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
              buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) => null,
              maxLength: 3,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 15),
              onChanged: (String value) => bloc.setReps(dto, value),
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
              initialValue: dto.weight,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 15),
              onChanged: (String value) => bloc.setWeight(dto, value),
              decoration: const InputDecoration(
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
                initialValue: dto.reps,
                onChanged: (value) => bloc.setReps(dto, value),
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
        break;
      case 'TIME':
        returnedWidget = Row(
          children: [
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
                insertNull: false,
                decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
                style: const TextStyle(fontSize: 12),
                hint: const Text('Temps', style: TextStyle(fontSize: 10)),
                initialValue: dto.time,
                onChanged: (String? value) => bloc.setTime(dto, value),
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
            buildCounter: (BuildContext context, {required currentLength, required isFocused, int? maxLength}) => null,
            maxLength: 3,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 15),
            onChanged: (String value) => bloc.setSets(dto, value),
            decoration: const InputDecoration(
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
            initialValue: dto.restTime,
            onChanged: (String? value) => bloc.setRestTime(dto, value),
          ),
        )
      ],
    );
  }

  Widget getListTile(BuildContext context,WorkoutSetDto dto, List<WorkoutSetDto?> listWorkout) {
    final Widget upWidget = ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: DottedBorder(
        color: Theme.of(context).primaryColor,
        strokeWidth: 1,
        radius: const Radius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
      onWillAccept: (data) => data is WorkoutSetDto && data.uid != dto.uid,
      onAccept: (data) => bloc.switchOrder(data, dto.order),
      builder: (context, candidateData, rejectedData) {
        final Widget tile = ListTile(
          dense: true,
          minLeadingWidth: 20,
          leading: Draggable<WorkoutSetDto>(
            data: dto,
            feedback: SizedBox(
              width: 200,
              height: 100,
              child: Text(dto.nameExercice!),
            ),
            child: const Icon(Icons.view_headline),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dto.nameExercice!, style: TextStyle(fontSize: 14),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: mapWorkoutSetDto(dto),
              ),
            ],
          ),
          trailing: IconButton(
            tooltip: 'Supprimer l\'exercice',
            onPressed: () => bloc.deleteWorkoutSet(dto),
            icon: const Icon(Icons.delete,  color: Colors.grey,),
          ),
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

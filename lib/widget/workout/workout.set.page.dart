import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
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
import 'package:rxdart/rxdart.dart';

class WorkoutSetPage extends StatelessWidget {
  final TrainersService trainersService = TrainersService.getInstance();
  final Workout workout;
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  WorkoutSetPage({Key? key, required this.workout}) : super(key: key);

  void switchOrder(WorkoutSetDto dto, List<WorkoutSetDto?> dtos, int newOrder) {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    FieldValue increment = FieldValue.increment(1);
    dtos.where((element) => element!.order >= newOrder).forEach((element) {
      writeBatch.update(trainersService.getWorkoutSetsReference(workout).doc(element!.uid), {'order': increment});
    });
    writeBatch.update(trainersService.getWorkoutSetsReference(workout).doc(dto.uid), {'order': newOrder});
    writeBatch.commit();
  }

  Widget getSecondLine(WorkoutSetDto dto) {
    switch (dto.typeExercice) {
      case 'REPS_WEIGHT':
        return Row(
          children: [
            LimitedBox(
              maxHeight: 25,
              maxWidth: 100,
              child: TextFormField(
                maxLines: 1,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontSize: 15),
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
                maxLines: 1,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Weight',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        );
      case 'REPS_ONLY':
        return Row(
          children: [
            LimitedBox(
              maxHeight: 25,
              maxWidth: 60,
              child: TextFormField(
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
      case 'TIME':
        return Row(
          children: [
            LimitedBox(
              maxHeight: 25,
              maxWidth: 150,
              child: ParamDropdownButton(
                icon: Icon(
                  Icons.arrow_downward,
                  size: 12,
                ),
                onlyValue: true,
                decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
                style: TextStyle(fontSize: 12),
                hint: Text('Type d\'exercice', style: TextStyle(fontSize: 10)),
                paramName: 'type_exercice',
                initialValue: null,
                onChanged: (onChangedValue) => print(onChangedValue),
              ),
              // TextFormField(
              //   textAlignVertical: TextAlignVertical.bottom,
              //   style: TextStyle(fontSize: 15),
              //   decoration: InputDecoration(
              //     hintText: 'Temps',
              //     hintStyle: TextStyle(fontSize: 12),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //     ),
              //   ),
              // ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget getListTile(WorkoutSetDto dto, List<WorkoutSetDto?> listWorkout) {
    return DragTarget<WorkoutSetDto>(
      onWillAccept: (data) => (data is WorkoutSetDto && data.uid != dto.uid),
      onAccept: (data) => switchOrder(data, listWorkout, dto.order),
      builder: (context, candidateData, rejectedData) {
        Widget upWidget = ListTile(
          title: Text('Déplacer ici'),
          tileColor: Colors.amber,
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
                child: getSecondLine(dto),
              ),
            ],
          ),
          trailing: IconButton(
              onPressed: () => trainersService.getWorkoutSetsReference(workout).doc(dto.uid).delete().then((value) => print('OK')),
              icon: Icon(Icons.delete)),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Colors.tealAccent,
            elevation: 5,
            child: StreamBuilder<List<WorkoutSetDto?>>(
              stream: trainersService.listenToWorkoutStepDto(workout),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<WorkoutSetDto?> listWorkoutSetDto = snapshot.data!;
                  return DragTarget<Exercice>(
                    onWillAccept: (exerciceToAccept) => (exerciceToAccept is Exercice),
                    onAccept: (exerciceDragged) {
                      WorkoutSet set = WorkoutSet(uidExercice: exerciceDragged.uid);
                      set.uid = trainersService.getWorkoutSetsReference(workout).doc().id;
                      int maxOrder = 0;
                      listWorkoutSetDto.forEach((workoutSet) {
                        if (workoutSet!.order > maxOrder) {
                          maxOrder = workoutSet.order;
                        }
                      });
                      set.order = maxOrder + 1;
                      trainersService.getWorkoutSetsReference(workout).doc(set.uid).set(set.toJson()).then((value) => print('OK'));
                    },
                    builder: (context, candidateData, rejectedData) {
                      Color color = Colors.transparent;
                      if (candidateData.isNotEmpty) {
                        color = Colors.amber;
                      }
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(style: BorderStyle.solid, color: color, width: 4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Glisser ici les exercices du workout.', style: TextStyle(fontStyle: FontStyle.italic),),
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
                  return Text('Aucun set trouvé pour ce workout.');
                }
              },
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          'Exercices',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        )),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Recherche...',
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Exercice?>>(
                  stream: trainersService.listenToExercice(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                      return Center(child: Text('Aucun exercice trouvé.'));
                    } else {
                      List<Exercice?> listExercice = snapshot.data!;
                      return getGridView(listExercice);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getGridView(List<Exercice?> listExercice) {
    return LayoutBuilder(builder: (context, constraints) {
      int nbColumns = 2;
      if (constraints.maxWidth > 1200) {
        nbColumns = 8;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 6;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 3;
      }

      return GridView.count(
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listExercice.map((exercice) {
          if (exercice != null) {
            Widget gridCard = getGridCard(context, exercice);
            return Draggable<Exercice>(
              feedback: gridCard,
              data: exercice,
              child: InkWell(
                splashColor: Colors.amber,
                hoverColor: Colors.amber,
                borderRadius: BorderRadius.circular(10),
                onTap: () => print('Hello'),
                child: gridCard,
              ),
            );
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  Widget getGridCard(BuildContext context, Exercice exercice) {
    Widget firstChild;
    if (exercice.imageUrl != null) {
      firstChild = Image.network(
        exercice.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return LoadingBouncingGrid.circle();
        },
      );
    } else {
      firstChild = Container(
        decoration: BoxDecoration(color: Color(Colors.amber.value)),
      );
    }
    return LimitedBox(
      maxHeight: 100,
      maxWidth: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(flex: 3, child: firstChild),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Center(
                  child: Text(
                    exercice.name,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        elevation: 2,
      ),
    );
  }
}

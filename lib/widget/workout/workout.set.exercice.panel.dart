import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.set/workout.dto.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/line.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_set.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

///
/// Panel bas qui présente la liste des exercices affectés au Workout
///
class WorkoutSetExercicePanel extends StatelessWidget {
  WorkoutSetExercicePanel({Key? key, required this.workout}) : super(key: key);

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final Workout workout;
  final WorkoutSetExercicePanelController controller = Get.put(WorkoutSetExercicePanelController());

  @override
  Widget build(BuildContext context) {
    controller.init(workout);
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: StreamBuilder<List<WorkoutSet>>(
        stream: controller.obsListWorkoutSet,
        builder: (BuildContext context, AsyncSnapshot<List<WorkoutSet>> snapshot) {
          if (snapshot.hasData) {
            final List<WorkoutSet?> listWorkoutSet = snapshot.data!;
            final Widget mainColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Text(
                        'Glisser ici les exercices du workout.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) => const Divider(height: 2),
                  itemCount: listWorkoutSet.length,
                  itemBuilder: (BuildContext context, int index) => _DragTargetDto(dto: listWorkoutSet.elementAt(index)!),
                )),
              ],
            );
            return DragTarget<Exercice>(
              onWillAccept: (Exercice? exerciceToAccept) => exerciceToAccept is Exercice,
              onAccept: (Exercice exerciceDragged) => controller.addWorkoutSet(exerciceDragged),
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
    );
  }
}

class _DragTargetDto extends StatelessWidget {
  _DragTargetDto({required this.dto});

  final WorkoutSet dto;
  final WorkoutSetExercicePanelController controller = Get.find();

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
    return DragTarget<WorkoutSet>(
      onWillAccept: (WorkoutSet? data) => data is WorkoutSet && data.uid != dto.uid,
      onAccept: (WorkoutSet data) => controller.switchOrder(data, dto.order),
      builder: (BuildContext context, List<WorkoutSet?> candidateData, List<dynamic> rejectedData) {
        final Widget tile = ListTileDto(dto: dto);
        if (candidateData.isNotEmpty) {
          return Column(children: <Widget>[upWidget, tile]);
        } else {
          return tile;
        }
      },
    );
  }
}

///
/// ViewModel pour la partie basse de l'écran de mise à jour d'un workout
///
class WorkoutSetExercicePanelController extends GetxController {
  final WorkoutSetService workoutSetService = Get.find();
  final int debounceTime = 200;
  final List<WorkoutSet> listDtos = <WorkoutSet>[];
  final BehaviorSubject<List<WorkoutSet>> subjectListDtos = BehaviorSubject<List<WorkoutSet>>();

  late Workout _workout;

  Stream<List<WorkoutSet>> get obsListWorkoutSet => subjectListDtos.stream;
  Timer? _debounce;

  void init(Workout workout) {
    listDtos.clear();
    subjectListDtos.sink.add(listDtos);
    _workout = workout;
    workoutSetService.getAllWorkoutSet(_workout).then((List<WorkoutSet> remoteList) {
      listDtos.addAll(remoteList);
      subjectListDtos.sink.add(listDtos);
    });
  }

  int getMaxOrder(List<WorkoutSet>? listWorkoutSet) {
    int maxOrder = 0;
    if (listWorkoutSet != null) {
      for (final WorkoutSet dto in listWorkoutSet) {
        if (dto.order > maxOrder) {
          maxOrder = dto.order;
        }
      }
    }
    return maxOrder + 1;
  }

  void deleteWorkoutSet(WorkoutSet dto) {
    listDtos.remove(dto);
    deleteFromFireStore(dto);
    subjectListDtos.sink.add(listDtos);
  }

  void addWorkoutSet(Exercice exerciceDragged) {
    final WorkoutSet workoutset = WorkoutSet();
    workoutset.uid = workoutSetService.getNewUid(_workout);
    workoutset.uidWorkout = _workout.uid!;
    workoutset.uidExercice = exerciceDragged.uid!;
    workoutset.typeExercice = exerciceDragged.typeExercice;
    workoutset.nameExercice = exerciceDragged.name;
    workoutset.imageUrlExercice = exerciceDragged.imageUrl;
    workoutset.order = getMaxOrder(listDtos);
    workoutset.lines.add(Line());
    workoutSetService.save(WorkoutSet.fromJson(workoutset.toJson())).then((_) {
      listDtos.add(workoutset);
      subjectListDtos.sink.add(listDtos);
    }).catchError(
        (error) => showToast("Une erreur est survenue lors de l'enregistrement du set : ${error.toString()}", duration: const Duration(seconds: 2)));
  }

  void deleteFromFireStore(WorkoutSet dto) {
    workoutSetService
        .delete(WorkoutSet.fromJson(dto.toJson()))
        .catchError((Object onError) => showToast('Erreur lors de la suppression du Set.', duration: const Duration(seconds: 2)));
  }

  void switchOrder(WorkoutSet workoutSetToMove, int newOrder) {
    int order = newOrder;
    final bool isDescente = workoutSetToMove.order < order;
    if (isDescente) {
      order = order - 1;
    }
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    // Mise à jour des DTO suivants pour les décaler tous.
    if (listDtos.isNotEmpty) {
      listDtos.where((WorkoutSet workoutSet) => workoutSet.uid != workoutSetToMove.uid).forEach((WorkoutSet e) {
        if (isDescente && e.order > workoutSetToMove.order && e.order <= order) {
          e.order = e.order - 1;
          batch.update(workoutSetService.getSetRef(e), {'order': e.order});
        }
        if (!isDescente && e.order < workoutSetToMove.order && e.order >= order) {
          e.order = e.order + 1;
          batch.update(workoutSetService.getSetRef(e), {'order': e.order});
        }
      });
    }

    // Mise à jour du DTO reçu avec son nouvel ordre d'affichage.
    workoutSetToMove.order = order;
    batch.update(workoutSetService.getSetRef(workoutSetToMove), {'order': workoutSetToMove.order});

    // Trie de la liste locale
    listDtos.sort((WorkoutSet a, WorkoutSet b) => a.order.compareTo(b.order));
    subjectListDtos.sink.add(listDtos);

    // Commit du batch pour envoyer toutes les modifications sur Firestore.
    batch.commit();
  }

  void updateWorkoutSet(WorkoutSet dto) {
    workoutSetService
        .save(dto)
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void setReps(WorkoutSet dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.reps = value;
      updateWorkoutSet(dto);
    });
  }

  void setDist(WorkoutSet dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.distance = value;
      updateWorkoutSet(dto);
    });
  }

  void setWeight(WorkoutSet dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.weight = value;
      updateWorkoutSet(dto);
    });
  }

  void setRestTime(WorkoutSet dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.restTime = value;
      updateWorkoutSet(dto);
    });
  }

  void setTime(WorkoutSet dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.time = value;
      updateWorkoutSet(dto);
    });
  }
}

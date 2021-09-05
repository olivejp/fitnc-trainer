import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.set/workout.dto.widget.dart';
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
/// Panel bas qui présente la liste des
///
class WorkoutSetBottomPanel extends StatelessWidget {
  WorkoutSetBottomPanel({Key? key, required this.workout}) : super(key: key);

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final Workout workout;
  final WorkoutSetBottomPanelController controller = Get.put(WorkoutSetBottomPanelController());

  @override
  Widget build(BuildContext context) {
    controller.init(workout);
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: StreamBuilder<List<WorkoutSetDto>>(
        stream: controller.obsListWorkoutSet,
        builder: (BuildContext context, AsyncSnapshot<List<WorkoutSetDto>> snapshot) {
          if (snapshot.hasData) {
            final List<WorkoutSetDto?> listWorkoutSetDto = snapshot.data!;
            final Widget liste = ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 2),
              itemCount: listWorkoutSetDto.length,
              itemBuilder: (BuildContext context, int index) => _DragTargetDto(dto: listWorkoutSetDto.elementAt(index)!),
            );
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
                Expanded(child: liste),
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

  final WorkoutSetDto dto;
  final WorkoutSetBottomPanelController controller =Get.find();

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
      onAccept: (WorkoutSetDto data) => controller.switchOrder(data, dto.order),
      builder: (BuildContext context, List<WorkoutSetDto?> candidateData, List<dynamic> rejectedData) {
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
class WorkoutSetBottomPanelController extends GetxController {
  final WorkoutSetService workoutSetService = Get.find();
  final int debounceTime = 200;
  final List<WorkoutSetDto> listDtos = <WorkoutSetDto>[];
  final BehaviorSubject<List<WorkoutSetDto>> subjectListDtos = BehaviorSubject<List<WorkoutSetDto>>();

  late Workout? _workout;

  Stream<List<WorkoutSetDto>> get obsListWorkoutSet => subjectListDtos.stream;
  Timer? _debounce;

  void init(Workout workout) {
    listDtos.clear();
    subjectListDtos.sink.add(listDtos);
    _workout = workout;
    getWorkoutSetDto(_workout!).then((List<WorkoutSetDto> remoteList) {
      listDtos.addAll(remoteList);
      subjectListDtos.sink.add(listDtos);
    });
  }

  Future<List<WorkoutSetDto>> getWorkoutSetDto(Workout workout) {
    return workoutSetService
        .getWorkoutSetsReference(workout)
        .orderBy('order')
        .get()
        .then((QuerySnapshot<Object?> querySnapshot) => querySnapshot.docs
            .map((QueryDocumentSnapshot<Object?> docSnapshot) => WorkoutSet.fromJson(docSnapshot.data() as Map<String, dynamic>))
            .map((WorkoutSet workoutSet) => workoutSetService.mapToDto(workoutSet))
            .toList())
        .then((List<Future<WorkoutSetDto>> remoteListFuture) => Future.wait(remoteListFuture));
  }

  int getMaxOrder(List<WorkoutSetDto>? listWorkoutSetDto) {
    int maxOrder = 0;
    if (listWorkoutSetDto != null) {
      for (final WorkoutSetDto dto in listWorkoutSetDto) {
        if (dto.order > maxOrder) {
          maxOrder = dto.order;
        }
      }
    }
    return maxOrder + 1;
  }

  void deleteWorkoutSet(WorkoutSetDto dto) {
    listDtos.remove(dto);
    deleteFromFireStore(dto);
    subjectListDtos.sink.add(listDtos);
  }

  DocumentReference<Object?> getSetRef(WorkoutSetDto dto) {
    return workoutSetService.getWorkoutSetsReference(_workout!).doc(dto.uid);
  }

  void addWorkoutSet(Exercice exerciceDragged) {
    final WorkoutSetDto dto = WorkoutSetDto.empty();
    dto.uid = workoutSetService.getWorkoutSetsReference(_workout!).doc().id;
    dto.uidExercice = exerciceDragged.uid;
    dto.typeExercice = exerciceDragged.typeExercice;
    dto.nameExercice = exerciceDragged.name;
    dto.imageUrlExercice = exerciceDragged.imageUrl;
    dto.order = getMaxOrder(listDtos);
    dto.lines.add(Line());
    listDtos.add(dto);
    subjectListDtos.sink.add(listDtos);

    getSetRef(dto)
        .set(WorkoutSet.fromJson(dto.toJson()).toJson())
        .catchError((_) => showToast("Une erreur est survenue lors de l'enregistrement du set.", duration: const Duration(seconds: 2)));
  }

  void deleteFromFireStore(WorkoutSetDto dto) {
    getSetRef(dto).delete().catchError((Object onError) => showToast('Erreur lors de la suppression du Set.', duration: const Duration(seconds: 2)));
  }

  void switchOrder(WorkoutSetDto dto, int newOrder) {
    int order = newOrder;
    final bool isDescente = dto.order < order;
    if (isDescente) {
      order = order - 1;
    }
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    // Mise à jour des DTO suivants pour les décaler tous.
    if (listDtos.isNotEmpty) {
      listDtos.where((WorkoutSetDto e) => e.uid != dto.uid).forEach((WorkoutSetDto e) {
        if (isDescente && e.order > dto.order && e.order <= order) {
          e.order = e.order - 1;
          batch.update(getSetRef(e), {'order': e.order});
        }
        if (!isDescente && e.order < dto.order && e.order >= order) {
          e.order = e.order + 1;
          batch.update(getSetRef(e), {'order': e.order});
        }
      });
    }

    // Mise à jour du DTO reçu avec son nouvel ordre d'affichage.
    dto.order = order;
    batch.update(getSetRef(dto), {'order': dto.order});

    // Trie de la liste locale
    listDtos.sort((WorkoutSetDto a, WorkoutSetDto b) => a.order.compareTo(b.order));
    subjectListDtos.sink.add(listDtos);

    // Commit du batch pour envoyer toutes les modifications sur Firestore.
    batch.commit();
  }

  void updateFirestoreSet(WorkoutSetDto dto, Map<String, dynamic> values) {
    getSetRef(dto)
        .update(values)
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void updateWorkoutSet(WorkoutSetDto dto) {
    getSetRef(dto)
        .set(dto.toJson())
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void setReps(WorkoutSetDto dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.reps = value;
      updateWorkoutSet(dto);
    });
  }

  void setWeight(WorkoutSetDto dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.weight = value;
      updateWorkoutSet(dto);
    });
  }

  void setRestTime(WorkoutSetDto dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.restTime = value;
      updateWorkoutSet(dto);
    });
  }

  void setTime(WorkoutSetDto dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      line.time = value;
      updateWorkoutSet(dto);
    });
  }
}

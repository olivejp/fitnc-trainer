import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutSetPageBloc {
  WorkoutSetPageBloc._();

  static WorkoutSetPageBloc? _instance;

  static WorkoutSetPageBloc getInstance() {
    _instance ??= WorkoutSetPageBloc._();
    return _instance!;
  }

  Workout? _workout;

  final List<WorkoutSetDto> listDtos = <WorkoutSetDto>[];
  final WorkoutSetService workoutSetService = WorkoutSetService.getInstance();
  final BehaviorSubject<List<WorkoutSetDto>> subjectListDtos = BehaviorSubject<List<WorkoutSetDto>>();

  Stream<List<WorkoutSetDto>> get obsListWorkoutSet => subjectListDtos.stream;

  void init(Workout workout) {
    if (_workout == null || (_workout != null && _workout!.uid != workout.uid)) {
      _workout = workout;
      workoutSetService
          .getWorkoutSetsReference(_workout!)
          .orderBy('order')
          .get()
          .then((QuerySnapshot<Object?> querySnapshot) => querySnapshot.docs
              .map((QueryDocumentSnapshot<Object?> docSnapshot) => WorkoutSet.fromJson(docSnapshot.data() as Map<String, dynamic>))
              .map((WorkoutSet workoutSet) => workoutSetService.mapToDto(workoutSet))
              .toList())
          .then((List<Future<WorkoutSetDto>> remoteListFuture) => Future.wait(remoteListFuture))
          .then((List<WorkoutSetDto> remoteList) {
        listDtos.clear();
        listDtos.addAll(remoteList);
        subjectListDtos.sink.add(listDtos);
      });
    }
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

  DocumentReference getSetRef(WorkoutSetDto dto) {
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
    listDtos.add(dto);
    subjectListDtos.sink.add(listDtos);

    getSetRef(dto)
        .set(WorkoutSet.fromJson(dto.toJson()).toJson())
        .then((_) => showToast('Set ajouté.', duration: const Duration(seconds: 2)))
        .catchError((_) => showToast('Une erreur est survenue lors de l\'enregistrement du set.', duration: const Duration(seconds: 2)));
  }

  void deleteFromFireStore(WorkoutSetDto dto) {
    getSetRef(dto)
        .delete()
        .then((_) => showToast('Set supprimé.', duration: const Duration(seconds: 2)))
        .catchError((Object onError) => showToast('Erreur lors de la suppression du Set.', duration: const Duration(seconds: 2)));
  }

  void switchOrder(WorkoutSetDto dto, int newOrder) {
    final bool isDescente = dto.order < newOrder;

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    if (listDtos.isNotEmpty) {
      listDtos.where((WorkoutSetDto e) => e.uid != dto.uid).forEach((WorkoutSetDto e) {
        if (isDescente && e.order > dto.order && e.order <= newOrder - 1) {
          e.order = e.order - 1;
          batch.update(getSetRef(e), {'order': e.order});
        }
        if (!isDescente && e.order < dto.order && e.order >= newOrder) {
          e.order = e.order + 1;
          batch.update(getSetRef(e), {'order': e.order});
        }
      });

      dto.order = newOrder - 1;
      batch.update(getSetRef(dto), {'order': dto.order});
    }
    listDtos.sort((WorkoutSetDto a, WorkoutSetDto b) => a.order.compareTo(b.order));
    subjectListDtos.sink.add(listDtos);
    batch.commit();
  }

  void updateDto(WorkoutSetDto dto, Map<String, dynamic> values) {
    getSetRef(dto)
        .update(values)
        .then((_) => print('Set mis à jour'))
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void setReps(WorkoutSetDto dto, String value) {
    dto.reps = value;
    updateDto(dto, {'reps': value});
  }

  void setWeight(WorkoutSetDto dto, String value) {
    dto.weight = value;
    updateDto(dto, {'weight': value});
  }

  void setRestTime(WorkoutSetDto dto, String? value) {
    dto.restTime = value;
    updateDto(dto, {'restTime': value});
  }

  void setTime(WorkoutSetDto dto, String? value) {
    dto.time = value;
    updateDto(dto, {'time': value});
  }

  void setSets(WorkoutSetDto dto, String value) {
    dto.sets = value;
    updateDto(dto, {'sets': value});
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutSetLeftPanelBloc {
  WorkoutSetLeftPanelBloc._();

  static WorkoutSetLeftPanelBloc? _instance;

  static WorkoutSetLeftPanelBloc getInstance() {
    _instance ??= WorkoutSetLeftPanelBloc._();
    return _instance!;
  }

  Workout? _workout;

  final List<WorkoutSetDto> listDtos = <WorkoutSetDto>[];
  final WorkoutSetService workoutSetService = WorkoutSetService.getInstance();
  final BehaviorSubject<List<WorkoutSetDto>> subjectListDtos = BehaviorSubject<List<WorkoutSetDto>>();

  Stream<List<WorkoutSetDto>> get obsListWorkoutSet => subjectListDtos.stream;
  Timer? _debounce;

  void init(Workout workout) {
    if (_workout == null || (_workout != null && _workout!.uid != workout.uid)) {
      _workout = workout;
      getWorkoutSetDto().then((List<WorkoutSetDto> remoteList) {
        listDtos.clear();
        listDtos.addAll(remoteList);
        subjectListDtos.sink.add(listDtos);
      });
    }
  }

  Future<List<WorkoutSetDto>> getWorkoutSetDto() {
    return workoutSetService
        .getWorkoutSetsReference(_workout!)
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
        .then((_) => print('Set mis à jour'))
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void updateWorkoutSet(WorkoutSetDto dto) {
    getSetRef(dto)
        .set(dto.toJson())
        .then((_) => showToast('Set mis à jour', duration: Duration(seconds: 2)))
        .catchError((Object onError) => showToast('Erreur lors de la mise à jour du Set.', duration: const Duration(seconds: 2)));
  }

  void setReps(WorkoutSetDto dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      line.reps = value;
      updateWorkoutSet(dto);
    });
  }

  void setWeight(WorkoutSetDto dto, Line line, String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      line.weight = value;
      updateWorkoutSet(dto);
    });
  }

  void setRestTime(WorkoutSetDto dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      line.restTime = value;
      updateWorkoutSet(dto);
    });
  }

  void setTime(WorkoutSetDto dto, Line line, String? value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      line.time = value;
      updateWorkoutSet(dto);
    });
  }
}

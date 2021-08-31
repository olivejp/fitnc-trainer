import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.bottom.panel.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.top.panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../constants/constants.dart';

class WorkoutSetPageVm {
  WorkoutSetPageVm();

  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> streamListExercice = BehaviorSubject<List<Exercice>>();
  final Subject<String?> subjectQuery = BehaviorSubject<String?>.seeded(null);
}

class WorkoutSetPage extends StatefulWidget {
  const WorkoutSetPage({Key? key, required this.workout, this.maxWidthSearchField = 200}) : super(key: key);

  final Workout workout;
  final double maxWidthSearchField;

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  State<WorkoutSetPage> createState() => _WorkoutSetPageState();
}

class _WorkoutSetPageState extends State<WorkoutSetPage> {
  String? _query;
  final TrainersService trainersService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Provider<WorkoutSetPageVm>(
      create: (BuildContext context) => WorkoutSetPageVm(),
      builder: (BuildContext context, Widget? child) {
        final WorkoutSetPageVm vm = Provider.of<WorkoutSetPageVm>(context);

        trainersService.listenToExercice().listen((List<Exercice> event) {
          vm.listCompleteExercice.clear();
          vm.listCompleteExercice.addAll(event);
          vm.streamListExercice.sink.add(vm.listCompleteExercice);
          UtilService.search(_query, vm.listCompleteExercice, vm.streamListExercice);
        });

        vm.subjectQuery.listen((String? value) {
          _query = value;
          UtilService.search(_query, vm.listCompleteExercice, vm.streamListExercice);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Text(
                'Composer',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                      child: WorkoutSetTopPanel(
                        maxWidthSearchField: widget.maxWidthSearchField,
                        alignmentSearchField: MainAxisAlignment.end,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: FitnessNcColors.blue50,
                        child: WorkoutSetBottomPanel(workout: widget.workout),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

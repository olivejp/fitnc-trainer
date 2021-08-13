import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.left.panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutSetPageBloc {
  WorkoutSetPageBloc._();

  factory WorkoutSetPageBloc.instance() {
    _instance ??= WorkoutSetPageBloc._();
    return WorkoutSetPageBloc._instance!;
  }

  static WorkoutSetPageBloc? _instance;

  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> _streamListExercice = BehaviorSubject<List<Exercice>>();
}

class WorkoutSetPage extends StatefulWidget {
  const WorkoutSetPage({Key? key, required this.workout}) : super(key: key);

  final Workout workout;

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  State<WorkoutSetPage> createState() => _WorkoutSetPageState();
}

class _WorkoutSetPageState extends State<WorkoutSetPage> {

  final TrainersService trainersService = TrainersService.instance();
  final WorkoutSetPageBloc bloc = WorkoutSetPageBloc.instance();

  String? _query;

  set query(String? text) {
    _query = text;
    UtilSearch.search(_query, bloc.listCompleteExercice, bloc._streamListExercice);
  }

  String? get query => _query;

  @override
  void initState() {
    super.initState();
    trainersService.listenToExercice()
    .listen((List<Exercice> event) {
      bloc.listCompleteExercice.clear();
      bloc.listCompleteExercice.addAll(event);
      bloc._streamListExercice.sink.add(bloc.listCompleteExercice);
      UtilSearch.search(_query, bloc.listCompleteExercice, bloc._streamListExercice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        WorkoutSetLeftPanel(workout: widget.workout),
        Expanded(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                        flex: 3,
                        child: Text(
                          'Exercices',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        )),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Recherche...',
                        ),
                        onChanged: (String value) => query = value,
                        textAlignVertical: TextAlignVertical.bottom,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Exercice?>>(
                  stream: bloc._streamListExercice,
                  builder: (BuildContext context, AsyncSnapshot<List<Exercice?>> snapshot) {
                    if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                      return const Center(child: Text('Aucun exercice trouvé.'));
                    } else {
                      return WorkoutExerciceGridView(listExercice: snapshot.data!);
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
}

class WorkoutExerciceGridView extends StatelessWidget {
  const WorkoutExerciceGridView({Key? key, required this.listExercice}) : super(key: key);

  final List<Exercice?> listExercice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      int nbColumns = 2;
      if (constraints.maxWidth > 1000) {
        nbColumns = 10;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 7;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 5;
      } else if (constraints.maxWidth > 400) {
        nbColumns = 4;
      }

      return GridView.count(
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listExercice.where((Exercice? exercice) => exercice != null).map((Exercice? exercice) {
          final Widget gridCard = ExerciceCard(
            exercice: exercice!,
          );
          return Draggable<Exercice>(
            feedback: gridCard,
            data: exercice,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {},
              child: gridCard,
            ),
          );
        }).toList(),
      );
    });
  }
}

class ExerciceCard extends StatelessWidget {
  const ExerciceCard({Key? key, required this.exercice}) : super(key: key);

  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    Widget firstChild;
    if (exercice.imageUrl != null) {
      firstChild = Image.network(
        exercice.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return LoadingRotating.square(
            backgroundColor: Theme.of(context).primaryColor,
          );
        },
      );
    } else {
      firstChild = Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      );
    }
    return LimitedBox(
      maxHeight: 100,
      maxWidth: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(flex: 5, child: firstChild),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Center(
                  child: Text(
                    exercice.name!,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

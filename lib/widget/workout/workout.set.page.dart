import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/main.dart';
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

class WorkoutComposePageBloc {
  WorkoutComposePageBloc._();

  factory WorkoutComposePageBloc.instance() {
    _instance ??= WorkoutComposePageBloc._();
    return WorkoutComposePageBloc._instance!;
  }

  static WorkoutComposePageBloc? _instance;

  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> _streamListExercice = BehaviorSubject<List<Exercice>>();
  final Subject<String?> subjectQuery = BehaviorSubject<String?>.seeded(null);
}

class WorkoutComposePage extends StatefulWidget {
  const WorkoutComposePage({Key? key, required this.workout}) : super(key: key);

  final Workout workout;

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  State<WorkoutComposePage> createState() => _WorkoutComposePageState();
}

class _WorkoutComposePageState extends State<WorkoutComposePage> {
  final TrainersService trainersService = TrainersService.instance();
  final WorkoutComposePageBloc bloc = WorkoutComposePageBloc.instance();

  String? _query;

  @override
  void initState() {
    super.initState();
    trainersService.listenToExercice().listen((List<Exercice> event) {
      bloc.listCompleteExercice.clear();
      bloc.listCompleteExercice.addAll(event);
      bloc._streamListExercice.sink.add(bloc.listCompleteExercice);
      UtilService.search(_query, bloc.listCompleteExercice, bloc._streamListExercice);
    });

    bloc.subjectQuery.listen((String? value) {
      _query = value;
      UtilService.search(_query, bloc.listCompleteExercice, bloc._streamListExercice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Composer',
              style: Theme.of(context).textTheme.headline1,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _WorkoutSetTopPanel(bloc: bloc, maxWidthSearchField: 200,alignmentSearchField: MainAxisAlignment.end,),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
        ),
      ),
    );
  }
}

class _WorkoutSetTopPanel extends StatelessWidget {
  const _WorkoutSetTopPanel({
    Key? key,
    required this.bloc, this.alignmentSearchField = MainAxisAlignment.start, this.maxWidthSearchField = 150,
  }) : super(key: key);

  final WorkoutComposePageBloc bloc;
  final MainAxisAlignment alignmentSearchField;
  final double maxWidthSearchField;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: alignmentSearchField,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  constraints: BoxConstraints(maxWidth: maxWidthSearchField, maxHeight: 30),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                  prefixIcon: Icon(Icons.search),
                  hintStyle: TextStyle(fontSize: 14),
                  hintText: 'Recherche...',
                ),
                onChanged: (String value) => bloc.subjectQuery.sink.add(value),
                textAlignVertical: TextAlignVertical.bottom,
              ),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<Exercice?>>(
            stream: bloc._streamListExercice,
            builder: (BuildContext context, AsyncSnapshot<List<Exercice?>> snapshot) {
              if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                return const Center(child: Text('Aucun exercice trouvé.'));
              } else {
                return _WorkoutComposeExerciceGridView(listExercice: snapshot.data!);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _WorkoutComposeExerciceGridView extends StatelessWidget {
  const _WorkoutComposeExerciceGridView({Key? key, required this.listExercice}) : super(key: key);

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

      return Scrollbar(

        isAlwaysShown: true,
        child: GridView.count(
          semanticChildCount: listExercice.length,
          shrinkWrap: true,
          // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisExtent: 150, childAspectRatio: 1 / 4),
          scrollDirection: Axis.horizontal,
          crossAxisCount: 1,
          childAspectRatio: 0.7,

          mainAxisSpacing: 10,
          children: listExercice.where((Exercice? exercice) => exercice != null).map((Exercice? exercice) {
            final Widget gridCard = _WorkoutComposeExerciceCard(
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
        ),
      );
    });
  }
}

class _WorkoutComposeExerciceCard extends StatelessWidget {
  const _WorkoutComposeExerciceCard({Key? key, required this.exercice}) : super(key: key);

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
                    maxLines: 1,
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

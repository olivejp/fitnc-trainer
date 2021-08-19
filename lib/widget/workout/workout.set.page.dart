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
  const WorkoutComposePage({Key? key, required this.workout, this.maxWidthSearchField = 200}) : super(key: key);

  final Workout workout;
  final double maxWidthSearchField;

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
                  child: _WorkoutSetTopPanel(
                    bloc: bloc,
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
  }
}

class _WorkoutSetTopPanel extends StatelessWidget {
  _WorkoutSetTopPanel({
    Key? key,
    required this.bloc,
    this.alignmentSearchField = MainAxisAlignment.start,
    this.maxWidthSearchField = 150,
  }) : super(key: key);

  final WorkoutComposePageBloc bloc;
  final MainAxisAlignment alignmentSearchField;
  final double maxWidthSearchField;
  final TextEditingController _searchTextController = TextEditingController();

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
                controller: _searchTextController,
                decoration: InputDecoration(
                  constraints: BoxConstraints(maxWidth: maxWidthSearchField, maxHeight: 30),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      iconSize: 15,
                      onPressed: () {
                        _searchTextController.clear();
                        bloc.subjectQuery.sink.add(null);
                      },
                      icon: Icon(Icons.clear)),
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
  _WorkoutComposeExerciceGridView({Key? key, required this.listExercice}) : super(key: key);

  final List<Exercice?> listExercice;
  final ScrollController _scrollController = ScrollController();
  final int scrollStep = 200;
  final double radiusButtonStep = 10;

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

      return Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 30,
            right: 30,
            child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: GridView.count(
                controller: _scrollController,
                semanticChildCount: listExercice.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                crossAxisCount: 1,
                childAspectRatio: 0.7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
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
            ),
          ),
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: FitnessNcColors.blue50Alpha060,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(radiusButtonStep), bottomLeft: Radius.circular(radiusButtonStep))),
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 15,
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        double offset = _scrollController.offset;
                        _scrollController.jumpTo(offset - scrollStep);
                      },
                    ),
                  ],
                ),
              )),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: FitnessNcColors.blue50Alpha060,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(radiusButtonStep), bottomRight: Radius.circular(radiusButtonStep))),
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 15,
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        double offset = _scrollController.offset;
                        _scrollController.jumpTo(offset + scrollStep);
                      },
                    ),
                  ],
                ),
              )),
        ],
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

import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.create.page.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  _WorkoutPageState createState() {
    return _WorkoutPageState();
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final List<Workout> listCompleteWorkout = <Workout>[];
  final BehaviorSubject<List<Workout>> _streamListWorkout =
      BehaviorSubject<List<Workout>>();
  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, listCompleteWorkout, _streamListWorkout);
  }

  String? get query => _query;

  @override
  Widget build(BuildContext context) {
    return Provider<WorkoutService>(
        create: (BuildContext context) => WorkoutService(context),
        builder: (_, __) {
          final WorkoutService bloc = Provider.of<WorkoutService>(context);

          bloc.listenAll().listen((List<Workout> event) {
            listCompleteWorkout.clear();
            listCompleteWorkout.addAll(event);
            UtilService.search(_query, listCompleteWorkout, _streamListWorkout);
          });

          return RoutedPage(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () => WorkoutCreatePage.showCreate(context),
                label: Text(
                  'Créer un workout',
                  style: GoogleFonts.roboto(
                      fontSize: 15, color: Color(Colors.white.value)),
                ),
                icon: Icon(
                  Icons.add,
                  color: Color(Colors.white.value),
                  size: 25.0,
                ),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: SelectableText(
                              'Workout',
                              style: Theme.of(context).textTheme.headline1,
                            )),
                        Expanded(
                          child: TextFormField(
                            onChanged: (String text) => query = text,
                            decoration: InputDecoration(
                              constraints: BoxConstraints(maxHeight: 43),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: Theme.of(context).primaryColor)),
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
                    child: StreamBuilder<List<Workout>>(
                      stream: _streamListWorkout,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Workout>> snapshot) {
                        if (!snapshot.hasData ||
                            (snapshot.hasData && snapshot.data!.isEmpty)) {
                          return const Center(
                              child: Text('Aucun workout trouvé.'));
                        } else {
                          final List<Workout> listWorkout = snapshot.data!;
                          return FitnessGridView<Workout>(
                            domains: listWorkout,
                            bloc: bloc,
                            onTap: (Workout domain) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        contentPadding: const EdgeInsets.all(0),
                                        content: SizedBox(
                                            width: 1280,
                                            child: WorkoutUpdatePage(
                                                workout: domain)),
                                      ));
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

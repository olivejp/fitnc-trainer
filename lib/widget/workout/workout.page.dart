import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
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
import 'package:loading_animations/loading_animations.dart';
import 'package:page_transition/page_transition.dart';

class WorkoutPage extends StatefulWidget {
  WorkoutPage({Key? key}) : super(key: key);

  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();

  @override
  _WorkoutPageState createState() {
    return _WorkoutPageState();
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  _WorkoutPageState();

  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => WorkoutCreatePage.showCreate(context),
          label: Text(
            'Créer un workout',
            style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
          ),
          icon: Icon(
            Icons.add,
            color: Color(Colors.white.value),
            size: 25.0,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: SelectableText(
                            'Workouts',
                            style: GoogleFonts.roboto(fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),
                          )),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Recherche...',
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: StreamBuilder<List<Workout?>>(
                    stream: widget.bloc.getStreamWorkout(),
                    builder: (BuildContext context, AsyncSnapshot<List<Workout?>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                          return const Center(child: Text('Aucun workout trouvé.'));
                        } else {
                          final List<Workout?> listWorkout = snapshot.data!;
                          return StreamBuilder<bool>(
                              stream: widget.homePageBloc.currentDisplayObs,
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data != null && snapshot.data == true) {
                                    return getListView(listWorkout, widget.bloc);
                                  } else {
                                    return WorkoutGridView(
                                      listWorkout: listWorkout,
                                      bloc: widget.bloc,
                                    );
                                  }
                                }
                                return Container();
                              });
                        }
                      }
                      return LoadingRotating.square(
                        backgroundColor: Theme.of(context).primaryColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView getListView(List<Workout?> listWorkout, WorkoutUpdateBloc bloc) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(height: 2.0),
        itemCount: listWorkout.length,
        itemBuilder: (BuildContext context, int index) {
          final Workout workout = listWorkout[index] as Workout;
          final Widget leading = (workout.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(workout.imageUrl!)) : const CircleAvatar();
          final Widget subtitle = workout.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((workout.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(workout.name),
            subtitle: subtitle,
            trailing: Wrap(children: [
              WorkoutDeleteButton(
                workout: workout,
                bloc: bloc,
              )
            ]),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      duration: Duration.zero,
                      reverseDuration: Duration.zero,
                      type: PageTransitionType.fade,
                      child: WorkoutUpdatePage(workout: workout)));
            },
          );
        });
  }
}

class WorkoutDeleteButton extends StatelessWidget {
  const WorkoutDeleteButton({Key? key, required this.workout, required this.bloc}) : super(key: key);

  final Workout workout;
  final WorkoutUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Etes vous sûr de vouloir supprimer ce workout?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => bloc.deleteWorkout(workout).then((_) => Navigator.pop(context)),
                  child: const Text('Oui')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
            ],
          ),
        );
      },
      icon: const Icon(Icons.delete, color: Colors.grey, size: 24),
    );
  }
}

class WorkoutGridCard extends StatelessWidget {
  const WorkoutGridCard({Key? key, required this.workout, required this.bloc}) : super(key: key);

  final Workout workout;
  final WorkoutUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    Widget firstChild;
    if (workout.imageUrl?.isNotEmpty == true) {
      firstChild = Ink.image(
        image: NetworkImage(
          workout.imageUrl!,
        ),
        fit: BoxFit.cover,
      );
    } else {
      firstChild = Container(decoration: const BoxDecoration(color: Colors.amber));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        onTap: () => Navigator.push(
            context,
            PageTransition(
              duration: Duration.zero,
              reverseDuration: Duration.zero,
              type: PageTransitionType.fade,
              child: WorkoutUpdatePage(workout: workout),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: 3, child: firstChild),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(workout.name, style: const TextStyle(fontSize: 15)),
                  ),
                  WorkoutDeleteButton(
                    workout: workout,
                    bloc: bloc,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutGridView extends StatelessWidget {
  const WorkoutGridView({Key? key, required this.listWorkout, required this.bloc}) : super(key: key);

  final List<Workout?> listWorkout;
  final WorkoutUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      int nbColumns = 1;
      if (constraints.maxWidth > 1200) {
        nbColumns = 6;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 3;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 2;
      }

      return GridView.count(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        childAspectRatio: 13 / 9,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listWorkout.map((Workout? workout) {
          if (workout != null) {
            return WorkoutGridCard(workout: workout, bloc: bloc);
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }
}

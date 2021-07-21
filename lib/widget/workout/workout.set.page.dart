import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.left.panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class WorkoutSetPage extends StatelessWidget {
  WorkoutSetPage({Key? key, required this.workout}) : super(key: key);

  final TrainersService trainersService = TrainersService.getInstance();
  final Workout workout;

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WorkoutSetLeftPanel(workout: workout),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: [
                    const Expanded(
                        flex: 3,
                        child: Text(
                          'Exercices',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
              Expanded(
                child: StreamBuilder<List<Exercice?>>(
                  stream: trainersService.listenToExercice(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                      return Center(child: Text('Aucun exercice trouvé.'));
                    } else {
                      List<Exercice?> listExercice = snapshot.data!;
                      return getGridView(listExercice);
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

  Widget getGridView(List<Exercice?> listExercice) {
    return LayoutBuilder(builder: (context, constraints) {
      int nbColumns = 2;
      if (constraints.maxWidth > 1200) {
        nbColumns = 10;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 7;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 5;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 4;
      }

      return GridView.count(
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listExercice.where((exercice) => exercice != null).map((exercice) {
          Widget gridCard = getGridCard(context, exercice!);
          return Draggable<Exercice>(
            feedback: gridCard,
            data: exercice,
            child: InkWell(
              splashColor: Colors.amber,
              hoverColor: Colors.amber,
              borderRadius: BorderRadius.circular(5),
              onTap: () => print('Hello'),
              child: gridCard,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget getGridCard(BuildContext context, Exercice exercice) {
    Widget firstChild;
    if (exercice.imageUrl != null) {
      firstChild = Image.network(
        exercice.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return LoadingBouncingGrid.circle();
        },
      );
    } else {
      firstChild = Container(
        decoration: BoxDecoration(color: Color(Colors.amber.value)),
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
          children: [
            Flexible(flex: 5, child: firstChild),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Center(
                  child: Text(
                    exercice.name,
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

import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

/// Panel supérieur proposant une liste d'exercice avec option de recherche.
/// Les cards exerices sont "draggable".
class WorkoutSetTopPanel extends StatelessWidget {
  WorkoutSetTopPanel({
    Key? key,
    this.alignmentSearchField = MainAxisAlignment.start,
    this.maxWidthSearchField = 150,
  }) : super(key: key);

  final WorkoutSetPageController controller = Get.find();
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
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      iconSize: 15,
                      onPressed: () {
                        _searchTextController.clear();
                        controller.subjectQuery.sink.add(null);
                      },
                      icon: const Icon(Icons.clear)),
                  hintStyle: const TextStyle(fontSize: 14),
                  hintText: 'Recherche...',
                ),
                onChanged: (String value) => controller.subjectQuery.sink.add(value),
                textAlignVertical: TextAlignVertical.bottom,
              ),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<Exercice?>>(
            stream: controller.streamListExercice,
            builder: (BuildContext context, AsyncSnapshot<List<Exercice?>> snapshot) {
              if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                return const Center(child: Text('Aucun exercice trouvé.'));
              } else {
                return _WorkoutSetExerciceGridView(listExercice: snapshot.data!);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _WorkoutSetExerciceGridView extends StatelessWidget {
  _WorkoutSetExerciceGridView({Key? key, required this.listExercice}) : super(key: key);

  final List<Exercice?> listExercice;
  final ScrollController _scrollController = ScrollController();
  final int scrollStep = 200;
  final double radiusButtonStep = 10;

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(bottom: 10),
              controller: _scrollController,
              semanticChildCount: listExercice.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              crossAxisCount: 1,
              childAspectRatio: 0.7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: listExercice.where((Exercice? exercice) => exercice != null).map((Exercice? exercice) {
                final Widget gridCard = _WorkoutSetExerciceCard(
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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      final double offset = _scrollController.offset;
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
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      final double offset = _scrollController.offset;
                      _scrollController.jumpTo(offset + scrollStep);
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _WorkoutSetExerciceCard extends StatelessWidget {
  const _WorkoutSetExerciceCard({Key? key, required this.exercice}) : super(key: key);

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
                    exercice.name,
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

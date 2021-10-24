import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/workout/workout.set.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      iconSize: 15,
                      onPressed: () {
                        _searchTextController.clear();
                        controller.subjectQuery.sink.add(null);
                      },
                      icon: const Icon(Icons.clear)),
                  hintStyle: const TextStyle(fontSize: 14),
                  hintText: 'search'.tr,
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
                return Center(child: Text('noExerciseFound'.tr));
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
  final double containerWidth = 30;
  final double arrowIconSize = 18;

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
            thickness: 20,
            child: GridView.count(
              padding: const EdgeInsets.only(bottom: 20),
              controller: _scrollController,
              semanticChildCount: listExercice.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              crossAxisCount: 1,
              childAspectRatio: 0.7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: listExercice.where((Exercice? exercice) => exercice != null).map((Exercice? exercice) {
                final Widget gridCard = FitnessGridCard<Exercice>(
                  domain: exercice!,
                  mouseCursor: SystemMouseCursors.grab,
                );
                return Draggable<Exercice>(
                  feedback: LimitedBox(
                    maxWidth: 200,
                    maxHeight: 100,
                    child: gridCard,
                  ),
                  data: exercice,
                  maxSimultaneousDrags: 1,
                  child: gridCard,
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
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radiusButtonStep), bottomLeft: Radius.circular(radiusButtonStep))),
              width: containerWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    iconSize: arrowIconSize,
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
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(radiusButtonStep), bottomRight: Radius.circular(radiusButtonStep))),
              width: containerWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    iconSize: arrowIconSize,
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

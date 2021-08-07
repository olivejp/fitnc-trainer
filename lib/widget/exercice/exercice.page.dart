import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:page_transition/page_transition.dart';

import 'exercice.create.page.dart';

class ExercicePage extends StatelessWidget {
  ExercicePage({Key? key}) : super(key: key);

  final MyHomePageBloc homePageBloc = MyHomePageBloc.instance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => ExerciceCreatePage.showCreate(context),
          label: Text(
            'Créer un exercice',
            style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20.0,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: SelectableText(
                        'Exercice',
                        style: Theme.of(context).textTheme.headline1,
                      )),
                  Expanded(
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
              child: StreamBuilder<List<Exercice>>(
                stream: bloc.getStreamExercice(),
                builder: (BuildContext context, AsyncSnapshot<List<Exercice>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun exercice trouvé.'));
                  } else {
                    final List<Exercice> listExercice = snapshot.data!;
                    return getGridView(listExercice);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGridView(List<Exercice> listExercice) {
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
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: listExercice.map((Exercice exercice) => ExerciceGridCard(
          exercice: exercice,
          bloc: bloc,
        )).toList(),
      );
    });
  }

  static Future<dynamic> goToUpdatePage(BuildContext context, Exercice exercice) {
    return Navigator.push(
        context,
        PageTransition(
          duration: Duration.zero,
          reverseDuration: Duration.zero,
          type: PageTransitionType.fade,
          child: ExerciceUpdatePage(exercice: exercice),
        ));
  }

  void deleteExercice(Exercice exercice, BuildContext context) {
    bloc.deleteExercice(exercice).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

class ExerciceGridCard extends StatelessWidget {
  const ExerciceGridCard({Key? key, required this.exercice, required this.bloc}) : super(key: key);

  final Exercice exercice;
  final ExerciceUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    return FitnessGridCard<Exercice>(
      domain: exercice,
      onTap: (Exercice domain) {
        Navigator.push(
            context,
            PageTransition(
              duration: Duration.zero,
              reverseDuration: Duration.zero,
              type: PageTransitionType.fade,
              child: ExerciceUpdatePage(exercice: exercice),
            ));
      },
      onDelete: (Exercice domain) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Êtes-vous sûr de vouloir supprimer cet exercice?'),
            actions: <Widget>[
              TextButton(onPressed: () => bloc.deleteExercice(exercice), child: Text('Oui')),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
            ],
          ),
        );
      },
    );
  }
}

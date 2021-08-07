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
                    return FitnessGridView<Exercice>(
                      domains: listExercice,
                      bloc: bloc,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

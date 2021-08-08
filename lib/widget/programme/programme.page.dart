import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/programme/programme.update.page.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'programme.create.page.dart';

class ProgrammePage extends StatelessWidget {
  ProgrammePage({Key? key}) : super(key: key);

  final HomePageBloc homePageBloc = HomePageBloc.instance();
  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => ProgrammeCreatePage.showCreate(context),
          label: Text(
            'Créer un programme',
            style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
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
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 3,
                      child: Text(
                        'Programme',
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
              child: StreamBuilder<List<Programme>>(
                stream: bloc.getStreamProgramme(),
                builder: (BuildContext context, AsyncSnapshot<List<Programme>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun programme trouvé.'));
                  } else {
                    final List<Programme> programmes = snapshot.data!;
                    return ProgrammeGridView(
                      programmes: programmes,
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

class ProgrammeGridView extends StatelessWidget {
  const ProgrammeGridView({Key? key, required this.programmes, required this.bloc}) : super(key: key);

  final List<Programme> programmes;
  final ProgrammeUpdateBloc bloc;

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
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: programmes.map((Programme programme) {
          return ProgrammeGridCard(programme: programme, bloc: bloc);
        }).toList(),
      );
    });
  }
}

class ProgrammeGridCard extends StatelessWidget {
  const ProgrammeGridCard({Key? key, required this.programme, required this.bloc}) : super(key: key);

  final Programme programme;
  final ProgrammeUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    return FitnessGridCard<Programme>(
        domain: programme,
        onTap: (Programme programme) {
          Navigator.push(
              context,
              PageTransition(
                duration: Duration.zero,
                reverseDuration: Duration.zero,
                type: PageTransitionType.fade,
                child: ProgrammeUpdatePage(programme: programme),
              ));
        },
        onDelete: (Programme programme) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Etes vous sûr de vouloir supprimer ce programme ?'),
              actions: <Widget>[
                TextButton(onPressed: () => bloc.deleteProgramme(programme).then((_) => Navigator.pop(context)), child: const Text('Oui')),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
              ],
            ),
          );
        });
  }
}

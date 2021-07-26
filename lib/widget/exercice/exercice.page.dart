import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
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

  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();

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
                stream: bloc.getStreamExercice(),
                builder: (BuildContext context, AsyncSnapshot<List<Exercice?>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun exercice trouvé.'));
                  } else {
                    final List<Exercice?> listExercice = snapshot.data!;
                    return StreamBuilder<bool>(
                        stream: homePageBloc.currentDisplayObs,
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null && snapshot.data == true) {
                              return getListView(listExercice);
                            } else {
                              return getGridView(listExercice);
                            }
                          }
                          return Container();
                        });
                    // return getListView(snapshot.data);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGridView(List<Exercice?> listExercice) {
    return LayoutBuilder(builder: (context, constraints) {
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
        children: listExercice.map((Exercice? exercice) {
          if (exercice != null) {
            return InkWell(
              splashColor: Theme.of(context).primaryColor,
              hoverColor: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5),
              onTap: () => goToUpdatePage(context, exercice),
              child: getGridCard(context, exercice),
            );
          } else {
            return Container();
          }
        }).toList(),
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

  Card getGridCard(BuildContext context, Exercice exercice) {
    Widget firstChild;
    if (exercice.imageUrl != null) {
      firstChild = Image.network(
        exercice.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(child: LoadingRotating.square(backgroundColor: Theme.of(context).primaryColor,));
        },
      );
    } else {
      firstChild = Container(
        decoration: BoxDecoration(color: Color(Colors.amber.value)),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: firstChild),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    exercice.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                getDeleteButton(context, exercice),
              ],
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }

  ListView getListView(List<Exercice?> listExercice) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(height: 2.0),
        itemCount: listExercice.length,
        itemBuilder: (BuildContext context, int index) {
          Exercice exercice = listExercice[index] as Exercice;
          final Widget leading = (exercice.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(exercice.imageUrl!)) : const CircleAvatar();
          final Widget subtitle = exercice.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((exercice.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
              contentPadding: const EdgeInsets.all(20.0),
              leading: leading,
              title: Text(exercice.name),
              subtitle: subtitle,
              trailing: Wrap(children: [getDeleteButton(context, exercice)]),
              onTap: () => goToUpdatePage(context, exercice));
        });
  }

  IconButton getDeleteButton(BuildContext context, Exercice exercice) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Êtes-vous sûr de vouloir supprimer cet exercice?'),
            actions: [
              TextButton(onPressed: () => deleteExercice(exercice, context), child: Text('Oui')),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
            ],
          ),
        );
      },
      icon: const Icon(
        Icons.delete,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  void deleteExercice(Exercice exercice, BuildContext context) {
    bloc.deleteExercice(exercice).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

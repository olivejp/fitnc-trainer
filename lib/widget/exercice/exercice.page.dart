import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ExercicePage extends StatefulWidget {
  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();

  ExercicePage({Key? key}) : super(key: key);

  @override
  _ExercicePageState createState() {
    return new _ExercicePageState();
  }
}

class _ExercicePageState extends State<ExercicePage> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  _ExercicePageState();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Exercice?>>(
      stream: widget.bloc.getStreamExercice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            (snapshot.hasData && snapshot.data!.isEmpty)) {
          return Center(child: Text('Aucun exercice trouvé.'));
        } else {
          List<Exercice?> listExercice = snapshot.data!;
          return StreamBuilder<bool>(
              stream: widget.homePageBloc.currentDisplayObs,
              builder: (context, snapshot) {
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
    );
  }

  Widget getGridView(List<Exercice?> listExercice) {
    return LayoutBuilder(builder: (context, constraints) {
      int nbColumns = 1;
      if (constraints.maxWidth > 1200) {
        nbColumns = 5;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 3;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 2;
      }

      return GridView.count(
        padding: const EdgeInsets.all(20.0),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        crossAxisCount: nbColumns,
        children: listExercice.map((exercice) {
          Widget leading = exercice?.imageUrl != null
              ? CircleAvatar(foregroundImage: NetworkImage(exercice!.imageUrl!))
              : Icon(
                  Icons.sports_volleyball,
                  color: Color(Colors.amber.value),
                );

          Widget description = exercice?.description != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    exercice!.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Container();

          Widget subtitle = exercice?.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                  (exercice!.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          if (exercice != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExerciceUpdatePage(
                            exercice: exercice,
                          ))),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                      leading: leading,
                      title: Text(exercice.name),
                      subtitle: subtitle,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: description,
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        getDeleteButton(context, exercice),
                      ],
                    ),
                  ],
                ),
                elevation: 2,
              ),
            );
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  ListView getListView(List<Exercice?> listExercice) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: listExercice != null ? listExercice.length : 0,
        itemBuilder: (context, index) {
          Exercice exercice = listExercice[index] as Exercice;
          Widget leading = (exercice.imageUrl != null)
              ? CircleAvatar(foregroundImage: NetworkImage(exercice.imageUrl!))
              : CircleAvatar();

          Widget subtitle = exercice.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                  (exercice.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(exercice.name),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, exercice)],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExerciceUpdatePage(
                            exercice: exercice,
                          )));
            },
          );
        });
  }

  IconButton getDeleteButton(BuildContext context, Exercice exercice) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Etes vous sûr de vouloir supprimer ce exercice?'),
            actions: [
              TextButton(
                  onPressed: () => deleteExercice(exercice, context),
                  child: Text('Oui')),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'))
            ],
          ),
        );
      },
      icon: Icon(
        Icons.delete,
        color: Color(Colors.amber.value),
        size: 24,
      ),
    );
  }

  void deleteExercice(Exercice exercice, BuildContext context) {
    widget.bloc
        .deleteExercice(exercice)
        .then((value) => Navigator.pop(context))
        .catchError((error) => print(error.toString()));
  }
}

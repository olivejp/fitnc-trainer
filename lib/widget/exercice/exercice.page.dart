import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    'Exercices',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  )),
              Expanded(
                flex: 1,
                child: TextFormField(
                  decoration: InputDecoration(
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
            stream: widget.bloc.getStreamExercice(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
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
          ),
        ),
      ],
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
        children: listExercice.map((exercice) {
          if (exercice != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => goToUpdatePage(context, exercice),
              child: getGridCard(exercice),
            );
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  Future<dynamic> goToUpdatePage(BuildContext context, Exercice exercice) {
    return Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExerciceUpdatePage(
                          exercice: exercice,
                        )));
  }

  Card getGridCard(Exercice exercice) {
    Widget firstChild;
    if (exercice.imageUrl != null) {
      firstChild = Image.network(
        exercice.imageUrl!,
        fit: BoxFit.cover,
      );
    } else {
      firstChild = Container(
        decoration: BoxDecoration(color: Color(Colors.amber.value)),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                getDeleteButton(context, exercice)
              ],
            ),
            flex: 1,
          ),
        ],
      ),
      elevation: 2,
    );
  }

  ListView getListView(List<Exercice?> listExercice) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: 2.0,
            ),
        itemCount: listExercice.length,
        itemBuilder: (context, index) {
          Exercice exercice = listExercice[index] as Exercice;
          Widget leading = (exercice.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(exercice.imageUrl!)) : CircleAvatar();

          Widget subtitle = exercice.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((exercice.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(exercice.name),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, exercice)],
            ),
            onTap: () => goToUpdatePage(context, exercice),
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
            title: Text('Êtes-vous sûr de vouloir supprimer cet exercice?'),
            actions: [
              TextButton(onPressed: () => deleteExercice(exercice, context), child: Text('Oui')),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'))
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
    widget.bloc.deleteExercice(exercice).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

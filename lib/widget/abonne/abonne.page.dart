import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/abonne/abonne_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'abonne.update.page.dart';

class AbonnePage extends StatefulWidget {
  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final AbonneUpdateBloc bloc = AbonneUpdateBloc.getInstance();

  AbonnePage({Key? key}) : super(key: key);

  @override
  _AbonnePageState createState() {
    return new _AbonnePageState();
  }
}

class _AbonnePageState extends State<AbonnePage> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  _AbonnePageState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: StreamBuilder<List<Abonne?>>(
        stream: widget.bloc.getStreamAbonne(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
            return Center(child: Text('Aucun abonne trouvé.'));
          } else {
            List<Abonne?> listAbonne = snapshot.data!;
            return StreamBuilder<bool>(
                stream: widget.homePageBloc.currentDisplayObs,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null && snapshot.data == true) {
                      return getListView(listAbonne);
                    } else {
                      return getGridView(listAbonne);
                    }
                  }
                  return Container();
                });
            // return getListView(snapshot.data);
          }
        },
      ),
    );
  }

  Widget getGridView(List<Abonne?> listAbonne) {
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
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        crossAxisCount: nbColumns,
        children: listAbonne.map((abonne) {
          Widget leading = abonne?.imageUrl != null
              ? CircleAvatar(foregroundImage: NetworkImage(abonne!.imageUrl!))
              : Icon(
                  Icons.sports_volleyball,
                  color: Colors.amber,
                );

          Widget dateNaissance = abonne?.dateNaissance != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    abonne!.dateNaissance!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Container();

          Widget subtitle = abonne?.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((abonne!.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          if (abonne != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                  context,
                  PageTransition(
                      duration: Duration.zero,
                      reverseDuration: Duration.zero,
                      type: PageTransitionType.fade,
                      child: AbonneUpdatePage(
                        abonne: abonne,
                      ))),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                      leading: leading,
                      title: Text('${abonne.nom!} ${abonne.prenom}'),
                      subtitle: subtitle,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: dateNaissance,
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        getDeleteButton(context, abonne),
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

  ListView getListView(List<Abonne?> listAbonne) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: listAbonne != null ? listAbonne.length : 0,
        itemBuilder: (context, index) {
          Abonne abonne = listAbonne[index] as Abonne;
          Widget leading = (abonne.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(abonne.imageUrl!)) : CircleAvatar();

          Widget subtitle = abonne.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((abonne.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            leading: leading,
            title: Text('${abonne.nom!} ${abonne.prenom!}'),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, abonne)],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      duration: Duration.zero,
                      reverseDuration: Duration.zero,
                      type: PageTransitionType.fade,
                      child: AbonneUpdatePage(
                        abonne: abonne,
                      )));
            },
          );
        });
  }

  IconButton getDeleteButton(BuildContext context, Abonne abonne) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Etes vous sûr de vouloir supprimer ce abonne?'),
            actions: [
              TextButton(onPressed: () => deleteAbonne(abonne, context), child: Text('Oui')),
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

  void deleteAbonne(Abonne abonne, BuildContext context) {
    widget.bloc.deleteAbonne(abonne).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

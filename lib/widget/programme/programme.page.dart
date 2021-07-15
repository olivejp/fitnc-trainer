import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/widget/programme/programme.update.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ProgrammePage extends StatefulWidget {
  final MyHomePageBloc homePageBloc = MyHomePageBloc.getInstance();
  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.getInstance();

  ProgrammePage({Key? key}) : super(key: key);

  @override
  _ProgrammePageState createState() {
    return new _ProgrammePageState();
  }
}

class _ProgrammePageState extends State<ProgrammePage> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  _ProgrammePageState();

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
                    'Programmes',
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
          child: StreamBuilder<List<Programme?>>(
            stream: widget.bloc.getStreamProgramme(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                return Center(child: Text('Aucun programme trouvé.'));
              } else {
                List<Programme?> listProgramme = snapshot.data!;
                return StreamBuilder<bool>(
                    stream: widget.homePageBloc.currentDisplayObs,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null && snapshot.data == true) {
                          return getListView(listProgramme);
                        } else {
                          return getGridView(listProgramme);
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

  Widget getGridView(List<Programme?> listProgramme) {
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
        children: listProgramme.map((programme) {
          if (programme != null) {
            return InkWell(
              splashColor: Color(Colors.amber.value),
              hoverColor: Color(Colors.amber.value),
              borderRadius: BorderRadius.circular(10),
              onTap: () => goToUpdatePage(context, programme),
              child: getGridCard(programme),
            );
          } else {
            return Container();
          }
        }).toList(),
      );
    });
  }

  Future<dynamic> goToUpdatePage(BuildContext context, Programme programme) {
    return Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProgrammeUpdatePage(
                          programme: programme,
                        )));
  }

  Card getGridCard(Programme programme) {
    Widget firstChild;
    if (programme.imageUrl != null) {
      firstChild = Image.network(
        programme.imageUrl!,
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
                    programme.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                getDeleteButton(context, programme)
              ],
            ),
            flex: 1,
          ),
        ],
      ),
      elevation: 2,
    );
  }

  ListView getListView(List<Programme?> listProgramme) {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: 2.0,
            ),
        itemCount: listProgramme.length,
        itemBuilder: (context, index) {
          Programme programme = listProgramme[index] as Programme;
          Widget leading = (programme.imageUrl != null) ? CircleAvatar(foregroundImage: NetworkImage(programme.imageUrl!)) : CircleAvatar();

          Widget subtitle = programme.createDate != null
              ? Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch((programme.createDate as Timestamp).millisecondsSinceEpoch)))
              : Container();

          return ListTile(
            contentPadding: const EdgeInsets.all(20.0),
            leading: leading,
            title: Text(programme.name),
            subtitle: subtitle,
            trailing: Wrap(
              children: [getDeleteButton(context, programme)],
            ),
            onTap: () => goToUpdatePage(context, programme),
          );
        });
  }

  IconButton getDeleteButton(BuildContext context, Programme programme) {
    return IconButton(
      tooltip: 'Supprimer',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Êtes-vous sûr de vouloir supprimer cet programme?'),
            actions: [
              TextButton(onPressed: () => deleteProgramme(programme, context), child: Text('Oui')),
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

  void deleteProgramme(Programme programme, BuildContext context) {
    widget.bloc.deleteProgramme(programme).then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
  }
}

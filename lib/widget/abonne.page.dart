import 'package:fitnc_trainer/bloc/abonne.bloc.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:flutter/material.dart';

class AbonnePage extends StatefulWidget {
  final AbonneBloc bloc = AbonneBloc.getInstance();

  AbonnePage({Key? key}) : super(key: key);

  @override
  _AbonnePageState createState() {
    return new _AbonnePageState();
  }
}

class _AbonnePageState extends State<AbonnePage> {
  _AbonnePageState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: StreamBuilder<List<Abonne?>>(
        stream: widget.bloc.getStreamAbonne(),
        builder: (context, snapshot) {
          bool isEmpty = snapshot.data?.isEmpty == true;
          if (!snapshot.hasData || isEmpty) {
            return Center(child: Text('Aucun abonné trouvé.'));
          } else {
            return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                itemBuilder: (context, index) {
                  Abonne abonne = snapshot.data![index] as Abonne;
                  return ListTile(
                    title: Text(abonne.name),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Supprimer',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    'Etes vous sûr de vouloir supprimer cet abonné?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        widget.bloc
                                            .deleteAbonne(abonne)
                                            .then((value) =>
                                                Navigator.pop(context))
                                            .catchError((error) =>
                                                print(error.toString()));
                                      },
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
                            color: Color(Colors.red.value),
                            size: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Mettre à jour',
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text("Modifier l'abonné"),
                                      content: ListTile(
                                        title: TextFormField(
                                          onChanged: (value) =>
                                              abonne.name = value,
                                          initialValue: abonne.name,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez rentrer un nom pour cet abonné';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              widget.bloc.update(abonne);
                                              Navigator.pop(context);
                                            },
                                            child: Text('Modifier'))
                                      ],
                                    ));
                          },
                          icon: Icon(
                            Icons.file_copy_outlined,
                            color: Color(Colors.blue.value),
                            size: 24,
                          ),
                        )
                      ],
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}

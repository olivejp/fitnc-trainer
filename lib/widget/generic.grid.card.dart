import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

///
/// Classe Widget pour une GridView spécialisée pour un AbstractFitnessDomain.
///
class FitnessGridView<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const FitnessGridView({Key? key, required this.domains, required this.bloc}) : super(key: key);
  final List<T> domains;
  final AbstractFitnessCrudBloc<T> bloc;

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
        children: domains.map((T domain) {
          return FitnessGridCard<T>(
            domain: domain,
            onTap: (T domain) {
              Navigator.push(
                  context,
                  PageTransition<Widget>(
                    duration: Duration.zero,
                    reverseDuration: Duration.zero,
                    type: PageTransitionType.fade,
                    child: bloc.openUpdate(context, domain),
                  ));
            },
            onDelete: (T domain) {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: RichText(
                      text: TextSpan(text: 'Êtes-vous sûr de vouloir supprimer : ', children: <InlineSpan>[
                    TextSpan(text: domain.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' ?'),
                  ])),
                  actions: <Widget>[
                    TextButton(onPressed: () => bloc.delete(domain).then((_) => Navigator.pop(context)), child: const Text('Oui')),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    });
  }
}

///
/// Classe Widget pour une Grid Card.
///
class FitnessGridCard<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const FitnessGridCard({Key? key, required this.domain, required this.onTap, required this.onDelete}) : super(key: key);

  final T domain;
  final void Function(T domain) onTap;
  final void Function(T domain) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        onTap: () => onTap(domain),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: (domain.imageUrl?.isNotEmpty == true)
                  ? Ink.image(
                      image: NetworkImage(
                        domain.imageUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : Container(decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(domain.name!, style: const TextStyle(fontSize: 15)),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () => onDelete(domain),
                    icon: const Icon(Icons.delete, color: Colors.grey, size: 24),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

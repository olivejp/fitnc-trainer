import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Classe Widget pour une GridView spécialisée pour un AbstractFitnessDomain.
///
class FitnessGridView<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const FitnessGridView({Key? key, required this.domains, required this.bloc, this.onTap})
      : super(key: key);
  final List<T> domains;
  final void Function(T domain)? onTap;
  final AbstractFitnessCrudBloc<T> bloc;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int nbColumns = 2;
          if (constraints.maxWidth > 1200) {
            nbColumns = 8;
          } else if (constraints.maxWidth > 1000) {
            nbColumns = 5;
          } else if (constraints.maxWidth > 800) {
            nbColumns = 4;
          } else if (constraints.maxWidth > 600) {
            nbColumns = 3;
          }

          return GridView.count(
            shrinkWrap: true,
            childAspectRatio: 13 / 9,
            padding: const EdgeInsets.all(10.0),
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            crossAxisCount: nbColumns,
            children: domains.map((T domain) {
              return _FitnessGridCard<T>(
                bloc: bloc,
                domain: domain,
                onTap: (T domain) {
                  if (onTap != null) {
                    onTap!(domain);
                  }
                },
                onDelete: (T domain) =>
                    UtilService.showDeleteDialog(context, domain, bloc),
              );
            }).toList(),
          );
        });
  }
}

///
/// Classe Widget pour une Grid Card.
///
class _FitnessGridCard<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const _FitnessGridCard({Key? key,
    required this.domain,
    required this.onTap,
    required this.onDelete,
    required this.bloc})
      : super(key: key);

  final T domain;
  final AbstractFitnessCrudBloc<T> bloc;
  final void Function(T domain) onTap;
  final void Function(T domain) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        splashColor: Theme
            .of(context)
            .colorScheme
            .onSurface
            .withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        onTap: () => onTap(domain),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: (domain.imageUrl?.isNotEmpty == true)
                  ? Ink.image(
                  image: NetworkImage(domain.imageUrl!), fit: BoxFit.cover)
                  : Container(
                  decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        domain.name!,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () => onDelete(domain),
                    icon:
                    const Icon(Icons.delete, color: Colors.grey, size: 24),
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

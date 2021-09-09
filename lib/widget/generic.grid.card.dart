import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/service/display.service.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///
/// Classe Widget pour une GridView spécialisée pour un AbstractFitnessDomain.
/// La function getCard vous permet de dessiner vous même la card que vous voulez.
/// Ce paramètre est optionnel et s'il n'est pas précisé une card par défaut sera dessiner.
///
class FitnessGridView<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  FitnessGridView(
      {Key? key,
      required this.domains,
      required this.bloc,
      this.onTap,
      this.getCard,
      this.childAspectRatio = 13 / 9,
      this.padding = 10,
      this.defaultMobileColumns = 2,
      this.defaultTabletColumns = 4,
      this.defaultDesktopColumns = 8})
      : assert((getCard != null && onTap == null) || (getCard == null && onTap != null),
            "Si vous implémenter la méthode getCard(), vous devriez implémenter la méthode onTap() dans l'implémentation de votre getCard()."),
        super(key: key);

  final List<T> domains;
  final void Function(T domain)? onTap;
  final AbstractFitnessCrudService<T> bloc;
  final double childAspectRatio;
  final double padding;
  final int defaultMobileColumns;
  final int defaultTabletColumns;
  final int defaultDesktopColumns;
  final Widget Function(T domain)? getCard;
  final DisplayTypeService displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int nbColumns = 1;
      switch (displayTypeController.displayType.value) {
        case DisplayType.mobile:
          nbColumns = defaultMobileColumns;
          break;
        case DisplayType.tablet:
          nbColumns = defaultTabletColumns;
          break;
        case DisplayType.desktop:
          nbColumns = defaultDesktopColumns;
          break;
      }

      return GridView.count(
        shrinkWrap: true,
        childAspectRatio: childAspectRatio,
        padding: EdgeInsets.all(padding),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: domains.map((T domain) {
          if (getCard != null) {
            return getCard!(domain);
          } else {
            return _FitnessGridCard<T>(
              bloc: bloc,
              domain: domain,
              onTap: (T domain) {
                if (onTap != null) {
                  onTap!(domain);
                }
              },
              onDelete: (T domain) => UtilService.showDeleteDialog(context, domain, bloc),
            );
          }
        }).toList(),
      );
    });
  }
}

///
/// Classe Widget pour une Grid Card.
///
class _FitnessGridCard<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const _FitnessGridCard({Key? key, required this.domain, required this.onTap, required this.onDelete, required this.bloc}) : super(key: key);

  final T domain;
  final AbstractFitnessCrudService<T> bloc;
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
                  ? Ink.image(image: NetworkImage(domain.imageUrl!), fit: BoxFit.cover)
                  : Container(decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        domain.name,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
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

import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

///
/// Classe Widget pour une GridView spécialisée pour un AbstractFitnessDomain.
/// La function getCard vous permet de dessiner vous même la card que vous voulez.
/// Ce paramètre est optionnel et s'il n'est pas précisé une card par défaut sera dessiner.
///
class FitnessGridView<T extends AbstractStorageDomain> extends StatelessWidget {
  FitnessGridView(
      {Key? key,
      required this.domains,
      required this.service,
      this.onTap,
      this.getCard,
      this.childAspectRatio = 13 / 9,
      this.padding = 10,
      this.defaultMobileColumns = 2,
      this.defaultTabletColumns = 4,
      this.defaultDesktopColumns = 8})
      : assert((getCard != null && onTap == null) || (getCard == null && onTap != null),
            'If you provide getCard(), then you should provide an onTap() method.'),
        super(key: key);

  final List<T> domains;
  final void Function(T domain)? onTap;
  final AbstractFitnessCrudService<T> service;
  final double childAspectRatio;
  final double padding;
  final int defaultMobileColumns;
  final int defaultTabletColumns;
  final int defaultDesktopColumns;
  final Widget Function(T domain)? getCard;
  final DisplayTypeService displayTypeController = Get.find();

  void _showDeleteDialog(
      BuildContext context, AbstractDomain domain, AbstractFitnessCrudService<AbstractDomain> service) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: RichText(
            text: TextSpan(text: 'Êtes-vous sûr de vouloir supprimer : ', children: <InlineSpan>[
          TextSpan(text: domain.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ' ?'),
        ])),
        actions: <Widget>[
          TextButton(
              onPressed: () => service.delete(domain).then((_) => Navigator.pop(context)), child: const Text('Oui')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
        ],
      ),
    );
  }

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
            return FitnessGridCard<T>(
              domain: domain,
              onTap: (T domain) {
                if (onTap != null) {
                  onTap!(domain);
                }
              },
              onDelete: (T domain) => _showDeleteDialog(context, domain, service),
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
class FitnessGridCard<T extends AbstractStorageDomain> extends StatelessWidget {
  const FitnessGridCard({
    Key? key,
    required this.domain,
    this.onTap,
    this.onDelete,
    this.mouseCursor,
    this.borderRadius = 5,
    this.splashColor,
    this.hoverColor,
  }) : super(key: key);

  final T domain;
  final void Function(T domain)? onTap;
  final void Function(T domain)? onDelete;
  final MouseCursor? mouseCursor;
  final double borderRadius;
  final Color? splashColor;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      elevation: 2,
      child: InkWell(
        mouseCursor: mouseCursor,
        splashColor: splashColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap != null ? () => onTap!(domain) : null,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Colors.black, Colors.white.withOpacity(0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            if (domain.imageUrl?.isNotEmpty == true)
              Ink.image(image: NetworkImage(domain.imageUrl!), fit: BoxFit.cover)
            else
              Container(
                decoration: const BoxDecoration(color: Colors.amber),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DomainCardNameRow<T>(domain: domain, onDelete: onDelete),
            ),
          ],
        ),
      ),
    );
  }
}

class DomainCardNameRow<T extends AbstractDomain> extends StatelessWidget {
  const DomainCardNameRow({
    Key? key,
    required this.domain,
    this.onDelete,
  }) : super(key: key);

  final T domain;
  final void Function(T domain)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
            child: Text(
              domain.name,
              style: GoogleFonts.nunito(fontSize: 15, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        if (onDelete != null)
          IconButton(
            tooltip: 'delete'.tr,
            onPressed: () => onDelete!(domain),
            icon: const Icon(Icons.delete, color: Colors.white, size: 24),
          )
      ],
    );
  }
}

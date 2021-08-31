import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';

class FitnessDecorationTextFormField extends StatelessWidget {
  const FitnessDecorationTextFormField({Key? key, this.initialValue, this.labelText, this.onChanged, this.validator, this.autofocus = false, this.hintText}) : super(key: key);

  final bool autofocus;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          constraints: const BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        validator: validator);
  }
}



class HorizontalGridView<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridView(
      {Key? key, required this.listDomains, required this.onChanged})
      : super(key: key);

  final List<T> listDomains;
  final void Function(T domain) onChanged;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 300,
      child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisExtent: 200, childAspectRatio: 1 / 4),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: listDomains
              .map((T e) =>
              HorizontalGridCard<T>(domain: e, onChanged: onChanged))
              .toList()),
    );
  }
}

class HorizontalGridCard<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridCard(
      {Key? key, required this.domain, required this.onChanged})
      : super(key: key);

  final T domain;
  final void Function(T domain) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        onTap: () => onChanged(domain),
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(domain.name!,
                        style: const TextStyle(fontSize: 15)),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () {},
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

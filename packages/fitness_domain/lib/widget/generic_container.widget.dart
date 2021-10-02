import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import '../constants.dart';

class StreamList<T> extends StatelessWidget {
  const StreamList({
    Key? key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.loading,
    this.onError,
    this.physics,
    this.padding,
    this.emptyWidget,
    this.showLoading = true,
    this.separatorBuilder,
    this.shrinkWrap = true,
  }) : super(key: key);
  final Stream<List<T>> stream;
  final List<T>? initialData;
  final Widget? loading;
  final Widget? emptyWidget;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget Function(Object? error)? onError;
  final Widget Function(BuildContext context, T domain) builder;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool showLoading;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      initialData: initialData,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        if (snapshot.hasError) {
          return onError != null ? onError!(snapshot.error) : Text(snapshot.error.toString());
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<T> list = snapshot.data!;
          if (separatorBuilder != null) {
            return ListView.separated(
              shrinkWrap: shrinkWrap,
              padding: padding,
              physics: physics,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                T element = list.elementAt(index);
                return builder(context, element);
              },
              separatorBuilder: separatorBuilder!,
            );
          } else {
            return ListView.builder(
              shrinkWrap: shrinkWrap,
              padding: padding,
              physics: physics,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                T element = list.elementAt(index);
                return builder(context, element);
              },
            );
          }
        }
        if (snapshot.hasData && snapshot.data!.isEmpty) {
          if (emptyWidget != null) {
            return emptyWidget!;
          } else {
            return Container();
          }
        }
        if (showLoading == false) {
          return Container();
        } else {
          return loading ??
              LoadingBouncingGrid.circle(
                backgroundColor: Theme.of(context).primaryColor,
              );
        }
      },
    );
  }
}

class FitnessDecorationTextFormField extends StatelessWidget {
  const FitnessDecorationTextFormField({
    Key? key,
    this.initialValue,
    this.labelText,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.hintText,
    this.controller,
    this.inputBorder,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  final bool autofocus;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final InputBorder? inputBorder;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        autofocus: autofocus,
        textAlign: textAlign,
        decoration: InputDecoration(
          border: inputBorder,
          hintText: hintText,
          labelText: labelText,
          constraints: const BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        validator: validator);
  }
}

class HorizontalGridView<T extends AbstractStorageDomain> extends StatelessWidget {
  const HorizontalGridView({Key? key, required this.listDomains, required this.onChanged}) : super(key: key);

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
          children: listDomains.map((T e) => HorizontalGridCard<T>(domain: e, onChanged: onChanged)).toList()),
    );
  }
}

class HorizontalGridCard<T extends AbstractStorageDomain> extends StatelessWidget {
  const HorizontalGridCard({Key? key, required this.domain, required this.onChanged}) : super(key: key);

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
                  ? Ink.image(image: NetworkImage(domain.imageUrl!), fit: BoxFit.cover)
                  : Container(decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(domain.name, style: const TextStyle(fontSize: 15)),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () {},
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

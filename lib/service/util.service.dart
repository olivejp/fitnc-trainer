import 'dart:developer';

import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UtilService {
  ///
  /// Méthode utilitaire pour rechercher dans une liste les éléments contenant la chaine 'query' et émet la liste résultat
  /// dans un Stream donné en paramètre.
  ///
  ///  String? query : la chaine recherché
  ///  List<T> listCompleteDomain : la liste dans laquelle on va rechercher
  ///  Subject<List<T>> stream : le stream dans lequel on va émettre les résultats.
  ///
  static void search<T extends InterfaceDomainSearchable>(String? query, List<T> listCompleteDomain, Subject<List<T>> stream) {
    final String? text = query?.toUpperCase();
    List<T> listFiltered;
    if (text != null && text.isNotEmpty) {
      listFiltered = listCompleteDomain.where((T element) {
        bool finded = false;
        for (final String searchField in element.searchFields()) {
          final Object? field = element.toJson()[searchField];
          if (field != null && field is String) {
            if (field.toUpperCase().contains(text)) {
              finded = true;
              break;
            }
          }
        }
        return finded;
      }).toList();
    } else {
      listFiltered = listCompleteDomain;
    }
    stream.sink.add(listFiltered);
  }

  static void showDeleteDialog(BuildContext context, AbstractDomain domain, AbstractFitnessCrudBloc<AbstractDomain> bloc) {
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
  }
}

import 'dart:developer';

import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:rxdart/rxdart.dart';

class UtilSearch {
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
          } else {
            log("Le field $searchField} n'est pas un String.");
          }
        }
        return finded;
      }).toList();
    } else {
      listFiltered = listCompleteDomain;
    }
    stream.sink.add(listFiltered);
  }
}

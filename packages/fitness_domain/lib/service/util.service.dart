import 'dart:async';
import 'dart:typed_data';

import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:http/http.dart' as http;
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
  static void search<T extends InterfaceDomainSearchable>(
      String? query, List<T> listCompleteDomain, Subject<List<T>> stream) {
    final String? text = query?.toUpperCase();
    List<T> listFiltered;
    if (text != null && text.isNotEmpty) {
      listFiltered = listCompleteDomain.where((T element) {
        bool found = false;
        for (final String searchField in element.searchFields()) {
          final Object? field = element.toJson()[searchField];
          if (field != null && field is String) {
            if (field.toUpperCase().contains(text)) {
              found = true;
              break;
            }
          }
        }
        return found;
      }).toList();
    } else {
      listFiltered = listCompleteDomain;
    }
    stream.sink.add(listFiltered);
  }

  ///
  /// Renvoie dans une Future les bytes de l'image qui se trouve à l'adresse passée en paramètre.
  ///
  static Future<Uint8List> fetchImageBytes(String imageUrl) {
    return http.readBytes(Uri.parse(imageUrl));
  }
}

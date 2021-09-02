import 'dart:async';
import 'dart:typed_data';

import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
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

  /// Permet de récupérer le StorageFile à partir du Domain.
  static Future<StorageFile?> getFutureStorageFile(AbstractFitnessStorageDomain domain) {
    final Completer<StorageFile?> completer = Completer<StorageFile?>();
    if (domain.imageUrl != null && domain.imageUrl!.isNotEmpty) {
      _getRemoteImageToUint8List(domain.imageUrl!).then((Uint8List bytes) {
        domain.storageFile!.fileName = basename(domain.imageUrl!);
        domain.storageFile!.fileBytes = bytes;
        completer.complete(domain.storageFile);
      });
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  static Future<Uint8List> _getRemoteImageToUint8List(String imageUrl) {
    return http.readBytes(Uri.parse(imageUrl));
  }

  static void showDeleteDialog(BuildContext context, AbstractDomain domain, AbstractFitnessCrudService<AbstractDomain> service) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: RichText(
            text: TextSpan(text: 'Êtes-vous sûr de vouloir supprimer : ', children: <InlineSpan>[
          TextSpan(text: domain.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ' ?'),
        ])),
        actions: <Widget>[
          TextButton(onPressed: () => service.delete(domain).then((_) => Navigator.pop(context)), child: const Text('Oui')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
        ],
      ),
    );
  }
}

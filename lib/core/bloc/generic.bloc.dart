import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

///
/// Interface de haut niveau pour les opérations CRUD
///
abstract class AbstractCrudBloc<T> {
  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

///
/// Classe abstraite dont on doit étendre pour récupérer les méthodes par défaut pour le CRUD Firebase.
///
abstract class AbstractFirebaseCrudBloc<T extends AbstractFirebaseDomain> implements AbstractCrudBloc<T> {
  /// Méthode abstraite qui retournera la collectionReference.
  CollectionReference<Object?> getCollectionReference();

  /// Méthode de sauvegarde l'entité passée.
  @override
  Future<void> save(T domain) {
    if (domain.uid != null && domain.uid?.isNotEmpty == true) {
      return update(domain);
    } else {
      return create(domain);
    }
  }

  @override
  Future<void> create(T domain) async {
    domain.createDate = FieldValue.serverTimestamp();
    domain.uid ??= getCollectionReference().doc().id;
    return sendToFireStore(domain);
  }

  @override
  Future<void> update(T domain) async {
    return sendToFireStore(domain);
  }

  @override
  Future<void> delete(T domain) {
    return getCollectionReference().doc(domain.uid).delete().then((_) {});
  }

  Future<void> sendToFireStore(T domain) {
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference().doc(domain.uid).set(domain.toJson()).then((_) {});
  }
}

///
/// Mixins Bloc pour implémenter les méthodes de base pour le Firebase storage.
///
abstract class AbstractFitnessStorageBloc<T extends AbstractFitnessStorageDomain> {
  final String pathWorkoutMainImage = 'mainImage';

  void setStorageFile(T domain, StorageFile? value) {
    domain.storageFile = value;
  }

  /// Méthode abstraite
  String getUrl(User user, T domain);

  /// Envoi le document dans Firebase Storage.
  Future<void> createStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      domain.imageUrl = await _sendToStorage(domain);
    }
  }

  /// Supprime tous les documents présents dans Firebase Storage à l'adresse du getUrl() puis envoie le nouveau document.
  Future<void> eraseAndReplaceStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      await deleteAllFiles(domain);
      await createStorage(domain);
    }
  }

  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée par le getUrl().
  Future<void> deleteAllFiles(T domain) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return FirebaseStorage.instance.ref(getUrl(user, domain)).listAll().then((ListResult value) {
      final List<Future<void>> listFuture = <Future<void>>[];
      for (final Reference ref in value.items) {
        listFuture.add(ref.delete());
      }
      return listFuture;
    }).then((List<Future<void>> listFuture) => Future.wait(listFuture));
  }

  /// Envoi le StorageFile sur Firebase Storage et renvoie l'URL de l'image à partir du Storage Firebase.
  Future<String> _sendToStorage(T domain) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      final String url = getUrl(user, domain);
      return _sendToStorageAndGetReference(url: '$url/$pathWorkoutMainImage/${domain.storageFile!.fileName}', bytes: domain.storageFile!.fileBytes!);
    }
    throw Exception('Envoi sur le storage échoué.');
  }

  /// Permet de récupérer le StorageFile à partir du Domain.
  Future<StorageFile?> getFutureStorageFile(T domain) {
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

  Future<String> _sendToStorageAndGetReference({required String url, required Uint8List bytes, String? contentType}) async {
    final SettableMetadata metadata = SettableMetadata(cacheControl: 'max-age=36000', contentType: contentType);
    return FirebaseStorage.instance.ref(url).putData(bytes, metadata).then((ref) => ref.ref.getDownloadURL());
  }

  Future<Uint8List> _getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }
}

///
/// Classe Bloc spécifique à l'application Fitness NC pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessCrudBloc<T extends AbstractFirebaseDomain> extends AbstractFirebaseCrudBloc<T> {
  /// Méthode abstraite qui retournera le widget à ouvrir pour une mise à jour.
  Widget openUpdate(BuildContext context, T domain);
}

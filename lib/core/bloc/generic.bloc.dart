import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

///
/// Interface de haut niveau pour les opérations CRUD
///
abstract class AbstractCrudService<T> {
  Stream<List<T>> listenAll();

  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

///
/// Classe abstraite dont on doit étendre pour récupérer les méthodes par défaut pour le CRUD Firebase.
///
abstract class AbstractFirebaseCrudService<T extends AbstractDomain> extends GetxService implements AbstractCrudService<T> {
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
    return _sendToFireStore(domain);
  }

  @override
  Future<void> update(T domain) async {
    return _sendToFireStore(domain);
  }

  @override
  Future<void> delete(T domain) {
    return getCollectionReference().doc(domain.uid).delete().then((_) {});
  }

  Future<void> _sendToFireStore(T domain) {
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference().doc(domain.uid).set(domain.toJson()).then((_) {});
  }
}

///
/// Mixin Service pour implémenter les méthodes de base pour le Firebase storage.
///
abstract class MixinFitnessStorageService<T extends AbstractFitnessStorageDomain> {
  /// Méthode abstraite
  /// Permet de spécifier l'emplacement où sera stocké le fichier dans Firebase Storage.
  /// Cette url sera complétée avec le nom du fichier, ex:
  /// Pour un document nommé : myPicture.jpg
  /// Si getStorageRef renvoie : 'myStorage/123/pictures'  alors le document sera positionné à 'myStorage/123/pictures/myPictre.jpg'
  String getStorageRef(User user, T domain);

  /// Méthode pour envoyer le document dans Firebase Storage.
  Future<void> createStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      domain.imageUrl = await _sendToStorage(domain);
    }
  }

  /// Supprime tous les documents présents dans Firebase Storage à l'adresse du getUrl() puis envoie le nouveau document.
  Future<void> eraseAndReplaceStorage(T domain) async {
    await deleteAllFiles(domain);
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      await createStorage(domain);
    } else {
      domain.imageUrl = null;
    }
  }

  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée par le getUrl().
  Future<void> deleteAllFiles(T domain) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return FirebaseStorage.instance.ref(getStorageRef(user, domain)).listAll().then((ListResult value) {
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
      final String url = getStorageRef(user, domain);
      return _sendToStorageAndGetReference(url: '$url/${domain.storageFile!.fileName}', bytes: domain.storageFile!.fileBytes!);
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

  Future<String> _sendToStorageAndGetReference({required String url, required Uint8List bytes, String? contentType}) {
    final SettableMetadata metadata = SettableMetadata(cacheControl: 'max-age=36000', contentType: contentType);
    return FirebaseStorage.instance.ref(url).putData(bytes, metadata).then((TaskSnapshot ref) => ref.ref.getDownloadURL());
  }

  Future<Uint8List> _getRemoteImageToUint8List(String imageUrl) {
    return http.readBytes(Uri.parse(imageUrl));
  }
}

///
/// Classe Bloc spécifique à l'application Fitness NC pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessCrudService<T extends AbstractDomain> extends AbstractFirebaseCrudService<T> {}

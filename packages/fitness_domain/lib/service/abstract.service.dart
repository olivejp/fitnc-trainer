import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

///
/// Interface de haut niveau pour les opérations CRUD
///
abstract class AbstractCrudService<T> {
  Future<T?> read(String uid);

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

  T fromJson(Map<String, dynamic> map);

  @override
  Future<T?> read(String uid) {
    return getCollectionReference().doc(uid).get().then((DocumentSnapshot<Object?> value) => fromJson(value.data()! as Map<String, dynamic>));
  }

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
  /// Si getStorageRef renvoie : 'myStorage/123/pictures'  alors le document sera positionné à 'myStorage/123/pictures/myPicture.jpg'
  String getStorageRef(User user, T domain);

  ///
  /// Méthode pour envoyer le document dans Firebase Storage.
  ///
  Future<void> createStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      domain.imageUrl = await _sendToStorage(domain);
    } else {
      domain.imageUrl = null;
    }
  }

  ///
  /// Supprime tous les documents présents dans Firebase Storage à l'adresse du getStorageRef() puis envoie le nouveau document.
  ///
  Future<void> eraseAndReplaceStorage(T domain) async {
    await deleteAllFiles(domain);
    return createStorage(domain);
  }

  User checkUserConnected() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    } else {
      return user;
    }
  }

  ///
  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée par le getStorageRef().
  ///
  Future<void> deleteAllFiles(T domain) async {
    final User user = checkUserConnected();
    ListResult value = await FirebaseStorage.instance.ref(getStorageRef(user, domain)).listAll();
    final List<Future<void>> listFuture = value.items.map((Reference ref) => ref.delete()).toList();
    await Future.wait(listFuture);
  }

  ///
  /// Envoi le StorageFile sur Firebase Storage et renvoie l'URL de l'image à partir du Storage Firebase.
  ///
  Future<String?> _sendToStorage(T domain) async {
    final User user = checkUserConnected();
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      final String url = getStorageRef(user, domain);
      return _sendToStorageAndGetReference(url: '$url/${domain.storageFile!.fileName}', bytes: domain.storageFile!.fileBytes!);
    } else {
      return Future<String?>.value(null);
    }
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
    return FirebaseStorage.instance
        .ref(url)
        .putData(bytes, metadata)
        .then((TaskSnapshot ref) => ref.ref.getDownloadURL())
        .catchError((Object? error) => Future<String>.error("Une erreur est survenue lors de l'envoi au Storage. ${error.toString()}"));
  }

  Future<Uint8List> _getRemoteImageToUint8List(String imageUrl) {
    return http.readBytes(Uri.parse(imageUrl));
  }
}

///
/// Classe Service spécifique à l'application Fitness NC pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessCrudService<T extends AbstractDomain> extends AbstractFirebaseCrudService<T> {}

///
/// Classe abstraite de service pour tous les domaines héritant de AbstractFitnessStorageDomain.
/// Ce service surcharge les méthodes de save et delete pour aller sauvegarder le storageFile et mettre à jour l'imageUrl de l'entité.
/// Il supprime également
///
abstract class AbstractFitnessStorageService<T extends AbstractFitnessStorageDomain> extends AbstractFitnessCrudService<T>
    with MixinFitnessStorageService<T> {

  Future<void> callUpdateOrCreate(T domain){
    final bool isUpdate = domain.uid != null;
    return isUpdate ? update(domain) : create(domain);
  }

  @override
  Future<void> save(T domain) {
    final bool shouldSendToStorage = domain.storageFile?.fileBytes != null && domain.storageFile?.fileName != null;
    if (shouldSendToStorage) {
      return eraseAndReplaceStorage(domain).then((_) => callUpdateOrCreate(domain)).catchError((Object? error) {
        print('Erreur ${error?.toString()}');
        return callUpdateOrCreate(domain);
      });
    } else {
      return callUpdateOrCreate(domain);
    }
  }

  @override
  Future<void> delete(T domain) {
    return deleteAllFiles(domain).then((_) => delete(domain));
  }
}

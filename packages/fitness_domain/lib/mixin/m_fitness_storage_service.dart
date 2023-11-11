import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/util.service.dart';
import 'package:path/path.dart';

///
/// Mixin Service pour implémenter les méthodes de base pour le Firebase storage.
/// Tous les services qui doivent gérer des AbstractFitnessStorageDomain DOIVENT implémenter cette mixin.
///
mixin MFitnessStorageService<T extends AbstractStorageDomain> {
  /// Méthode abstraite
  /// Permet de spécifier l'emplacement où sera stocké le fichier dans Firebase Storage.
  /// Cette url sera complétée avec le nom du fichier, ex:
  /// Pour un document nommé : myPicture.jpg
  /// Si getStorageRef renvoie : 'myStorage/123/pictures'  alors le document sera positionné à 'myStorage/123/pictures/myPicture.jpg'
  String getStorageRef(User user, T domain);

  ///
  /// Méthode pour envoyer un document dans Firebase Storage.
  /// Le paramètre domain doit étendre de AbstractStorageDomain.
  ///
  /// La propriété storageFile ne doit pas être null.
  /// La propriété storageFile.fileBytes ne doit pas être null.
  /// La propriété storageFile.fileName ne doit pas être null ou vide.
  ///
  /// Le domain sera mis à jour comme suit :
  /// - La propriété imageName sera renseignée avec le nom du fichier,
  ///      ou null si le fichier ou son nom est vide.
  /// - La propriété imageUrl récupérera un lien URL qui permettra le téléchargement de l'image une fois uploadée,
  ///      ou null si le fichier ou son nom est vide.
  ///
  /// Renvoie une Future<void> qui sera complète quand l'upload de l'image sera terminé,
  /// ou renverra une erreur si l'une des 3 propriétés est vide.
  ///
  Future<void> createStorage(T domain) async {
    domain.imageName = null;
    domain.imageUrl = null;

    if (domain.storageFile == null) {
      return Future<void>.error('domain.storageFile is null');
    }

    if (domain.storageFile!.fileBytes == null || domain.storageFile!.fileBytes!.isEmpty) {
      return Future<void>.error('domain.storageFile.fileBytes is null or empty');
    }

    if (domain.storageFile!.fileName == null || domain.storageFile!.fileName!.trim().isEmpty) {
      return Future<void>.error('domain.storageFile.fileName is null or empty');
    }

    domain.imageName = domain.storageFile!.fileName;
    domain.imageUrl = await _sendToStorage(domain);
  }

  ///
  /// Supprime tous les documents présents dans Firebase Storage à l'adresse du getStorageRef() puis envoie le nouveau document.
  ///
  Future<void> eraseAndReplaceStorage(T domain) async {
    await deleteAllFiles(domain);
    return createStorage(domain);
  }

  ///
  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée par le getStorageRef().
  /// Si aucun utilisateur connecté renverra une exception.
  ///
  Future<void> deleteAllFiles(T domain) async {
    final User user = AuthService.getUserConnectedOrThrow();

    ListResult value = await FirebaseStorage.instance.ref(getStorageRef(user, domain)).listAll();

    final List<Future<void>> listFuture = value.items.map((Reference ref) => ref.delete()).toList();

    await Future.wait(listFuture);
  }

  ///
  /// Permet de récupérer le StorageFile à partir du Domain.
  ///
  Future<StorageFile?> getFutureStorageFile(T domain) {
    final Completer<StorageFile?> completer = Completer<StorageFile?>();
    if (domain.imageUrl != null && domain.imageUrl!.isNotEmpty) {
      UtilService.fetchImageBytes(domain.imageUrl!).then((Uint8List bytes) {
        domain.storageFile!.fileName = basename(domain.imageUrl!);
        domain.storageFile!.fileBytes = bytes;
        completer.complete(domain.storageFile);
      });
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  ///
  /// Envoi le StorageFile sur Firebase Storage et renvoie l'URL de l'image à partir du Storage Firebase.
  ///
  Future<String?> _sendToStorage(T domain) async {
    final User user = AuthService.getUserConnectedOrThrow();
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      final String url = getStorageRef(user, domain);
      return _sendToStorageAndGetReference(
          url: '$url/${domain.storageFile!.fileName}', bytes: domain.storageFile!.fileBytes!);
    } else {
      return Future<String?>.value(null);
    }
  }

  Future<String> _sendToStorageAndGetReference({
    required String url,
    required Uint8List bytes,
    String? contentType,
    String? cacheControl = 'max-age=36000',
  }) {
    final SettableMetadata metadata = SettableMetadata(
      cacheControl: cacheControl,
      contentType: contentType,
    );
    return FirebaseStorage.instance
        .ref(url)
        .putData(bytes, metadata)
        .then((TaskSnapshot ref) => ref.ref.getDownloadURL())
        .catchError((Object? error) => Future<String>.error("Error while uploading. ${error.toString()}"));
  }
}

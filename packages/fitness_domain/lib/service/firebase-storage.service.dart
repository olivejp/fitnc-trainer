import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FirebaseStorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final bool emulate;

  ///
  /// A l'initialisation du service
  /// si le dev mode est activé, on va se brancher sur l'émulator.
  ///
  FirebaseStorageService({this.emulate = false}) {
    if (emulate) {
      developer.log(
        '[WARNING] Application launched with emulate mode : Firebase Storage emulator will be used.',
        level: 100,
      );
      _firebaseStorage.useStorageEmulator('localhost', 9199);
    }
  }

  ///
  /// Supprime tous les documents présents dans Firebase Storage à l'adresse indiquée puis pousse le nouveau StorageFile.
  ///
  Future<String> eraseAndReplaceStorage(String path, StorageFile storageFile) async {
    await deleteAllFiles(path);
    return sendToStorage(path, storageFile);
  }

  ///
  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée
  ///
  Future<void> deleteAllFiles(String path) {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return Future<String>.error('Utilisateur non connecté');
    }
    return _firebaseStorage.ref(path).listAll().then((ListResult value) {
      final List<Future<void>> listFuture = <Future<void>>[];
      for (final Reference ref in value.items) {
        listFuture.add(ref.delete());
      }
      return listFuture;
    }).then((List<Future<void>> listFuture) => Future.wait(listFuture));
  }

  ///
  /// Envoi le StorageFile sur Firebase Storage et renvoie l'URL de l'image à partir du Storage Firebase.
  ///
  Future<String> sendToStorage(String path, StorageFile storageFile) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return Future<String>.error('Aucun utilisateur connecté.');
    }
    if (storageFile.fileBytes != null && storageFile.fileName != null) {
      return _sendToStorageAndGetReference(url: '$path/${storageFile.fileName}', bytes: storageFile.fileBytes!);
    } else {
      return Future<String>.error(
          "Le StorageFile n'est pas complet. L'attribut fileBytes et fileName sont obligatoires.");
    }
  }

  ///
  /// Permet de récupérer le StorageFile à partir d'une adresse url.
  ///
  Future<StorageFile?> getFutureStorageFile(String? imageUrl) {
    final Completer<StorageFile?> completer = Completer<StorageFile?>();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      _getRemoteImageToUint8List(imageUrl).then((Uint8List bytes) {
        final StorageFile storageFile = StorageFile();
        storageFile.fileName = basename(imageUrl);
        storageFile.fileBytes = bytes;
        completer.complete(storageFile);
      });
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  ///
  /// Pousse un fichier binaire à l'adresse url indiquée.
  /// Possibilité de spécifier le type de contenu.
  ///
  Future<String> _sendToStorageAndGetReference({required String url, required Uint8List bytes, String? contentType}) {
    final SettableMetadata metadata = SettableMetadata(cacheControl: 'max-age=36000', contentType: contentType);
    return _firebaseStorage.ref(url).putData(bytes, metadata).then((TaskSnapshot ref) => ref.ref.getDownloadURL());
  }

  ///
  /// Permet de récupérer le binaire d'un fichier à partir de son adresse url.
  ///
  Future<Uint8List> _getRemoteImageToUint8List(String imageUrl) {
    return http.readBytes(Uri.parse(imageUrl));
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class FirestorageService {
  Future<String> sendToStorageAndGetReference(
      String url, Uint8List fileByte) async {
    final SettableMetadata metadata = SettableMetadata(
        cacheControl: 'max-age=36000', contentType: 'image/jpeg');
    return FirebaseStorage.instance
        .ref(url)
        .putData(fileByte, metadata)
        .then((TaskSnapshot ref) => ref.ref.getDownloadURL());
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  // TODO A tester
  Future<void> deleteAll(String url) async {
    final Completer completer = Completer();
    try {
      ListResult listResult = await FirebaseStorage.instance.ref(url).listAll();
      for (var i = 0; i < listResult.items.length; i++) {
        await listResult.items.elementAt(i).delete();
        completer.complete();
      }
    } on Exception catch (e) {
      print(e.toString());
      completer.completeError(e.toString());
    }
    return completer.future;
  }
}

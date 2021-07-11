import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';

class FirestorageService {
  static FirestorageService? _instance;

  FirestorageService._() {
    _instance = this;
  }

  static FirestorageService getInstance() {
    if (_instance == null) {
      _instance = FirestorageService._();
    }
    return _instance!;
  }

  Future<String> sendToStorageAndGetReference(String url, Uint8List fileByte) async {
    return await FirebaseStorage.instance.ref(url).putData(fileByte).then((ref) => ref.ref.getDownloadURL());
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  // TODO A tester
  Future<void> deleteAll(String url) async {
    Completer completer = Completer();
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

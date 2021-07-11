import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:path/path.dart';

class FirestorageService {
  static FirestorageService? _instance;
  static final THUMBS_PATH = 'thumbs';
  static final THUMBS_SUFFIX_NAME = '_200x200';

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
    String ext = extension(url).toUpperCase();
    SettableMetadata? metadata = getMetadata(ext);
    return await FirebaseStorage.instance.ref(url).putData(fileByte, metadata).then((ref) => ref.ref.getDownloadURL());
  }

  UploadTask sendToStorage(String url, Uint8List fileByte) {
    String ext = extension(url).toUpperCase();
    SettableMetadata? metadata = getMetadata(ext);
    return FirebaseStorage.instance.ref(url).putData(fileByte, metadata);
  }

  SettableMetadata? getMetadata(String ext) {
    SettableMetadata? metadata;
    if (ext.contains('JPEG') || ext.contains('JPG')) {
      metadata = SettableMetadata(contentType: 'image/jpeg');
    }
    if (ext.contains('PNG')) {
      metadata = SettableMetadata(contentType: 'image/png');
    }
    if (ext.contains('GIF')) {
      metadata = SettableMetadata(contentType: 'image/gif');
    }
    return metadata;
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  Future<String> getThumbnailImageUrl(String url, String fileName) {
    Completer<String> completer = Completer();
    String thumbnailName = getThumbnailName(fileName);
    FirebaseStorage.instance.ref(url).child(THUMBS_PATH).child(thumbnailName).getDownloadURL().then((value) {
      completer.complete(value);
    }).catchError((error) => print(error.toString()));

    return completer.future;
  }

  String getThumbnailName(String fileName) {
    int indexDot = fileName.lastIndexOf('.');
    String firstPart = fileName.substring(0, indexDot);
    String lastPart = fileName.substring(indexDot, fileName.length);
    final string = '$firstPart$THUMBS_SUFFIX_NAME$lastPart';
    String thumbnailName = string;
    return thumbnailName;
  }

  Future<Uint8List> getThumbnailImageBytes(String url, String fileName) async {
    String downloadUrl = await getThumbnailImageUrl(url, fileName);
    return getRemoteImageToUint8List(downloadUrl);
  }

  Future<Uint8List> getImageBytes(String url, String fileName) async {
    String downloadUrl = await FirebaseStorage.instance.ref(url).child(fileName).getDownloadURL();
    return getRemoteImageToUint8List(downloadUrl);
  }

  Widget getAvatarThumbnail(String url, String? fileName) {
    Widget leading = fileName != null
        ? FutureBuilder<String?>(
            future: getThumbnailImageUrl(url, fileName),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(foregroundImage: NetworkImage(snapshot.data!));
              } else {
                return CircleAvatar();
              }
            })
        : Icon(
            Icons.sports_volleyball,
            color: Color(Colors.amber.value),
          );
    return leading;
  }
}

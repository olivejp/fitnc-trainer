import 'dart:convert';

import 'package:http/http.dart';

import 'firestore.interfaces.dart';
import 'firestore.wrapper.dart';

/// Enumération des différents types gérés par Firestore.
enum FirestoreEnumType { STRING, INTEGER, DATE, BOOLEAN }

/// Classe utilitaire pour convertir les fields issus d'une réponse de Firestore.
class FirestoreFieldConverter {
  static dynamic convert(String fieldName, Map<String, dynamic> json,
      FirestoreEnumType expectedType) {
    dynamic field = json[fieldName];
    if (field == null) {
      return null;
    }

    switch (expectedType) {
      case FirestoreEnumType.STRING:
        return field['stringValue'];
      case FirestoreEnumType.INTEGER:
        return field['integerValue'];
      case FirestoreEnumType.DATE:
        return field['dateValue'];
      case FirestoreEnumType.BOOLEAN:
        return field['booleanValue'];
      default:
        throw UnsupportedError('Le type Firestore n' 'a pas pu être déduit');
    }
  }
}

class FirestoreConverterTools<T extends FirestoreSerializable> {
  final T expectedClass;

  FirestoreConverterTools(this.expectedClass);

  void Function(String token) passToken;

  /// Conversion d'une réponse Http en une liste d'objet de type T.
  List<T> convertHttpResponseToList(Response response) {
    List<FirestoreDocumentWrapper> listDocumentWrapper = [];
    List<T> listResult = [];

    /// On décode la réponse Json en objet Map.
    dynamic mapBody = jsonDecode(response.body);

    /// On dépile le premier wrapper au dessus de la réponse.
    FirestoreWrapper firestoreWrapper = FirestoreWrapper.fromJson(mapBody);

    /// Pour chaque document présent dans le premier Wrapper, je vais appeler un second Unwrapper.
    firestoreWrapper.documents.forEach((documentWrapped) {
      listDocumentWrapper
          .add(FirestoreDocumentWrapper.fromJson(documentWrapped));
    });

    /// Pour chaque Wrapper de second niveau, je vais appeler la méthode qui permet de transformer un objet Json en objet T.
    listDocumentWrapper.forEach((documentWrapper) {
      listResult
          .add(this.expectedClass.fromFirestoreJson(documentWrapper.fields));
    });

    /// Si un nextPageToken est présent et qu'il y a une fonction pour le récupérer, on appelle la fonction.
    if (this.passToken != null) {
      if (firestoreWrapper.nextPageToken != null) {
        this.passToken(firestoreWrapper.nextPageToken);
      } else {
        this.passToken(null);
      }
    }

    return listResult;
  }

  /// Conversion d'une réponse Http en un objet de type T.
  T convertHttpResponse(Response response) {
    FirestoreDocumentWrapper documentWrapper =
    FirestoreDocumentWrapper.fromJson(jsonDecode(response.body));
    return this.expectedClass.fromFirestoreJson(documentWrapper.fields);
  }

  FirestoreConverterTools<T> getToken(
      void Function(String token) passTokenFunction) {
    this.passToken = passTokenFunction;
    return this;
  }
}

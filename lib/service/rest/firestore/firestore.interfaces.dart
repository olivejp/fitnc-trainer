import 'dart:collection';

import 'package:http/http.dart';

import '../abstract-rest-domain.service.dart';
import 'firestore.utils.dart';

class FirestorePagination {
  int _pageNumber = 0;
  int pageSize;
  List<String> pageTokens;

  FirestorePagination({this.pageSize});

  void incrementPageNumber() {
    this._pageNumber++;
  }

  void decrementPageNumber() {
    this._pageNumber--;
  }

  String addPageToken(String pageToken) {
    this.pageTokens.add(pageToken);
    return pageToken;
  }

  void refresh() {
    this._pageNumber = 0;
    this.pageTokens.clear();
  }
}

/// Interface à appliquer sur les domaines nécessitant une conversion depuis les API REST Firestore.
abstract class FirestoreSerializable<T> {
  T fromFirestoreJson(Map<String, dynamic> map);
}

abstract class FirestoreDomainService<T extends FirestoreSerializable>
    extends RestDomainService<T> {
  /// Pas très sexy, mais pour avoir un lien vers la méthode 'fromFirestoreJson'
  /// de la classe T qui étend FirestoreSerializable,
  ///
  /// Il nous faut une instance de la classe.
  /// Vous devez privilégier une instance final qui sera au niveau du service
  /// qui étendra FirestoreDomainService.
  T getModelInstance();

  String Function(String) passToken;

  FirestoreDomainService(String path, {bool isHttps, String authority})
      : super(path, isHttps: isHttps, authority: authority);

  /// Méthode pour aller à une nouvelle page.
  Future<List<T>> nextPage(FirestorePagination firestorePagination) {
    Map<String, dynamic> queryParameters =
    HashMap.from({"pageSize": firestorePagination.pageSize});

    /// Si la liste des pageToken n'est pas vide, je passe le dernier en queryParameter.
    if (firestorePagination.pageTokens != null &&
        firestorePagination.pageTokens.isNotEmpty) {
      queryParameters.putIfAbsent(
          "pageToken", () => firestorePagination.pageTokens.last);
    }

    /// Appel du RestService avec les queryParameters.
    return this
        .restHttpService
        .findAll(queryParameters: queryParameters)
        .then((response) {
      return FirestoreConverterTools<T>(getModelInstance())
          .getToken((String token) {
        firestorePagination.incrementPageNumber();
        firestorePagination.addPageToken(token);
      }).convertHttpResponseToList(response);
    }).catchError((onError) => print(onError.toString()));
  }

  //
  // Future<List<T>> previousPage(FirestorePagination firestorePagination) {
  //   Map<String, dynamic> queryParameters =
  //       HashMap.from({"pageSize": firestorePagination.pageSize});
  //   if (firestorePagination.pageTokens != null &&
  //       firestorePagination.pageTokens.isNotEmpty) {
  //     queryParameters.putIfAbsent(
  //         "pageToken", () => firestorePagination.pageTokens.last);
  //   }
  //   return this
  //       .restHttpService
  //       .findAll(queryParameters: queryParameters)
  //       .then((response) {
  //     return FirestoreConverterTools<T>(getModelInstance())
  //         .getToken((String token) => firestorePagination.pageTokens.add(token))
  //         .convertHttpResponseToList(response);
  //   });
  // }

  @override
  T mapResponseToDomain(Response httpResponse) {
    return FirestoreConverterTools<T>(getModelInstance())
        .convertHttpResponse(httpResponse);
  }

  @override
  List<T> mapResponseToListDomain(Response httpResponse) {
    return FirestoreConverterTools<T>(getModelInstance())
        .convertHttpResponseToList(httpResponse);
  }
}

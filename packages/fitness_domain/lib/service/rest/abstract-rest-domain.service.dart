import 'package:fitness_domain/service/rest/rest-http.service.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

/// Classe abstraite permettant de gérer un domain au travers d'un RestHttpService.
abstract class RestDomainService<T> {
  RestDomainService(String path, {String authority = '', bool isHttps = false}) {
    this.restHttpService = RestHttpService(path, authority: authority, isHttps: isHttps);
  }
  T mapResponseToDomain(http.Response response);

  List<T> mapResponseToListDomain(http.Response response);

  late RestHttpService restHttpService;

  Future<Tuple2<T, http.Response>> find(String id,
      {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return this
        .restHttpService
        .find(id, headers: headers, queryParameters: queryParameters)
        .then((http.Response response) => Tuple2<T, http.Response>(mapResponseToDomain(response), response));
  }

  Future<Tuple2<List<T>, http.Response>> findAll(
      {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return this
        .restHttpService
        .findAll(headers: headers, queryParameters: queryParameters)
        .then((http.Response response) => Tuple2<List<T>, http.Response>(mapResponseToListDomain(response), response));
  }

  Future<bool> delete(String id, {Object? body, Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return this
        .restHttpService
        .delete(id, headers: headers, queryParameters: queryParameters)
        .then((http.Response response) => true)
        .catchError((error) => false);
  }

  Future<Tuple2<T, http.Response>> save(String id, Object body,
      {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return this
        .restHttpService
        .save(id, body, headers: headers, queryParameters: queryParameters)
        .then((http.Response response) => Tuple2<T, http.Response>(mapResponseToDomain(response), response));
  }

  Future<Tuple2<T, http.Response>> update(String id, Object body, String path,
      {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return this
        .restHttpService
        .update(id, body, headers: headers, queryParameters: queryParameters)
        .then((http.Response response) => Tuple2<T, http.Response>(mapResponseToDomain(response), response));
  }
}


import 'package:http/http.dart' as http;

import 'http.service.dart';

class RestHttpService extends HttpService {
  final String path;

  RestHttpService(this.path, {String authority, bool isHttps})
      : super(authority, isHttps: isHttps);

  Future<http.Response> find(String id,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    String urlWithId = (id != null) ? this.path + '/$id' : this.path;
    return get(urlWithId, headers: headers, queryParameters: queryParameters);
  }

  Future<http.Response> findAll(
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    return getAll(this.path,
        headers: headers, queryParameters: queryParameters);
  }

  Future<http.Response> delete(String id,
      {Object body,
        Map<String, String> headers,
        Map<String, dynamic> queryParameters}) {
    String urlWithId = (id != null) ? this.path + '/$id' : this.path;
    return suppress(urlWithId,
        body: body, headers: headers, queryParameters: queryParameters);
  }

  Future<http.Response> save(String id, Object body,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    String urlWithId = (id != null) ? this.path + '/$id' : this.path;
    return post(body, urlWithId,
        headers: headers, queryParameters: queryParameters);
  }

  Future<http.Response> update(String id, Object body,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    String urlWithId = (id != null) ? this.path + '/$id' : this.path;
    return put(body, urlWithId,
        headers: headers, queryParameters: queryParameters);
  }
}

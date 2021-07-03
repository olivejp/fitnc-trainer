import 'package:http/http.dart' as http;

class HttpService {
  final String authority;
  final bool isHttps;

  HttpService(this.authority, {this.isHttps});

  Uri getUri(String path, Map<String, dynamic> queryParameters) {
    if (this.isHttps) {
      return Uri.https(this.authority, path, queryParameters);
    } else {
      return Uri.http(this.authority, path, queryParameters);
    }
  }

  Future<http.Response> get(String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.get(uri, headers: headers);
  }

  Future<http.Response> getAll(String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.get(uri, headers: headers);
  }

  Future<http.Response> suppress(String path,
      {Object body,
      Map<String, String> headers,
      Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.delete(uri, headers: headers);
  }

  Future<http.Response> post(Object body, String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.post(uri, body: body, headers: headers);
  }

  Future<http.Response> put(Object body, String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.put(uri, body: body, headers: headers);
  }

  Future<http.Response> head(String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.head(uri, headers: headers);
  }

  Future<http.Response> patch(Object body, String path,
      {Map<String, String> headers, Map<String, dynamic> queryParameters}) {
    Uri uri = getUri(path, queryParameters);
    return http.patch(uri, body: body, headers: headers);
  }
}

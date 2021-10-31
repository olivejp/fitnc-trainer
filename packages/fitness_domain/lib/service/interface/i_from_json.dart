
///
/// Interface to deserialize data from a json.
///
abstract class IFromJson<T> {
  T fromJson(Map<String, dynamic> map);
}
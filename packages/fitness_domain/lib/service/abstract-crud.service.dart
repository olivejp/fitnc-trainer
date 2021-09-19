import 'dart:async';

///
/// Interface de haut niveau pour les opérations CRUD
///
abstract class AbstractCrudService<T> {
  Future<T?> read(String uid);

  Stream<List<T>> listenAll();

  Future<List<T>> getAll();

  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';

///
/// Interface pour lecture d'une ou plusieurs entité indépendante <T>
///
abstract class IReaderService<T> {
  Future<T?> read(String uid);

  Future<List<T>> getAll();
}

///
/// Interface pour lecture d'une ou plusieurs entité <T> dépendante d'une entité parente
///
abstract class ISubReaderService<T> {
  Future<T?> read(String rootDomainUid, String uidDomain);

  Future<List<T>> getAll(String rootDomainUid);
}

///
/// Interface d'écriture et de suppression des entités <T>
///
abstract class IWriteService<T> {
  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

///
/// Interface d'écoute d'une ou plusieurs entité indépendante <T>
///
abstract class IListenService<T> {
  Stream<List<T>> listenAll();

  Stream<T> listen(String uid);
}

///
/// Interface d'écoute d'une ou plusieurs entité  <T> dépendante d'une entité parente.
///
abstract class ISubListenService<T> implements ISubReaderService<T> {
  CollectionReference<Object?> getCollectionReference(String rootDomainUid);

  Stream<List<T>> listenAll(String rootDomainUid);

  Stream<T> listen(String rootDomainUid, String uid);
}

///
/// Interface de haut niveau pour les opérations CRUD
/// Sur des entités placées à la racine de la DB Firebase.
///
abstract class ICrudService<T>
    implements IWriteService<T>, IListenService<T>, IReaderService<T> {}

///
/// Interface de haut niveau pour les opérations CRUD
/// Sur des entités placées à la racine de la DB Firebase.
///
abstract class ISubCrudService<T>
    implements IWriteService<T>, ISubListenService<T>, ISubReaderService<T> {}

///
/// Interface de haut niveau pour les opérations CRUD
/// Sur des entités placées en SOUS COLLECTION de la DB.
/// CAD qui sont placés sous une autre entité dont on a besoin pour les localiser.
///
abstract class IFirebaseSubCrudService<T extends AbstractDomain,
    U extends AbstractDomain> implements ISubCrudService<T> {
  String getCollectionName();
}

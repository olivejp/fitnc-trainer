import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';

abstract class InterfaceCrudService<T> {
  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

abstract class InterfaceObserverService<T> {
  Future<T?> read(String uid);

  Stream<List<T>> listenAll();

  Future<List<T>> getAll();

  Stream<T> listen(String uid);
}


///
/// Interface de haut niveau pour les opérations CRUD
/// Sur des entités placées à la racine de la DB Firebase.
///
abstract class InterfaceCrudObserverService<T> implements InterfaceCrudService<T>, InterfaceObserverService<T> {}




abstract class InterfaceSubcollectionObserverService<T> {
  CollectionReference<Object?> getCollectionReference(String rootDomainUid);

  Future<List<T>> getAll(String rootDomainUid);

  Stream<List<T>> listenAll(String rootDomainUid);
}


///
/// Interface de haut niveau pour les opérations CRUD
/// Sur des entités placées en SOUS COLLECTION de la DB.
/// CAD qui sont placés sous une autre entité dont on a besoin pour les localiser.
///
abstract class InterfaceFirebaseSubcollectionCrudService<T extends AbstractDomain, U extends AbstractDomain>
    implements InterfaceCrudService<T>, InterfaceSubcollectionObserverService<T> {

  String getCollectionName();

  Future<T?> read(String rootDomainUid, String uidDomain);
}

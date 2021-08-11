import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe abstract qui permet d'utiliser les opérations CRUD sur une collection Firestore.
/// Toutes les opérations nécessitent qu'on leur donne la collection référence.
abstract class AbstractFirestoreService<T> {
  AbstractFirestoreService();

  T mapSnapshotToModel(DocumentSnapshot<Map<String, dynamic>> snapshot);

  Future<T> getSpecific(CollectionReference<Map<String, dynamic>> collectionReference, String uid) {
    final Completer<T> completer = Completer<T>();
    collectionReference
        .doc(uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) => completer.complete(mapSnapshotToModel(snapshot)))
        .catchError((Object error) => completer.completeError(error));
    return completer.future;
  }

  Future<DocumentReference<Map<String, dynamic>>> addSpecific(
      CollectionReference<Map<String, dynamic>> collectionReference, Map<String, dynamic> item) {
    return collectionReference.add(item);
  }

  Future<void> deleteSpecific(CollectionReference<Map<String, dynamic>> collectionReference, String uid) {
    return collectionReference.doc(uid).delete();
  }

  Stream<List<T>> listenSpecific(CollectionReference<Map<String, dynamic>> collectionReference) {
    return collectionReference.snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenPagination(CollectionReference<Map<String, dynamic>> collectionReference, String orderByField, int pageSize) {
    return collectionReference.orderBy(orderByField).limit(pageSize).snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenNextPagination(
      CollectionReference<Map<String, dynamic>> collectionReference, dynamic lastFieldOrderedBy, String orderByField, int pageSize) {
    return collectionReference.orderBy(orderByField).startAfter(<dynamic>[lastFieldOrderedBy]).limit(pageSize).snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> event) =>
            event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenPreviousPagination(
      CollectionReference<Map<String, dynamic>> collectionReference, dynamic firstFieldOrderedBy, String orderByField, int pageSize) {
    return collectionReference.orderBy(orderByField).endBefore(<dynamic>[firstFieldOrderedBy]).limitToLast(pageSize).snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> event) =>
            event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => mapSnapshotToModel(doc)).toList());
  }

  Future<List<T>> findAllSpecific(CollectionReference<Map<String, dynamic>> collectionReference) {
    final Completer<List<T>> completer = Completer<List<T>>();
    collectionReference.get().then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<T> listMapped = querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
        return mapSnapshotToModel(snapshot);
      }).toList();

      completer.complete(listMapped);
    });
    return completer.future;
  }
}

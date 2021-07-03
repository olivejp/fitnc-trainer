import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe abstract qui permet d'utiliser les opérations CRUD sur une collection Firestore.
/// Toutes les opérations nécessitent qu'on leur donne la collection référence.
abstract class AbstractFirestoreService<T> {
  AbstractFirestoreService();

  T mapSnapshotToModel(DocumentSnapshot snapshot);

  Future<T> getSpecific(CollectionReference collectionReference, String uid) {
    Completer completer = Completer();
    collectionReference
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) =>
            completer.complete(mapSnapshotToModel(snapshot)))
        .catchError((error) => completer.completeError(error));
    return completer.future;
  }

  Future<DocumentReference> addSpecific(
      CollectionReference collectionReference, Map<String, dynamic> item) {
    return collectionReference.add(item);
  }

  Future<void> deleteSpecific(
      CollectionReference collectionReference, String uid) {
    return collectionReference.doc(uid).delete();
  }

  Stream<List<T>> listenSpecific(CollectionReference collectionReference) {
    return collectionReference.snapshots().map((QuerySnapshot event) =>
        event.docs.map((doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenPagination(CollectionReference collectionReference,
      String orderByField, int pageSize) {
    return collectionReference
        .orderBy(orderByField)
        .limit(pageSize)
        .snapshots()
        .map((QuerySnapshot event) =>
            event.docs.map((doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenNextPagination(CollectionReference collectionReference,
      dynamic lastFieldOrderedBy, String orderByField, int pageSize) {
    return collectionReference
        .orderBy(orderByField)
        .startAfter([lastFieldOrderedBy])
        .limit(pageSize)
        .snapshots()
        .map((QuerySnapshot event) =>
            event.docs.map((doc) => mapSnapshotToModel(doc)).toList());
  }

  Stream<List<T>> listenPreviousPagination(
      CollectionReference collectionReference,
      dynamic firstFieldOrderedBy,
      String orderByField,
      int pageSize) {
    return collectionReference
        .orderBy(orderByField)
        .endBefore([firstFieldOrderedBy])
        .limitToLast(pageSize)
        .snapshots()
        .map((QuerySnapshot event) =>
            event.docs.map((doc) => mapSnapshotToModel(doc)).toList());
  }

  Future<List<T>> findAllSpecific(CollectionReference collectionReference) {
    var completer = Completer<List<T>>();
    collectionReference.get().then((querySnapshot) {
      List<T> listMapped =
          querySnapshot.docs.map((QueryDocumentSnapshot snapshot) {
        return mapSnapshotToModel(snapshot);
      }).toList();

      completer.complete(listMapped);
    });
    return completer.future;
  }
}

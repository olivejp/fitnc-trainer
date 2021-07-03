import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract.firestore.service.dart';

/// Classe abstract qui permet de se brancher sur une collection Firestore au niveau 0.
abstract class AbstractAbsoluteFirestoreService<T>
    extends AbstractFirestoreService<T> {
  CollectionReference collectionReference;

  AbstractAbsoluteFirestoreService({this.collectionReference});

  CollectionReference getCollectionReferenceItemsSubcollection(
      String uid, String subcollectionName) {
    return collectionReference.doc(uid).collection(subcollectionName);
  }

  Future<T> get(String uid) {
    return getSpecific(collectionReference, uid);
  }

  Future<DocumentReference> add(Map<String, dynamic> item) {
    return addSpecific(collectionReference, item);
  }

  Future<void> delete(String uid) {
    return deleteSpecific(collectionReference, uid);
  }

  Stream<List<T>> listen() {
    return listenSpecific(collectionReference);
  }

  Stream<List<T>> beginPagination(String orderByField, int pageSize) {
    return listenPagination(collectionReference, orderByField, pageSize);
  }

  Stream<List<T>> nextPage(
      dynamic lastFieldOrderedBy, String orderByField, int pageSize) {
    return listenNextPagination(
        collectionReference, lastFieldOrderedBy, orderByField, pageSize);
  }

  Stream<List<T>> previousPage(
      dynamic firstFieldOrderedBy, String orderByField, int pageSize) {
    return listenPreviousPagination(
        collectionReference, firstFieldOrderedBy, orderByField, pageSize);
  }

  Future<List<T>> findAll() {
    return findAllSpecific(collectionReference);
  }
}

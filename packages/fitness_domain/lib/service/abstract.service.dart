import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:get/get.dart';

import 'abstract-crud.service.dart';
import 'mixin/m_fitness_storage_service.dart';
import 'firebase_query_condition.dart';
import 'interface/i_from_json.dart';


///
/// T represents the main model
/// U represents the root model
/// X is the service for the root model
///
abstract class AbstractFirebaseSubcollectionCrudService<T extends AbstractSubDomain, U extends AbstractDomain,
        X extends AbstractFirebaseCrudService<U>> extends GetxService
    implements IFirebaseSubCrudService<T, U>, IFromJson<T> {
  final X rootService = Get.find();

  CollectionReference<Map<String, dynamic>> getCollectionReference(String rootDomainUid) {
    return rootService.getCollectionReference().doc(rootDomainUid).collection(getCollectionName());
  }

  Stream<T> listen(String rootDomainUid, String uid) {
    return getCollectionReference(rootDomainUid)
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> event) => fromJson(event.data() as Map<String, dynamic>));
  }

  Stream<List<T>> orderByListen(String rootDomainUid, String orderBy, bool descending) {
    return listenFromQuery(getCollectionReference(rootDomainUid).orderBy(orderBy, descending: descending));
  }

  Future<List<T>> orderByGet(String rootDomainUid, String orderBy, bool descending) {
    return getFromQuery(getCollectionReference(rootDomainUid).orderBy(orderBy, descending: descending));
  }

  Stream<List<T>> whereListen(Object field, String rootDomainUid,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull,
      String? orderBy,
      bool orderByDescending = false}) {
    Query query = getCollectionReference(rootDomainUid).where(field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: orderByDescending);
    }

    return listenFromQuery(query);
  }

  // Retourne une Stream de liste de domain sur lesquels on applique une Query.
  Stream<List<T>> listenFromQuery(Query query) {
    return query
        .withConverter<T>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (T domain, _) => domain.toJson(),
        )
        .snapshots()
        .map((QuerySnapshot<T> snapshot) => snapshot.docs.map((QueryDocumentSnapshot<T> e) => e.data()).toList());
  }

  Query compoundQueries(String rootDomainUid, List<FirebaseQueryCondition> listConditions,
      {String? orderBy, bool orderByDescending = false}) {
    Query? queryFinal;
    for (FirebaseQueryCondition condition in listConditions) {
      if (queryFinal == null) {
        queryFinal = getCollectionReference(rootDomainUid).where(
          condition.field,
          isEqualTo: condition.isEqualTo,
          isNull: condition.isNull,
          isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
          isGreaterThan: condition.isGreaterThan,
          isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
          isLessThan: condition.isLessThan,
          isNotEqualTo: condition.isNotEqualTo,
          whereNotIn: condition.whereNotIn,
          whereIn: condition.whereIn,
          arrayContainsAny: condition.arrayContainsAny,
          arrayContains: condition.arrayContains,
        );
      } else {
        queryFinal.where(
          condition.field,
          isEqualTo: condition.isEqualTo,
          isNull: condition.isNull,
          isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
          isGreaterThan: condition.isGreaterThan,
          isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
          isLessThan: condition.isLessThan,
          isNotEqualTo: condition.isNotEqualTo,
          whereNotIn: condition.whereNotIn,
          whereIn: condition.whereIn,
          arrayContainsAny: condition.arrayContainsAny,
          arrayContains: condition.arrayContains,
        );
      }
    }
    if (orderBy != null) {
      queryFinal = queryFinal!.orderBy(orderBy, descending: orderByDescending);
    }

    return queryFinal!;
  }

  Query createQuery(String rootDomainUid, Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull,
      String? orderBy,
      bool orderByDescending = false}) {
    Query query = getCollectionReference(rootDomainUid).where(field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull);

    if (orderBy != null) {
      query = query.orderBy(field, descending: orderByDescending);
    }

    return query;
  }

  Future<List<T>> where(String rootDomainUid, Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull,
      String? orderBy,
      bool orderByDescending = false}) {
    return getFromQuery(createQuery(rootDomainUid, field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull,
        orderBy: orderBy,
        orderByDescending: orderByDescending));
  }

  // Retourne une future avec une liste de domain sur lesquels on applique une Query.
  Future<List<T>> getFromQuery(Query query) async {
    Future<QuerySnapshot<T>> ftQuerySnaphot = query
        .withConverter<T>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (T domain, _) => domain.toJson(),
        )
        .get();

    return (await ftQuerySnaphot).docs.map((QueryDocumentSnapshot<T> querySnapshot) => querySnapshot.data()).toList();
  }

  Future<List<T>> getAllInAnyRoot() async {
    final List<T> resultList = <T>[];
    final List<Future<List<T>>> list =
        (await rootService.getAll()).map((U rootDomain) => getAll(rootDomain.uid!)).toList();
    (await Future.wait(list)).forEach((List<T> listT) => resultList.addAll(listT));
    return resultList;
  }

  Future<List<T>> getAll(String rootDomainUid) async {
    return getCollectionReference(rootDomainUid).get().then((QuerySnapshot<Map<String, dynamic>> value) =>
        value.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> e) => fromJson(e.data())).toList());
  }

  Stream<List<T>> listenAll(String rootDomainUid) {
    return getCollectionReference(rootDomainUid).snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => fromJson(doc.data())).toList());
  }

  Future<void> _sendToFireStore(T domain) {
    if (domain.createDate == null) {
      domain.createDate = FieldValue.serverTimestamp();
    }
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference(domain.getParentUid()).doc(domain.uid).set(domain.toJson());
  }

  Future<void> save(T domain) {
    if (domain.uid != null && domain.uid?.isNotEmpty == true) {
      return update(domain);
    } else {
      return create(domain);
    }
  }

  Future<void> create(T domainToSave) {
    domainToSave.creatorUid = FirebaseAuth.instance.currentUser?.uid;
    domainToSave.createDate = FieldValue.serverTimestamp();
    domainToSave.uid ??= getCollectionReference(domainToSave.getParentUid()).doc().id;
    return _sendToFireStore(domainToSave);
  }

  Future<void> update(T domainToSave) {
    return _sendToFireStore(domainToSave);
  }

  Future<void> delete(T domainToSave) {
    return getCollectionReference(domainToSave.getParentUid()).doc(domainToSave.uid).delete();
  }

  Future<T?> read(String rootDomainUid, String uidDomain) async {
    final Map<String, dynamic>? data = (await getCollectionReference(rootDomainUid).doc(uidDomain).get()).data();
    return data != null ? fromJson(data) : null;
  }
}

///
/// Classe abstraite dont on doit étendre pour récupérer les méthodes par défaut pour le CRUD Firebase.
///
abstract class AbstractFirebaseCrudService<T extends AbstractDomain> extends GetxService
    implements ICrudService<T>, IFromJson<T> {
  /// Méthode abstraite qui retournera la collectionReference.
  CollectionReference<Object?> getCollectionReference();

  Future<void> _sendToFireStore(T domain) {
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference().doc(domain.uid).set(domain.toJson()).then((_) {});
  }

  Future<List<T>> where(Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull,
      String? orderBy,
      bool orderByDescending = false}) {
    Query query = getCollectionReference().where(field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull);

    if (orderBy != null) {
      query = query.orderBy(field, descending: orderByDescending);
    }

    return getFromQuery(query);
  }

  Stream<List<T>> whereListen(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return listenFromQuery(getCollectionReference().where(field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull));
  }

  // Retourne une Stream de liste de domain sur lesquels on applique une Query.
  Stream<List<T>> listenFromQuery(Query query) {
    return query
        .withConverter<T>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (T domain, _) => domain.toJson(),
        )
        .snapshots()
        .map((QuerySnapshot<T> snapshot) => snapshot.docs.map((QueryDocumentSnapshot<T> e) => e.data()).toList());
  }

  // Retourne une future avec une liste de domain sur lesquels on applique une Query.
  Future<List<T>> getFromQuery(Query query) async {
    Future<QuerySnapshot<T>> ftQuerySnaphot = query
        .withConverter<T>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (T domain, _) => domain.toJson(),
        )
        .get();

    return (await ftQuerySnaphot).docs.map((QueryDocumentSnapshot<T> querySnapshot) => querySnapshot.data()).toList();
  }

  /// Méthode d'écoute d'un objet à partir de son UID.
  @override
  Stream<T> listen(String uid) {
    try {
      return getCollectionReference()
          .doc(uid)
          .snapshots()
          .map((DocumentSnapshot<Object?> event) => fromJson(event.data() as Map<String, dynamic>));
    } catch (e) {
      throw Exception('Soucis lors de la récupération de la référence du document. ${e.toString()}');
    }
  }

  /// Méthode de lecture d'un objet à partir de son UID.
  @override
  Future<T?> read(String uid) async {
    DocumentSnapshot<Object?> documentSnapshot;
    T doc;

    // Récupération de la référence du document.
    try {
      documentSnapshot = await getCollectionReference().doc(uid).get();
    } catch (e) {
      throw Exception('Soucis lors de la récupération de la référence du document. ${e.toString()}');
    }

    // Si le snapshot ne ramène rien, je renvoie null.
    Object? obj = documentSnapshot.data();
    if (obj == null) return null;

    // Je tente de désérialiser les infos.
    try {
      doc = fromJson(obj as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Soucis lors de la transformation fromJson. ${e.toString()}');
    }
    return doc;
  }

  ///
  /// Méthode de sauvegarde de l'entité passée.
  /// - Si un UID est présent, on appelle la méthode de mise à jour.
  /// - Si aucun UID présent, on affecte un UID et on appelle la méthode de création.
  @override
  Future<void> save(T domain) {
    if (domain.uid != null && domain.uid?.isNotEmpty == true) {
      return update(domain);
    } else {
      return create(domain);
    }
  }

  ///
  /// Méthode de création. On affecte un UID et on renseigne la date de création.
  ///
  @override
  Future<void> create(T domain) async {
    domain.creatorUid = FirebaseAuth.instance.currentUser?.uid;
    domain.createDate = FieldValue.serverTimestamp();
    domain.uid ??= getCollectionReference().doc().id;
    return _sendToFireStore(domain);
  }

  @override
  Future<void> update(T domain) async {
    return _sendToFireStore(domain);
  }

  @override
  Future<void> delete(T domain) {
    return getCollectionReference().doc(domain.uid).delete().then((_) {});
  }

  @override
  Future<List<T>> getAll() {
    return getCollectionReference().get().then((QuerySnapshot<Object?> value) =>
        value.docs.map((QueryDocumentSnapshot<Object?> e) => fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}

///
/// Classe Service spécifique à l'application Fitness NC pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessCrudService<T extends AbstractDomain> extends AbstractFirebaseCrudService<T> {}

///
/// Classe abstraite de service pour tous les domaines héritant de AbstractFitnessStorageDomain.
/// Ce service surcharge les méthodes de save et delete pour aller sauvegarder le storageFile et mettre à jour l'imageUrl de l'entité.
/// Il supprime également
///
abstract class AbstractFitnessStorageService<T extends AbstractStorageDomain> extends AbstractFitnessCrudService<T>
    with MFitnessStorageService<T> {
  Future<void> callUpdateOrCreate(T domain) {
    final bool isUpdate = domain.uid != null;
    return isUpdate ? update(domain) : create(domain);
  }

  @override
  Future<void> save(T domain) {
    final bool shouldSendToStorage = domain.storageFile?.fileBytes != null && domain.storageFile?.fileName != null;
    if (shouldSendToStorage) {
      return callUpdateOrCreate(domain)
          .then((_) => eraseAndReplaceStorage(domain))
          .then((_) => callUpdateOrCreate(domain))
          .catchError((Object? error) {
        print('Erreur ${error?.toString()}');
        return callUpdateOrCreate(domain);
      });
    } else {
      return callUpdateOrCreate(domain);
    }
  }

  @override
  Future<void> delete(T domain) {
    return deleteAllFiles(domain).then((_) => super.delete(domain));
  }
}

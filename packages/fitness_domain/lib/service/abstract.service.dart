import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:get/get.dart';

import 'abstract-crud.service.dart';
import 'abstract.mixin.dart';

///
/// Classe abstraite dont on doit étendre pour récupérer les méthodes par défaut pour le CRUD Firebase.
///
abstract class AbstractFirebaseCrudService<T extends AbstractDomain> extends GetxService implements AbstractCrudService<T> {
  /// Méthode abstraite qui retournera la collectionReference.
  CollectionReference<Object?> getCollectionReference();

  /// Méthode abstraite pour savoir comment désérialiser un objet T à partir d'un JSON.
  T fromJson(Map<String, dynamic> map);

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

  Future<void> _sendToFireStore(T domain) {
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference().doc(domain.uid).set(domain.toJson()).then((_) {});
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
abstract class AbstractFitnessStorageService<T extends AbstractFitnessStorageDomain> extends AbstractFitnessCrudService<T>
    with MixinFitnessStorageService<T> {
  Future<void> callUpdateOrCreate(T domain) {
    final bool isUpdate = domain.uid != null;
    return isUpdate ? update(domain) : create(domain);
  }

  @override
  Future<List<T>> getAll() {
    return getCollectionReference()
        .get()
        .then((QuerySnapshot<Object?> value) => value.docs.map((QueryDocumentSnapshot<Object?> e) => fromJson(e as Map<String, dynamic>)).toList());
  }

  @override
  Future<void> save(T domain) {
    final bool shouldSendToStorage = domain.storageFile?.fileBytes != null && domain.storageFile?.fileName != null;
    if (shouldSendToStorage) {
      return eraseAndReplaceStorage(domain).then((_) => callUpdateOrCreate(domain)).catchError((Object? error) {
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

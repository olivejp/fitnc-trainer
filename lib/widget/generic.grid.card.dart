import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';

///
/// Classe Bloc pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessStorageBloc<T extends AbstractFitnessStorageDomain> {
  final FirestorageService firestorageService = FirestorageService.instance();
  final String pathWorkoutMainImage = 'mainImage';

  void setStorageFile(T domain, StorageFile? value) {
    domain.storageFile = value;
  }

  /// Méthode abstraite
  String getUrl(User user, T domain);

  /// Envoi le document dans Firebase Storage.
  Future<void> createStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      domain.imageUrl = await _sendToStorage(domain);
    }
  }

  /// Supprime tous les documents présents dans Firebase Storage à l'adresse du getUrl() puis envoie le nouveau document.
  Future<void> eraseAndReplaceStorage(T domain) async {
    if (domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      await deleteAllFiles(domain);
      await createStorage(domain);
    }
  }

  /// Supprime tous les fichiers présents dans le storage à l'adresse indiquée par le getUrl().
  Future<void> deleteAllFiles(T domain) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return FirebaseStorage.instance.ref(getUrl(user, domain)).listAll().then((ListResult value) {
      final List<Future<void>> listFuture = <Future<void>>[];
      for (final Reference ref in value.items) {
        listFuture.add(ref.delete());
      }
      return listFuture;
    }).then((List<Future<void>> listFuture) => Future.wait(listFuture));
  }

  /// Envoi le StorageFile sur Firebase Storage.
  Future<String> _sendToStorage(T domain) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && domain.storageFile != null && domain.storageFile!.fileBytes != null && domain.storageFile!.fileName != null) {
      final String url = getUrl(user, domain);
      return firestorageService.sendToStorageAndGetReference(
          '$url/$pathWorkoutMainImage/${domain.storageFile!.fileName}', domain.storageFile!.fileBytes!);
    }
    throw Exception('Envoi sur le storage échoué.');
  }

  /// Permet de récupérer le StorageFile à partir du Domain.
  Future<StorageFile?> getFutureStorageFile(T domain) {
    final Completer<StorageFile?> completer = Completer<StorageFile?>();
    if (domain.imageUrl != null && domain.imageUrl!.isNotEmpty) {
      firestorageService.getRemoteImageToUint8List(domain.imageUrl!).then((Uint8List bytes) {
        domain.storageFile!.fileName = basename(domain.imageUrl!);
        domain.storageFile!.fileBytes = bytes;
        completer.complete(domain.storageFile);
      });
    } else {
      completer.complete(null);
    }
    return completer.future;
  }
}

abstract class AbstractCrudBloc<T> {
  Future<void> save(T domain);

  Future<void> create(T domain);

  Future<void> update(T domain);

  Future<void> delete(T domain);
}

///
/// Classe Bloc pour implémenter les méthodes de base du CRUD
///
abstract class AbstractFitnessCrudBloc<T extends AbstractFitnessDomain> implements AbstractCrudBloc<T> {
  /// Méthode abstraite qui retournera la collectionReference.
  CollectionReference<Object?> getCollectionReference();

  /// Méthode abstraite qui retournera le widget à ouvrir pour une mise à jour.
  Widget openUpdate(BuildContext context, T domain);

  /// Méthode de sauvegarde l'entité passée.
  @override
  Future<void> save(T domain) {
    if (domain.uid != null && domain.uid?.isNotEmpty == true) {
      return update(domain);
    } else {
      return create(domain);
    }
  }

  @override
  Future<void> create(T domain) async {
    domain.createDate = FieldValue.serverTimestamp();
    domain.uid ??= getCollectionReference().doc().id;
    return sendToFireStore(domain);
  }

  @override
  Future<void> update(T domain) async {
    return sendToFireStore(domain);
  }

  @override
  Future<void> delete(T domain) {
    return getCollectionReference().doc(domain.uid).delete().then((_) {});
  }

  Future<void> sendToFireStore(T domain) {
    domain.updateDate = FieldValue.serverTimestamp();
    return getCollectionReference().doc(domain.uid).set(domain.toJson()).then((_) {});
  }
}

///
/// Classe Widget pour une GridView spécialisée pour un AbstractFitnessDomain.
///
class FitnessGridView<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const FitnessGridView({Key? key, required this.domains, required this.bloc}) : super(key: key);
  final List<T> domains;
  final AbstractFitnessCrudBloc<T> bloc;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      int nbColumns = 1;
      if (constraints.maxWidth > 1200) {
        nbColumns = 6;
      } else if (constraints.maxWidth > 1000) {
        nbColumns = 4;
      } else if (constraints.maxWidth > 800) {
        nbColumns = 3;
      } else if (constraints.maxWidth > 600) {
        nbColumns = 2;
      }

      return GridView.count(
        childAspectRatio: 13 / 9,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: nbColumns,
        children: domains.map((T domain) {
          return FitnessGridCard<T>(
            domain: domain,
            onTap: (T domain) {
              Navigator.push(
                  context,
                  PageTransition<T>(
                      duration: Duration.zero,
                      reverseDuration: Duration.zero,
                      type: PageTransitionType.fade,
                      child: bloc.openUpdate(context, domain)));
            },
            onDelete: (T domain) {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Êtes-vous sûr de vouloir supprimer cet exercice ?'),
                  actions: <Widget>[
                    TextButton(onPressed: () => bloc.delete(domain).then((_) => Navigator.pop(context)), child: const Text('Oui')),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    });
  }
}

///
/// Classe Widget pour une Grid Card.
///
class FitnessGridCard<T extends AbstractFitnessStorageDomain> extends StatelessWidget {
  const FitnessGridCard({Key? key, required this.domain, required this.onTap, required this.onDelete}) : super(key: key);

  final T domain;
  final void Function(T domain) onTap;
  final void Function(T domain) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        onTap: () => onTap(domain),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: (domain.imageUrl?.isNotEmpty == true)
                  ? Ink.image(
                      image: NetworkImage(
                        domain.imageUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : Container(decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(domain.name!, style: const TextStyle(fontSize: 15)),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () => onDelete(domain),
                    icon: const Icon(Icons.delete, color: Colors.grey, size: 24),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

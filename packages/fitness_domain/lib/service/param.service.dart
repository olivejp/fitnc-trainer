import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/abstract.absolute-firestore.service.dart';
import 'package:fitness_domain/domain/param.domain.dart';
import 'package:flutter/material.dart';

class ParamService extends AbstractAbsoluteFirestoreService<Param> {
  ParamService._() : super(collectionReference: FirebaseFirestore.instance.collection('params')) {
    _instance = this;
  }

  static ParamService? _instance;

  static ParamService getInstance() {
    _instance ??= ParamService._();
    return _instance!;
  }

  Stream<List<Param>> listenListParam(String paramName) {
    return collectionReference.doc(paramName).collection('values').orderBy('order').snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> querySnapshot) =>
            querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> e) {
              try {
                return Param.fromJson(e.data());
              } catch (e) {
                print(e);
                throw Exception('Mal barrée');
              }
            }).toList());
  }

  Future<List<Param>> getListParam(String paramName) {
    return collectionReference
        .doc(paramName)
        .collection('values')
        .orderBy('order')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) => querySnapshot.docs.map((e) {
              try {
                return Param.fromJson(e.data());
              } catch (e) {
                print("Erreur : ${e}");
                throw Exception('Mal barrée');
              }
            }).toList());
  }

  DropdownMenuItem<String?> mapParamToDropdownItem(Param param, {required bool onlyName}) {
    return DropdownMenuItem<String?>(
      value: param.valeur,
      child: getRowFromParam(param, onlyName),
    );
  }

  List<DropdownMenuItem<String?>> getParamAsDropdown(
      List<Param> params, bool onlyName, bool insertNull, String? nullElement) {
    final List<DropdownMenuItem<String?>> list =
        params.map((param) => mapParamToDropdownItem(param, onlyName: onlyName)).toList();

    if (insertNull) {
      list.add(DropdownMenuItem<String?>(
        child: nullElement != null ? Text(nullElement) : const Text(''),
      ));
    }

    return list;
  }

  Future<List<DropdownMenuItem<String?>>> getFutureParamAsDropdown(String paramName,
      {bool onlyName = false, bool insertNull = false, String? nullElement}) async {
    final List<DropdownMenuItem<String?>> list =
        (await getListParam(paramName)).map((param) => mapParamToDropdownItem(param, onlyName: onlyName)).toList();

    if (insertNull) {
      list.add(DropdownMenuItem<String?>(
        child: nullElement != null ? Text(nullElement) : const Text(''),
      ));
    }

    return list;
  }

  Widget getRowFromParam(Param param, bool onlyName) {
    if (onlyName) {
      return Text(param.nom!);
    } else {
      return Row(children: <Widget>[
        Text('${param.nom!}  -  '),
        Text(
          param.libelle!,
          style: TextStyle(fontStyle: FontStyle.italic, color: Color(Colors.grey.value)),
        ),
      ]);
    }
  }

  @override
  Param mapSnapshotToModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Param.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}

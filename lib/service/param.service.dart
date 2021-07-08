import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/param.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firestore/abstract.absolute-firestore.service.dart';

class ParamService extends AbstractAbsoluteFirestoreService<Param> {
  static ParamService? _instance;

  ParamService._() : super(collectionReference: FirebaseFirestore.instance.collection('params')) {
    _instance = this;
  }

  static ParamService getInstance() {
    if (_instance == null) {
      _instance = ParamService._();
    }
    return _instance!;
  }

  Future<List<Param>> getListParam(String paramName) {
    return findAllSpecific(this.collectionReference.doc(paramName).collection('values'));
  }

  Future<List<DropdownMenuItem<dynamic>>> getParamAsDropdown(String paramName) async {
    return (await getListParam(paramName))
        .map((param) => DropdownMenuItem(
              child: Row(children: [
                Text(param.nom! + '  -  '),
                Text(param.libelle!, style: TextStyle(fontStyle: FontStyle.italic, color: Color(Colors.grey.value)),),
              ]),
              value: param.valeur,
            ))
        .toList();
  }

  @override
  Param mapSnapshotToModel(DocumentSnapshot snapshot) {
    return Param.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}

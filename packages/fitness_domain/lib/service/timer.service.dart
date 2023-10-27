import 'package:fitness_domain/service/param.service.dart';
import 'package:fitness_domain/domain/param.domain.dart';
import 'package:flutter/material.dart';

class TimerService {

  TimerService._() {
    _instance = this;
    timerArray.sort((a, b) => a.order!.compareTo(b.order!));
  }
  final ParamService paramService = ParamService.getInstance();
  List<Param> timerArray = [
    Param(nom: '5 sec', libelle: '5 secondes', valeur: '5_SEC', order: 1),
    Param(nom: '10 sec', libelle: '10 secondes', valeur: '10_SEC', order: 2),
    Param(nom: '15 sec', libelle: '15 secondes', valeur: '15_SEC', order: 3),
    Param(nom: '20 sec', libelle: '20 secondes', valeur: '20_SEC', order: 4),
    Param(nom: '25 sec', libelle: '25 secondes', valeur: '25_SEC', order: 5),
    Param(nom: '30 sec', libelle: '30 secondes', valeur: '30_SEC', order: 6),
    Param(nom: '35 sec', libelle: '35 secondes', valeur: '35_SEC', order: 7),
    Param(nom: '40 sec', libelle: '40 secondes', valeur: '40_SEC', order: 8),
    Param(nom: '45 sec', libelle: '45 secondes', valeur: '45_SEC', order: 9),
    Param(nom: '50 sec', libelle: '50 secondes', valeur: '50_SEC', order: 10),
    Param(nom: '55 sec', libelle: '55 secondes', valeur: '55_SEC', order: 11),
    Param(nom: '60 sec', libelle: '60 secondes', valeur: '60_SEC', order: 12),
    Param(nom: '90 sec', libelle: '90 secondes', valeur: '90_SEC', order: 13),
    Param(nom: '2 min', libelle: '2 minutes', valeur: '2_MIN', order: 14),
    Param(nom: '3 min', libelle: '3 minutes', valeur: '3_MIN', order: 15),
    Param(nom: '5 min', libelle: '5 minutes', valeur: '5_MIN', order: 16),
    Param(nom: '10 min', libelle: '10 minutes', valeur: '10_MIN', order: 17),
    Param(nom: '30 min', libelle: '30 minutes', valeur: '30_MIN', order: 18),
    Param(nom: '1 h', libelle: '1 heure', valeur: '1_HOUR', order: 19),
  ];

  static TimerService? _instance;

  static TimerService getInstance() {
    _instance ??= TimerService._();
    return _instance!;
  }

  List<DropdownMenuItem<String?>> getDropdownMenuItem(bool onlyName, bool insertNull, String? nullElement) {
    return paramService.getParamAsDropdown(this.timerArray, onlyName, insertNull, nullElement);
  }
}

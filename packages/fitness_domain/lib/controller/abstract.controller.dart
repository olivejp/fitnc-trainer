import 'dart:async';

import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/service/abstract-crud.service.dart';
import 'package:fitness_domain/service/util.service.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

abstract class LocalSearchControllerMixin<T extends InterfaceDomainSearchable, U extends ICrudService<T>> extends GetxController {
  LocalSearchControllerMixin();

  final U service = Get.find();
  final BehaviorSubject<List<T>> streamList = BehaviorSubject<List<T>>();
  final List<T> listComplete = <T>[];
  final RxString query = ''.obs;
  StreamSubscription<List<T>>? subscription;

  void _initList() {
    subscription = service.listenAll().listen((List<T> event) {
      listComplete.clear();
      listComplete.addAll(event);
      streamList.sink.add(listComplete);
      UtilService.search(query.value, listComplete, streamList);
    });
  }

  void refreshSearchController() {
    if (subscription != null) {
      subscription!.cancel().then((_) => _initList());
    } else {
      _initList();
    }

    query.listen((String queryValue) {
      UtilService.search(queryValue, listComplete, streamList);
    });
  }
}

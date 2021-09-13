import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/util.service.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

abstract class SearchControllerMixin<T extends InterfaceDomainSearchable, U extends AbstractCrudService<T>> extends GetxController {
  SearchControllerMixin();

  final U service = Get.find();
  final BehaviorSubject<List<T>> streamList = BehaviorSubject<List<T>>();
  final List<T> listComplete = <T>[];
  final RxString query = ''.obs;

  void refreshSearchController() {
    service.listenAll().listen((List<T> event) {
      listComplete.clear();
      listComplete.addAll(event);
      streamList.sink.add(listComplete);
      UtilService.search(query.value, listComplete, streamList);
    });

    query.listen((String queryValue) {
      UtilService.search(queryValue, listComplete, streamList);
    });
  }
}

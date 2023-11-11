import 'dart:async';

import 'package:fitness_domain/domain/abstract.domain.dart';
import 'package:fitness_domain/service/util.service.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

///
/// Classe utilitaire pour rechercher dans une liste.
///
mixin SearchMixin<T extends InterfaceDomainSearchable> {
  final BehaviorSubject<List<T>> streamList = BehaviorSubject<List<T>>();
  final List<T> _listComplete = <T>[];
  final RxString searchQuery = ''.obs;

  void clearSearch() {
    searchQuery.value = '';
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void initSearchList({
    Stream<List<T>> Function()? getStreamList,
    Future<List<T>> Function()? getFutureList,
    List<T> Function()? getLocalList,
  }) {
    assert(getStreamList != null || getFutureList != null || getLocalList != null,
        'initSearchList called without any parameter. Please provide at least one of these method : getStreamList, getFutureList, getLocalList.');

    _fetchList(getStreamList, getFutureList, getLocalList);
    searchQuery.listen((String queryValue) {
      UtilService.search(queryValue, _listComplete, streamList);
    });
  }

  void _fetchList(
    Stream<List<T>> Function()? getStreamList,
    Future<List<T>> Function()? getFutureList,
    List<T> Function()? getLocalList,
  ) {
    if (getLocalList != null) {
      _initialization(getLocalList());
      return;
    }

    if (getFutureList != null) {
      getFutureList().then((List<T> listValues) => _initialization(listValues));
      return;
    }

    if (getStreamList != null) {
      getStreamList().listen((List<T> listValues) => _initialization(listValues));
      return;
    }
  }

  void _initialization(List<T> event) {
    _listComplete.clear();
    _listComplete.addAll(event);
    streamList.sink.add(_listComplete);
    UtilService.search(searchQuery.value, _listComplete, streamList);
  }
}

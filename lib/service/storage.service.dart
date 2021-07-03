import 'package:localstorage/localstorage.dart';

class StorageService {
  final LocalStorage storage = new LocalStorage('food_nc_storage');
  static StorageService _instance;

  // Private constructor with the ._()
  StorageService._();

  static StorageService getInstance() {
    if (_instance == null) {
      _instance = StorageService._();
    }
    return _instance;
  }

  Future<bool> initStorage() {
    return storage.ready.then((value) {
      if (value) {
        print('Storage is ready');
      } else {
        print('!!! Storage is NOT ready !!!');
      }
    }).catchError(
        (error) => print('Erreur lors du chargement du storage : ' + error));
  }

  Future<void> setItem(String key, dynamic value) {
    return storage.setItem(key, value);
  }

  dynamic getItem(String key) {
    return storage.getItem(key);
  }

  LocalStorage getStorage() {
    return storage;
  }
}

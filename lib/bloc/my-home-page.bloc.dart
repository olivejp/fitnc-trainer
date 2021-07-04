import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePageBloc {
  static MyHomePageBloc? _instance;

  final AuthService authService = AuthService.getInstance();

  int _currentPage = 0;
  late BehaviorSubject<int> _streamCurrentPage;

  Stream<int> get currentPageObs => _streamCurrentPage.stream;

  MyHomePageBloc._() {
    _streamCurrentPage = BehaviorSubject.seeded(0);
  }

  static MyHomePageBloc getInstance() {
    if (_instance == null) {
      _instance = MyHomePageBloc._();
    }
    return _instance!;
  }

  changePage(int newPage) {
    _currentPage = newPage;
    _streamCurrentPage.sink.add(_currentPage);
  }

  Future<bool> logout() {
    return authService.disconnect();
  }
}

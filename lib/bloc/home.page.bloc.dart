import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePageBloc {
  static MyHomePageBloc? _instance;

  final AuthService authService = AuthService.getInstance();

  int _currentPage = 0;
  bool _currentDisplay = false;
  late BehaviorSubject<int> _streamCurrentPage;
  late BehaviorSubject<bool> _streamDisplayList;

  Stream<int> get currentPageObs => _streamCurrentPage.stream;
  Stream<bool> get currentDisplayObs => _streamDisplayList.stream;

  MyHomePageBloc._() {
    _streamCurrentPage = BehaviorSubject.seeded(0);
    _streamDisplayList = BehaviorSubject.seeded(_currentDisplay);
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

  toggleDisplay() {
    _currentDisplay = !_currentDisplay;
    _streamDisplayList.sink.add(_currentDisplay);
  }
}

import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePageBloc {
  factory MyHomePageBloc.instance() {
    _instance ??= MyHomePageBloc._();
    return _instance!;
  }

  MyHomePageBloc._() {
    _streamCurrentPage = BehaviorSubject<int>.seeded(_currentPage);
    _streamDisplayList = BehaviorSubject<bool>.seeded(_currentDisplay);
    _streamIsExpanded = BehaviorSubject<bool>.seeded(_isExpanded);
  }

  static MyHomePageBloc? _instance;

  final AuthService authService = AuthService.getInstance();

  int _currentPage = 0;
  bool _currentDisplay = false;
  late BehaviorSubject<int> _streamCurrentPage;
  late BehaviorSubject<bool> _streamDisplayList;
  late BehaviorSubject<bool> _streamIsExpanded;
  bool _isExpanded = false;

  Stream<bool> get currentIsExpanded => _streamIsExpanded.stream;

  Stream<int> get currentPageObs => _streamCurrentPage.stream;

  Stream<bool> get currentDisplayObs => _streamDisplayList.stream;

  set isExpanded(bool isExpanded) {
    _isExpanded = isExpanded;
    _streamIsExpanded.sink.add(isExpanded);
  }

  bool get isExpanded => _isExpanded;

  void changePage(int newPage) {
    _currentPage = newPage;
    _streamCurrentPage.sink.add(_currentPage);
  }

  Future<bool> logout() {
    return authService.disconnect();
  }

  void toggleDisplay() {
    _currentDisplay = !_currentDisplay;
    _streamDisplayList.sink.add(_currentDisplay);
  }
}

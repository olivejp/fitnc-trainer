import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:rxdart/rxdart.dart';

enum Pages { pageWorkout, pageExercice, pageCalendar, pageProgramme }

class MyHomePageBloc {
  static MyHomePageBloc? _instance;

  final AuthService authService = AuthService.getInstance();

  Pages _currentPage = Pages.pageProgramme;
  bool _currentDisplay = false;
  late BehaviorSubject<Pages> _streamCurrentPage;
  late BehaviorSubject<bool> _streamDisplayList;
  late BehaviorSubject<bool> _streamIsExpanded;
  bool _isExpanded = false;

  Stream<bool> get currentIsExpanded => _streamIsExpanded.stream;

  Stream<Pages> get currentPageObs => _streamCurrentPage.stream;

  Stream<bool> get currentDisplayObs => _streamDisplayList.stream;

  MyHomePageBloc._() {
    _streamCurrentPage = BehaviorSubject.seeded(Pages.pageProgramme);
    _streamDisplayList = BehaviorSubject.seeded(_currentDisplay);
    _streamIsExpanded = BehaviorSubject.seeded(_isExpanded);
  }

  set isExpanded(bool isExpanded) {
    _isExpanded = isExpanded;
    _streamIsExpanded.sink.add(isExpanded);
  }

  bool get isExpanded => _isExpanded;

  static MyHomePageBloc getInstance() {
    _instance ??= MyHomePageBloc._();
    return _instance!;
  }

  changePage(Pages newPage) {
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

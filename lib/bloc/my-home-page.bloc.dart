import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePageBloc {
  static MyHomePageBloc _instance;

  int _currentPage = 0;
  BehaviorSubject<int> _streamCurrentPage;

  Observable<int> get currentPageObs => _streamCurrentPage.stream;

  MyHomePageBloc._() {
    _streamCurrentPage = BehaviorSubject(seedValue: 0);
  }

  static MyHomePageBloc getInstance() {
    if (_instance == null) {
      _instance = MyHomePageBloc._();
    }
    return _instance;
  }


  changePage(int newPage) {
    _currentPage = newPage;
    _streamCurrentPage.sink.add(_currentPage);
  }
}

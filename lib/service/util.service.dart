import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:rxdart/rxdart.dart';

class UtilSearch {
  static void search<T extends AbstractFirebaseDomain>(String? query, List<T> listCompleteDomain, Subject<List<T>> stream) {
    final String? text = query?.toUpperCase();
    List<T> listFiltered;
    if (text != null && text.isNotEmpty) {
      listFiltered = listCompleteDomain.where((T element) {
        final bool inName = element.name != null && element.name!.toUpperCase().contains(text);
        final bool inDescription = element.description != null && element.description!.toUpperCase().contains(text);
        return inName || inDescription;
      }).toList();
    } else {
      listFiltered = listCompleteDomain;
    }
    stream.sink.add(listFiltered);
  }
}
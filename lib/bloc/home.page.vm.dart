import 'package:get/get.dart';

class HomePageController extends GetxController {
  HomePageController();

  RxInt currentPage = 0.obs;
  RxBool isExpanded = false.obs;

  void changePage(int newPage) {
    currentPage.value = newPage;
  }

  void changeExpanded(bool isExpanded) {
    this.isExpanded.value = isExpanded;
  }
}

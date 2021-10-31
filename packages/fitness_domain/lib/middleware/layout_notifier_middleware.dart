import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutNotifierMiddleware extends GetMiddleware {
  @override
  Widget onPageBuilt(Widget page) {
    return LayoutNotifier(child: page);
  }
}

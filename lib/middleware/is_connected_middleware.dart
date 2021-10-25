import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsConnectedMiddleware extends GetMiddleware {
  final AuthService authService = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    if (!authService.isConnected()) {
      return const RouteSettings(name: FitnessConstants.routeLogin);
    }
    return null;
  }
}

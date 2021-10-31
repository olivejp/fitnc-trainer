import 'dart:developer' as developer;

import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsConnectedMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {

    final AuthService authService = Get.find();

    if (!authService.isConnected()) {
      developer.log('User not connected redirect to /login');
      return const RouteSettings(name: FitnessConstants.routeLogin);
    }

    developer.log('User connected continue to $route');
    return null;
  }
}

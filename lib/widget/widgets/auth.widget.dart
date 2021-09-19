import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/controller/auth.controller.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWidget extends StatelessWidget {
  AuthWidget({Key? key}) : super(key: key);

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find();
    return StreamBuilder<User?>(
      stream: authService.listenUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            authController.user.value = user;
            return MyHomePage();
          } else {
            authController.user.value = null;
            return const LoginPage();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

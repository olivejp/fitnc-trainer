import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/constants.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:fitnc_trainer/widget/home.page.dart';
import 'package:fitnc_trainer/widget/login/login.page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.getUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user != null ? MyHomePage(FitnessConstants.appTitle) : LoginPage();
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

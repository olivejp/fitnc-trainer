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
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<User?>(
      stream: authService.getUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            return Provider<User>.value(value: user, child: const MyHomePage());
          } else {
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

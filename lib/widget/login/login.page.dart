import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottom.widget.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPageController extends GetxController {
  AuthService authService = Get.find();

  String? email;
  String? password;
  RxBool hidePassword = true.obs;
  Rx<String?> errors = null.obs;

  void switchHidePassword() {
    hidePassword.value = !hidePassword.value;
  }

  void setError(String? errors) {
    this.errors.value = errors;
  }

  Future<UserCredential> onPressedEnter(GlobalKey<FormState> formKey) {
    setError(null);
    if (email == null) {
      return Future<UserCredential>.error("L'email ne peut pas être null.'");
    }

    if (password == null) {
      return Future<UserCredential>.error("Le mot de passe ne peut pas être null.'");
    }

    if (formKey.currentState?.validate() == true) {
      return authService.signInWithEmailPassword(email!, password!).catchError((Object? error) {
        setError(error.toString());
      });
    } else {
      return Future<UserCredential>.error("Le formulaire n'est pas valide.");
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  final LoginPageController controller = Get.put(LoginPageController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    return Scaffold(
        backgroundColor: FitnessNcColors.blue50,
        body: Stack(children: <Widget>[
          Transform(
            transform: Matrix4.identity()
              ..translate(MediaQuery.of(context).size.width)
              ..add(Matrix4.skewX(-0.3)),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.amber.withAlpha(100), Colors.amber.shade700])),
            ),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(MediaQuery.of(context).size.width - 80)
              ..add(Matrix4.skewX(-0.3)),
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.amber.withAlpha(100), Colors.amber.shade700])),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30, left: 20),
                        child: Text(
                          FitnessConstants.appTitle,
                          style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 25),
                        ),
                      ),
                      Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(60.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  'connectToYourAccount'.tr,
                                  style: GoogleFonts.robotoTextTheme()
                                      .headline6!
                                      .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: TextFormField(
                                    style: GoogleFonts.roboto(fontSize: 15),
                                    decoration: InputDecoration(
                                        labelText: 'email'.tr,
                                        hintStyle: GoogleFonts.roboto(fontSize: 15),
                                        focusedBorder: defaultBorder,
                                        border: defaultBorder,
                                        enabledBorder: defaultBorder),
                                    onChanged: (String value) => controller.email = value,
                                    onFieldSubmitted: (_) =>
                                        controller.onPressedEnter(_formKey).then((UserCredential value) {
                                      if (widget.callback != null) {
                                        widget.callback!(value);
                                      }
                                    }),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Merci de renseigner votre adresse email.';
                                      }
                                      if (!RegExp(
                                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                          .hasMatch(value)) {
                                        return "L'adresse mail n'est pas formatée correctement'.";
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Obx(
                                        () => TextFormField(
                                          style: GoogleFonts.roboto(fontSize: 15),
                                          obscureText: controller.hidePassword.value,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                            labelText: 'password'.tr,
                                            focusedBorder: defaultBorder,
                                            border: defaultBorder,
                                            enabledBorder: defaultBorder,
                                            hintStyle: GoogleFonts.roboto(fontSize: 15),
                                            suffixIcon: IconButton(
                                              tooltip:
                                                  controller.hidePassword.value ? 'showPassword'.tr : 'hidePassword'.tr,
                                              onPressed: controller.switchHidePassword,
                                              icon: controller.hidePassword.value
                                                  ? const Icon(Icons.visibility_outlined)
                                                  : const Icon(Icons.visibility_off_outlined),
                                            ),
                                          ),
                                          onChanged: (String value) => controller.password = value,
                                          onFieldSubmitted: (_) =>
                                              controller.onPressedEnter(_formKey).then((UserCredential value) {
                                            if (widget.callback != null) {
                                              widget.callback!(value);
                                            }
                                          }),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => print('hello'),
                                        child: Text('passwordForgotten'.tr),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                                    onPressed: () => controller.onPressedEnter(_formKey).then((UserCredential value) {
                                      if (widget.callback != null) {
                                        widget.callback!(value);
                                      }
                                    }),
                                    child: Text(
                                      'continue'.tr,
                                      style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () =>
                                      (controller.errors.value != null) ? Text(controller.errors.value!) : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30, left: 20),
                        child: Row(
                          children: <Widget>[
                            Text('noAccount'.tr),
                            TextButton(
                              onPressed: () => Get.offNamed(FitnessConstants.routeSignUp),
                              child: Text(
                                'signUp'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const FitnessBottomCu(),
        ]));
  }
}

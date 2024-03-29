import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/controller/login/sign-up.controller.dart';
import 'package:fitnc_trainer/widget/bottom.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;

  @override
  _SignUpPageState createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  _SignUpPageState();

  final SignUpController controller = Get.put(SignUpController());
  final HidePasswordController hidePasswordController = Get.put(HidePasswordController());
  final DisplayTypeService displayTypeService = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    final Widget columnLeft = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 20),
            child: Text(
              FitnessConstants.appTitle,
              style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 25),
            ),
          ),
        ),
      ],
    );

    void onPressedEnter() {
      controller.cleanError();
      if (_formKey.currentState?.validate() == true) {
        controller.signUp().then((UserCredential value) {
          if (widget.callback != null) {
            widget.callback!(value);
          }
        }).catchError((Object? error) {
          if (error is FirebaseAuthException) {
            controller.setError(error.message!);
          } else {
            controller.setError(error.toString());
          }
        });
      }
    }

    final Widget columnRight = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                            'Créez votre compte',
                            style: GoogleFonts.robotoTextTheme()
                                .headline6!
                                .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: TextFormField(
                                        style: GoogleFonts.roboto(fontSize: 15),
                                        decoration: InputDecoration(
                                          labelStyle: GoogleFonts.roboto(fontSize: 15),
                                          focusedBorder: defaultBorder,
                                          border: defaultBorder,
                                          enabledBorder: defaultBorder,
                                          labelText: 'Nom',
                                        ),
                                        onChanged: (String value) => controller.name = value,
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Merci de renseigner votre nom.';
                                          }
                                        }),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: TextFormField(
                                        style: GoogleFonts.roboto(fontSize: 15),
                                        decoration: InputDecoration(
                                          labelText: 'Prénom',
                                          focusedBorder: defaultBorder,
                                          border: defaultBorder,
                                          enabledBorder: defaultBorder,
                                        ),
                                        onChanged: (String value) => controller.prenom = value,
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Merci de renseigner votre prénom.';
                                          }
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              style: GoogleFonts.roboto(fontSize: 15),
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.email),
                                labelText: 'Email',
                                focusedBorder: defaultBorder,
                                border: defaultBorder,
                                enabledBorder: defaultBorder,
                              ),
                              onChanged: (String value) => controller.email = value,
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
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              style: GoogleFonts.roboto(fontSize: 15),
                              onChanged: (String value) => controller.telephone = value,
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.phone_android),
                                labelText: 'Téléphone',
                                focusedBorder: defaultBorder,
                                border: defaultBorder,
                                enabledBorder: defaultBorder,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Obx(
                              () => TextFormField(
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  onChanged: (String value) => controller.password = value,
                                  obscureText: hidePasswordController.hidePassword1.value,
                                  decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      focusedBorder: defaultBorder,
                                      border: defaultBorder,
                                      enabledBorder: defaultBorder,
                                      suffixIcon: IconButton(
                                        tooltip: hidePasswordController.hidePassword1.value
                                            ? 'Afficher le mot de passe'
                                            : 'Masquer le mot de passe',
                                        onPressed: hidePasswordController.switchPassword1,
                                        icon: hidePasswordController.hidePassword1.value
                                            ? const Icon(Icons.visibility_outlined)
                                            : const Icon(Icons.visibility_off_outlined),
                                      )),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le mot de passe ne peut pas être vide.';
                                    }
                                  }),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Obx(
                              () => TextFormField(
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  onChanged: (String value) => controller.passwordCheck = value,
                                  obscureText: hidePasswordController.hidePassword2.value,
                                  decoration: InputDecoration(
                                      focusedBorder: defaultBorder,
                                      border: defaultBorder,
                                      enabledBorder: defaultBorder,
                                      labelText: 'Retaper votre mot de passe',
                                      suffixIcon: IconButton(
                                          tooltip: hidePasswordController.hidePassword2.value
                                              ? 'Afficher le mot de passe'
                                              : 'Masquer le mot de passe',
                                          onPressed: hidePasswordController.switchPassword2,
                                          icon: hidePasswordController.hidePassword2.value
                                              ? const Icon(Icons.visibility_outlined)
                                              : const Icon(Icons.visibility_off_outlined))),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le mot de passe ne peut pas être vide.';
                                    }
                                    if (controller.password != controller.passwordCheck) {
                                      return "Le mot de passe n'est pas identique.";
                                    }
                                  }),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                                onPressed: () => onPressedEnter(),
                                child: Text('Créer un compte',
                                    style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15)),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Vous avez un compte ?'),
                                TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/login'),
                                    child: const Text(
                                      'Connexion.',
                                    )),
                              ],
                            ),
                          ),
                          Obx(
                            () {
                              if (controller.errors.value.isNotEmpty == true) {
                                return Text(
                                  controller.errors.value,
                                  style: const TextStyle(color: Colors.red),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );

    return LayoutNotifier(
      child: Scaffold(
        backgroundColor: FitnessNcColors.blue50,
        body: Stack(
          children: <Widget>[
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
                        colors: <Color>[Colors.amber.withAlpha(100), Colors.amber.shade700])),
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
                        colors: <Color>[Colors.amber.withAlpha(100), Colors.amber.shade700])),
              ),
            ),
            Builder(builder: (_) {
              const Widget child = FitnessBottomCu();
              Widget toShow;
              if (displayTypeService.displayType.value == DisplayType.desktop) {
                toShow = Row(
                  children: <Widget>[
                    Expanded(child: columnLeft),
                    Expanded(child: columnRight),
                  ],
                );
              } else {
                toShow = columnRight;
              }
              return Stack(children: <Widget>[toShow, child]);
            }),
          ],
        ),
      ),
    );
  }
}

/// Controller pour changer l'état des boutons 'Hide password'.
class HidePasswordController extends GetxController {
  RxBool hidePassword1 = true.obs;
  RxBool hidePassword2 = true.obs;

  void switchPassword1() {
    hidePassword1.value = !hidePassword1.value;
  }

  void switchPassword2() {
    hidePassword2.value = !hidePassword2.value;
  }
}

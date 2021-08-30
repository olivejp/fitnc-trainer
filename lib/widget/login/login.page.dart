import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../bottom.widget.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPageVm with ChangeNotifier {
  LoginPageVm(BuildContext context) {
    authService = Provider.of<AuthService>(context, listen: false);
  }

  late AuthService authService;
  String? email;
  String? password;
  bool _hidePassword = true;
  String? _errors;

  bool get hidePassword => _hidePassword;

  void switchHidePassword() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  String? get errors => _errors;

  void setError(String? errors) {
    _errors = errors;
    notifyListeners();
  }

  Future<UserCredential> onPressedEnter(GlobalKey<FormState> formKey) {
    setError(null);
    if (email == null) {
      return Future<UserCredential>.error("L'email ne peut pas être null.'");
    }

    if (password == null) {
      return Future<UserCredential>.error(
          "Le mot de passe ne peut pas être null.'");
    }

    if (formKey.currentState?.validate() == true) {
      return authService
          .signInWithEmailPassword(email!, password!)
          .catchError((Object? error) {
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    return ChangeNotifierProvider<LoginPageVm>(
      create: (BuildContext context) => LoginPageVm(context),
      builder: (BuildContext context, _) {
        final LoginPageVm vm = Provider.of<LoginPageVm>(context, listen: false);

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
                          colors: [
                        Colors.amber.withAlpha(100),
                        Colors.amber.shade700
                      ])),
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
                          colors: [
                        Colors.amber.withAlpha(100),
                        Colors.amber.shade700
                      ])),
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
                            padding:
                                const EdgeInsets.only(bottom: 30, left: 20),
                            child: Text(
                              FitnessConstants.appTitle,
                              style: GoogleFonts.alfaSlabOne(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 25),
                            ),
                          ),
                          Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(60.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      'Connectez-vous à votre compte',
                                      style: GoogleFonts.robotoTextTheme()
                                          .headline6!
                                          .copyWith(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: TextFormField(
                                        style: GoogleFonts.roboto(fontSize: 15),
                                        decoration: InputDecoration(
                                            labelText: 'Email',
                                            hintStyle: GoogleFonts.roboto(
                                                fontSize: 15),
                                            focusedBorder: defaultBorder,
                                            border: defaultBorder,
                                            enabledBorder: defaultBorder),
                                        onChanged: (String value) =>
                                            vm.email = value,
                                        onFieldSubmitted: (_) => vm
                                            .onPressedEnter(_formKey)
                                            .then((UserCredential value) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Consumer<LoginPageVm>(
                                            builder: (_, LoginPageVm consumeVm,
                                                    __) =>
                                                TextFormField(
                                              style: GoogleFonts.roboto(
                                                  fontSize: 15),
                                              obscureText:
                                                  consumeVm.hidePassword,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              decoration: InputDecoration(
                                                  labelText: 'Mot de passe',
                                                  focusedBorder: defaultBorder,
                                                  border: defaultBorder,
                                                  enabledBorder: defaultBorder,
                                                  hintStyle: GoogleFonts.roboto(
                                                      fontSize: 15),
                                                  suffixIcon: IconButton(
                                                      tooltip: consumeVm
                                                              .hidePassword
                                                          ? 'Afficher le mot de passe'
                                                          : 'Masquer le mot de passe',
                                                      onPressed: consumeVm
                                                          .switchHidePassword,
                                                      icon: vm.hidePassword
                                                          ? const Icon(Icons
                                                              .visibility_outlined)
                                                          : const Icon(Icons
                                                              .visibility_off_outlined))),
                                              onChanged: (String value) =>
                                                  vm.password = value,
                                              onFieldSubmitted: (_) => vm
                                                  .onPressedEnter(_formKey)
                                                  .then((UserCredential value) {
                                                if (widget.callback != null) {
                                                  widget.callback!(value);
                                                }
                                              }),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () => print('hello'),
                                              child: const Text(
                                                'Mot de passe oublié ?',
                                              )),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(
                                                double.infinity, 55)),
                                        onPressed: () => vm
                                            .onPressedEnter(_formKey)
                                            .then((UserCredential value) {
                                          if (widget.callback != null) {
                                            widget.callback!(value);
                                          }
                                        }),
                                        child: Text(
                                          'Continuer',
                                          style: GoogleFonts.roboto(
                                              color: Color(Colors.white.value),
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    Consumer<LoginPageVm>(
                                      builder: (_, LoginPageVm consumeVm, __) =>
                                          (consumeVm.errors != null)
                                              ? Text(consumeVm.errors!)
                                              : Container(),
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
                                const Text("Vous n'avez pas de compte ?"),
                                TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/sign_up'),
                                    child: const Text(
                                      "S'incrire",
                                      style: TextStyle(color: Colors.white),
                                    )),
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
      },
    );
  }
}

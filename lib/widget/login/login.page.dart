import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login/login.bloc.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottom.widget.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatefulWidget {
  LoginPage({Key? key,  this.callback}) : super(key: key);

  final LoginBloc bloc = LoginBloc.getInstance();
  final CallbackUserCredential? callback;

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _vnHidePassword = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    return Scaffold(
      backgroundColor: FitnessNcColors.blue50,
        body: Stack(children: <Widget>[
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
                      'Fitness Nc',
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
                              'Connectez-vous à votre compte',
                              style: GoogleFonts.robotoTextTheme().headline6!.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: TextFormField(
                                style: GoogleFonts.roboto(fontSize: 15),
                                decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintStyle: GoogleFonts.roboto(fontSize: 15),
                                    focusedBorder: defaultBorder,
                                    border: defaultBorder,
                                    enabledBorder: defaultBorder),
                                onChanged: (String value) => widget.bloc.email = value,
                                onFieldSubmitted: (String value) => onPressedEnter(),
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
                                  TextFormField(
                                    style: GoogleFonts.roboto(fontSize: 15),
                                    obscureText: _vnHidePassword.value,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        focusedBorder: defaultBorder,
                                        border: defaultBorder,
                                        enabledBorder: defaultBorder,
                                        hintStyle: GoogleFonts.roboto(fontSize: 15),
                                        suffixIcon: IconButton(
                                            tooltip: _vnHidePassword.value ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                                            onPressed: () => setState(() => _vnHidePassword.value = !_vnHidePassword.value),
                                            icon: ValueListenableBuilder<bool>(
                                              builder: (BuildContext context, bool value, Widget? child) {
                                                return value ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined);
                                              },
                                              valueListenable: _vnHidePassword,
                                            ))),
                                    onChanged: (String value) => widget.bloc.password = value,
                                    onFieldSubmitted: (_) => onPressedEnter(),
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
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                                onPressed: onPressedEnter,
                                child: Text(
                                  'Continuer',
                                  style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15),
                                ),
                              ),
                            ),
                            StreamBuilder<String?>(
                              stream: widget.bloc.errorsObservable,
                              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                                  return Text(snapshot.data!);
                                } else {
                                  return const Text('');
                                }
                              },
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
                            onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                            child: const Text(
                              "S'incrire",
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
      const BottomCu(),
    ]));
  }

  void onPressedEnter() {
    widget.bloc.cleanError();
    if (_formKey.currentState?.validate() == true) {
      widget.bloc.login().then((UserCredential value) {
        if (widget.callback != null) {
          widget.callback!(value);
        }
      }).catchError((Object? error) {
        widget.bloc.setError(error.toString());
      });
    }
  }
}

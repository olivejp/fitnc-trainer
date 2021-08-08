import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login/login.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottom.widget.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatefulWidget {
  final LoginBloc bloc = LoginBloc.getInstance();
  final CallbackUserCredential? callback;
  final String namePage;

  LoginPage({Key? key, this.namePage = '', this.callback}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('images/background.jpg'), fit: BoxFit.cover)),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fitness Nc',
            style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 50),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                color: Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: GoogleFonts.roboto(fontSize: 20),
                            decoration: InputDecoration(labelText: 'Email', hintStyle: GoogleFonts.roboto(fontSize: 20)),
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
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: GoogleFonts.roboto(fontSize: 20),
                            obscureText: showPassword,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintStyle: GoogleFonts.roboto(fontSize: 20),
                                suffixIcon:
                                    IconButton(onPressed: () => setState(() => showPassword = !showPassword), icon: Icon(Icons.remove_red_eye))),
                            onChanged: (value) => widget.bloc.password = value,
                            onFieldSubmitted: (value) => onPressedEnter(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton.extended(
                            onPressed: onPressedEnter,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            label: Text(
                              'Se connecter',
                              style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15),
                            ),
                          ),
                        ),
                        Wrap(
                          children: [
                            TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                                child: Text(
                                  'Créer un compte',
                                  style: TextStyle(color: Colors.black87),
                                )),
                            TextButton(onPressed: () => print('hello'), child: Text('Mot de passe oublié', style: TextStyle(color: Colors.black87))),
                          ],
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
            ),
          ),
        ],
      ),
      BottomCu(),
    ]));
  }

  void onPressedEnter() {
    widget.bloc.cleanError();
    if (_formKey.currentState?.validate() == true) {
      widget.bloc.login().then((value) {
        if (widget.callback != null) {
          widget.callback!(value);
        }
      }).catchError((error) {
        widget.bloc.setError(error.toString());
      });
    }
  }
}



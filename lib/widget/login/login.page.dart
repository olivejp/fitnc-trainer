import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login/login.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatefulWidget {
  final LoginBloc bloc = LoginBloc.getInstance();
  final CallbackUserCredential? callback;
  final String namePage;

  LoginPage({Key? key, this.namePage = '', this.callback}) : super(key: key);

  @override
  _LoginPageState createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _LoginPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(Colors.black87.value),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Fitness Nc',
                style: GoogleFonts.alfaSlabOne(
                    color: Color(Colors.amber.value), fontSize: 50),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Card(
                    color: Color(Colors.white70.value),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Wrap(
                          children: [
                            TextFormField(
                              style: GoogleFonts.roboto(fontSize: 20),
                              decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: GoogleFonts.roboto(fontSize: 20)),
                              enableSuggestions: true,
                              onChanged: (value) =>
                                  widget.bloc.changeEmail(value),
                              onFieldSubmitted: (value) => onPressedEnter(),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Merci de renseigner votre adresse email.';
                                }
                                if (!RegExp(
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                    .hasMatch(value)) {
                                  return "L'adresse mail n'est pas formattée correctement'.";
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            TextFormField(
                                style: GoogleFonts.roboto(fontSize: 20),
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    hintText: 'Mot de passe',
                                    hintStyle:
                                        GoogleFonts.roboto(fontSize: 20)),
                                onChanged: (value) =>
                                    widget.bloc.changePassword(value),
                                onFieldSubmitted: (value) => onPressedEnter()),
                            FloatingActionButton.extended(
                              onPressed: onPressedEnter,
                              label: Text(
                                'Se connecter',
                                style: GoogleFonts.roboto(
                                    color: Color(Colors.white.value),
                                    fontSize: 15),
                              ),
                            ),
                            StreamBuilder<String?>(
                              stream: widget.bloc.errorsObservable,
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data?.isNotEmpty == true) {
                                  return Text(snapshot.data!);
                                } else {
                                  return Text("");
                                }
                              },
                            ),
                          ],
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runSpacing: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

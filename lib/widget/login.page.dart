import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login.bloc.dart';
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
                    image: NetworkImage(
                        "https://s3.envato.com/files/189120872/0Q7A7108.jpg"),
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
              Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500, maxHeight: 250),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        GoogleFonts.roboto(fontSize: 20)),
                                onChanged: (value) =>
                                    widget.bloc.changeEmail(value),
                                onSubmitted: (value) => onPressedEnter(),
                              ),
                              TextField(
                                obscureText: true,
                                enableSuggestions: false,
                                decoration: InputDecoration(
                                    hintText: 'Mot de passe',
                                    hintStyle:
                                        GoogleFonts.roboto(fontSize: 20)),
                                onChanged: (value) =>
                                    widget.bloc.changePassword(value),
                                onSubmitted: (value) => onPressedEnter()
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 30),
                                  child: FloatingActionButton.extended(
                                    onPressed: onPressedEnter,
                                    label: Text(
                                      'Se connecter',
                                      style: GoogleFonts.roboto(
                                          color: Color(Colors.white.value),
                                          fontSize: 15),
                                    ),
                                  )),
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
                          ),
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
        print('Test validé');
        if (widget.callback != null) {
          widget.callback!(value);
        }
      }).catchError((error) {
        print('Test échoué');
        widget.bloc.setError(error.toString());
      });
    }
  }
}

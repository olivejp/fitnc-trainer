import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login.bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatefulWidget {
  final LoginBloc bloc = LoginBloc.getInstance();
  final CallbackUserCredential callback;
  final String namePage;

  LoginPage({Key key, this.namePage, this.callback}) : super(key: key);

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
        body: Form(
      key: _formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: 200),
          child: Card(
            shadowColor: Color(Colors.deepPurple.shade900.value),
            elevation: 3.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Email'),
                    validator: (String value) {
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
                    onChanged: (value) => widget.bloc.changeEmail(value),
                  ),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(hintText: 'Mot de passe'),
                    onChanged: (value) => widget.bloc.changePassword(value),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.bloc.cleanError();
                        if (_formKey.currentState.validate()) {
                          widget.bloc.login().then((value) {
                            print('Test validé');
                            if (widget.callback != null) {
                              widget.callback(value);
                            }
                          }).catchError((error) {
                            print('Test échoué');
                            widget.bloc.setError(error.toString());
                          });
                        }
                      },
                      child: Text('Se connecter'),
                    ),
                  ),
                  StreamBuilder<String>(
                    stream: widget.bloc.errorsObservable,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.isNotEmpty) {
                        return Text(snapshot.data);
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
    ));
  }
}

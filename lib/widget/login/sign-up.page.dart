import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login/sign-up.bloc.dart';
import 'package:fitnc_trainer/widget/bottom.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.namePage = '', this.callback}) : super(key: key);

  final SignUpBloc bloc = SignUpBloc.getInstance();
  final CallbackUserCredential? callback;
  final String namePage;

  @override
  _SignUpPageState createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  _SignUpPageState();

  final BehaviorSubject<bool> subjPasswordObscure = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<bool> subjPasswordCheckObscure = BehaviorSubject<bool>.seeded(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GenericContainerWidget(
            child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Fitness Nc',
                  style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 50),
                ),
                Card(
                  color: Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: TextFormField(
                                        decoration: const InputDecoration(labelText: 'Nom', helperText: 'Champ obligatoire'),
                                        onChanged: (String value) => widget.bloc.nom = value,
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
                                        decoration: const InputDecoration(labelText: 'Prénom', helperText: 'Champ obligatoire'),
                                        onChanged: (String value) => widget.bloc.prenom = value,
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
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(suffixIcon: Icon(Icons.email), labelText: 'Email', helperText: 'Champ obligatoire'),
                              onChanged: (String value) => widget.bloc.email = value,
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
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onChanged: (String value) => widget.bloc.telephone = value,
                              decoration: const InputDecoration(suffixIcon: Icon(Icons.phone_android), labelText: 'Téléphone'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamBuilder<bool>(
                              stream: subjPasswordObscure,
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                if (snapshot.hasData) {
                                  return TextFormField(
                                      onChanged: (String value) => widget.bloc.password = value,
                                      obscureText: snapshot.data!,
                                      decoration: InputDecoration(
                                          labelText: 'Mot de passe',
                                          suffixIcon: IconButton(
                                              onPressed: () => {
                                                    if (subjPasswordObscure.hasValue)
                                                      {subjPasswordObscure.sink.add(!subjPasswordObscure.valueOrNull!)}
                                                  },
                                              icon: const Icon(Icons.remove_red_eye))),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Le mot de passe ne peut pas être vide.';
                                        }
                                      });
                                }
                                return Container();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamBuilder<bool>(
                              stream: subjPasswordCheckObscure,
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                if (snapshot.hasData) {
                                  return TextFormField(
                                      onChanged: (String value) => widget.bloc.passwordCheck = value,
                                      obscureText: snapshot.data!,
                                      decoration: InputDecoration(
                                          labelText: 'Retaper votre mot de passe',
                                          suffixIcon: IconButton(
                                              onPressed: () => {
                                                    if (subjPasswordCheckObscure.hasValue)
                                                      {subjPasswordCheckObscure.sink.add(!subjPasswordCheckObscure.valueOrNull!)}
                                                  },
                                              icon: const Icon(Icons.remove_red_eye))),
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Le mot de passe ne peut pas être vide.';
                                        }
                                        if (widget.bloc.password != widget.bloc.passwordCheck) {
                                          return "Le mot de passe n'est pas identique.";
                                        }
                                      });
                                }
                                return Container();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton.extended(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onPressed: () => onPressedEnter(),
                                label: const Text('Créer un compte')),
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
                )
              ],
            ),
          ),
        )),
        BottomCu()
      ]),
    );
  }

  void onPressedEnter() {
    widget.bloc.cleanError();
    if (_formKey.currentState?.validate() == true) {
      widget.bloc.signUp().then((UserCredential value) {
        if (widget.callback != null) {
          widget.callback!(value);
        }
      }).catchError((Object? error) {
        widget.bloc.setError(error.toString());
      });
    }
  }
}

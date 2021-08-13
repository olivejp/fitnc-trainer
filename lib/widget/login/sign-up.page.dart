import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/bloc/login/sign-up.bloc.dart';
import 'package:fitnc_trainer/widget/bottom.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.callback}) : super(key: key);

  final SignUpBloc bloc = SignUpBloc.instance();
  final CallbackUserCredential? callback;

  @override
  _SignUpPageState createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  _SignUpPageState();

  final ValueNotifier<bool> _vnHidePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _vnHideSecondPassword = ValueNotifier<bool>(true);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showPassword = true;

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
              'Fitness Nc',
              style: GoogleFonts.alfaSlabOne(color: Theme.of(context).primaryColor, fontSize: 25),
            ),
          ),
        ),
      ],
    );
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
                            style: GoogleFonts.robotoTextTheme().headline6!.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
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
                                        style: GoogleFonts.roboto(fontSize: 15),
                                        decoration: InputDecoration(
                                          labelText: 'Prénom',
                                          focusedBorder: defaultBorder,
                                          border: defaultBorder,
                                          enabledBorder: defaultBorder,
                                        ),
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
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              style: GoogleFonts.roboto(fontSize: 15),
                              onChanged: (String value) => widget.bloc.telephone = value,
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
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _vnHidePassword,
                              builder: (BuildContext context, bool hidePassword, Widget? child) => TextFormField(
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  onChanged: (String value) => widget.bloc.password = value,
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      focusedBorder: defaultBorder,
                                      border: defaultBorder,
                                      enabledBorder: defaultBorder,
                                      suffixIcon: IconButton(
                                        tooltip: hidePassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                                        onPressed: () => _vnHidePassword.value = !_vnHidePassword.value,
                                        icon: hidePassword ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined),
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
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _vnHideSecondPassword,
                              builder: (BuildContext context, bool hidePassword, Widget? child) => TextFormField(
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  onChanged: (String value) => widget.bloc.passwordCheck = value,
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                      focusedBorder: defaultBorder,
                                      border: defaultBorder,
                                      enabledBorder: defaultBorder,
                                      labelText: 'Retaper votre mot de passe',
                                      suffixIcon: IconButton(
                                          tooltip: hidePassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                                          onPressed: () => _vnHideSecondPassword.value = !_vnHideSecondPassword.value,
                                          icon: hidePassword ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined))),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le mot de passe ne peut pas être vide.';
                                    }
                                    if (widget.bloc.password != widget.bloc.passwordCheck) {
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
                                child: Text('Créer un compte', style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15)),
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
        ),
      ],
    );

    return Scaffold(
      backgroundColor: FitnessNcColors.blue50,
      body: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()
              ..translate(MediaQuery.of(context).size.width)
              ..add(Matrix4.skewX(-0.3)),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.amber.withAlpha(100), Colors.amber.shade700])),
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
                      begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.amber.withAlpha(100), Colors.amber.shade700])),
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              Widget toShow;
              if (constraints.maxWidth > 900) {
                toShow = Row(
                  children: <Widget>[
                    Expanded(child: columnLeft),
                    Expanded(child: columnRight),
                  ],
                );
              } else {
                toShow = columnRight;
              }
              return Stack(children: <Widget>[toShow, const BottomCu()]);
            },
          )
        ],
      ),
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

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/abonne/abonne_update.bloc.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AbonneUpdatePage extends StatefulWidget {
  final AbonneUpdateBloc bloc = AbonneUpdateBloc.getInstance();

  final double containerHeight = 110;

  AbonneUpdatePage({Key? key, Abonne? abonne}) : super(key: key) {
    bloc.init(abonne);
  }

  @override
  _AbonneUpdatePageState createState() {
    return new _AbonneUpdatePageState();
  }
}

class _AbonneUpdatePageState extends State<AbonneUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _AbonneUpdatePageState();

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.bloc.abonne.uid != null ? '${widget.bloc.abonne.nom!} ${widget.bloc.abonne.prenom!}' : 'Nouveau abonné';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(appBarTitle, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 30)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: Theme.of(context).appBarTheme.iconTheme?.size,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GenericUpdateWidget(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreamBuilder<Uint8List?>(
                      stream: widget.bloc.selectedImageObs,
                      builder: (context, snapshot) {
                        ImageProvider? provider;
                        if (snapshot.hasData && snapshot.data != null) {
                          provider = MemoryImage(snapshot.data!);
                        }

                        return InkWell(
                          child: CircleAvatar(
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(Colors.white.value),
                              ),
                              radius: 50,
                              foregroundImage: provider,
                              backgroundColor: Theme.of(context).primaryColor),
                          onTap: callPhotoPicker,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        );
                      }),
                  IconButton(
                      tooltip: 'Supprimer la photo',
                      onPressed: () => deletePhoto(),
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(helperText: 'Genre'),
                            icon: Icon(Icons.transgender_rounded),
                            onChanged: (String? value) => widget.bloc.abonne.sexe = value,
                            value: widget.bloc.abonne.sexe,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le genre de l\'abonné';
                              }
                              return null;
                            },
                            items: [
                              DropdownMenuItem(
                                child: Text('Homme'),
                                value: 'Homme',
                              ),
                              DropdownMenuItem(
                                child: Text('Femme'),
                                value: 'Femme',
                              ),
                            ]),
                      ),
                      flex: 1,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextFormField(
                            initialValue: widget.bloc.abonne.nom,
                            autofocus: true,
                            onChanged: (value) => widget.bloc.abonne.nom = value,
                            decoration: InputDecoration(helperText: 'Nom'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le nom du abonne.';
                              }
                              return null;
                            }),
                      ),
                      flex: 1,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            initialValue: widget.bloc.abonne.prenom,
                            onChanged: (value) => widget.bloc.changePrenom(value),
                            decoration: InputDecoration(helperText: 'Prénom'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le prénom de l\'abonné.';
                              }
                              return null;
                            }),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          maxLength: 10,
                          initialValue: widget.bloc.abonne.dateNaissance,
                          onChanged: widget.bloc.changeDateNaissance,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value?.length != null && value!.length >= 8) {
                              DateTime time;
                              DateTime today = DateTime.now();
                              try {
                                time = DateFormat('dd/MM/yyyy').parseStrict(value);
                              } on Exception {
                                return 'Date incorrecte. Format accepté dd/mm/aaaa.';
                              }
                              if (time.isAfter(today)) {
                                return 'Date supérieure à la date du jour';
                              }
                              return null;
                            }
                          },
                          decoration: InputDecoration(suffixIcon: Icon(Icons.event_note), hintText: 'dd/mm/aaaa', helperText: 'Date de naissance'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          initialValue: widget.bloc.abonne.email,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: widget.bloc.changeEmail,
                          decoration: InputDecoration(helperText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Merci de renseigner l\'email de l\abonné.';
                            }
                            return null;
                          }),
                    ),
                    flex: 1,
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: TextFormField(
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        initialValue: (widget.bloc.abonne.telephone1) != null ? widget.bloc.abonne.telephone1.toString() : '',
                        onChanged: (value) => widget.bloc.abonne.telephone1 = int.tryParse(value),
                        decoration: InputDecoration(helperText: 'Téléphone fixe'),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: TextFormField(
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        initialValue: (widget.bloc.abonne.telephone2) != null ? widget.bloc.abonne.telephone2.toString() : '',
                        onChanged: (value) => widget.bloc.abonne.telephone2 = int.tryParse(value),
                        decoration: InputDecoration(helperText: 'Téléphone mobile'),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.bloc.abonne.adresse1,
                  onChanged: (value) => widget.bloc.abonne.adresse1 = value,
                  decoration: InputDecoration(alignLabelWithHint: true, helperText: 'Adresse ligne 1'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.bloc.abonne.adresse2,
                  onChanged: (value) => widget.bloc.abonne.adresse2 = value,
                  decoration: InputDecoration(alignLabelWithHint: true, helperText: 'Adresse ligne 2'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.bloc.abonne.adresse3,
                  onChanged: (value) => widget.bloc.abonne.adresse3 = value,
                  decoration: InputDecoration(alignLabelWithHint: true, helperText: 'Adresse ligne 3'),
                ),
              ]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.bloc.saveAbonne().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void deletePhoto() {
    widget.bloc.setImage(null, null);
  }

  void callPhotoPicker() {
    FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'gif']).then((result) {
      if (result != null) {
        widget.bloc.setImage(result.files.first.bytes, result.files.first.name);
      }
    });
  }
}

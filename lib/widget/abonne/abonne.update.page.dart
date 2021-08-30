import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/abonne/abonne_update.vm.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AbonneUpdatePage extends StatefulWidget {
  const AbonneUpdatePage({Key? key, this.abonne}) : super(key: key);

  final Abonne? abonne;

  @override
  _AbonneUpdatePageState createState() {
    return _AbonneUpdatePageState();
  }
}

class _AbonneUpdatePageState extends State<AbonneUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double containerHeight = 110;

  @override
  Widget build(BuildContext context) {
    final AbonneUpdateVm vm = Provider.of<AbonneUpdateVm>(context);

    void deletePhoto() {
      vm.setImage(null, null);
    }

    void callPhotoPicker() {
      FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: [
        'jpg',
        'png',
        'gif'
      ]).then((FilePickerResult? result) {
        if (result != null) {
          vm.setImage(result.files.first.bytes, result.files.first.name);
        }
      });
    }

    vm.init(widget.abonne);
    final String appBarTitle =
        vm.abonne.uid != null ? '${vm.nom!} ${vm.prenom!}' : 'Nouveau abonné';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(appBarTitle,
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle
                ?.copyWith(fontSize: 30)),
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
                      stream: vm.selectedImageObs,
                      builder: (BuildContext context,
                          AsyncSnapshot<Uint8List?> snapshot) {
                        ImageProvider? provider;
                        if (snapshot.hasData && snapshot.data != null) {
                          provider = MemoryImage(snapshot.data!);
                        }

                        return InkWell(
                          onTap: callPhotoPicker,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          child: CircleAvatar(
                              radius: 50,
                              foregroundImage: provider,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.add_photo_alternate,
                                color: Color(Colors.white.value),
                              )),
                        );
                      }),
                  IconButton(
                      tooltip: 'Supprimer la photo',
                      onPressed: () => deletePhoto(),
                      icon: const Icon(
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
                            decoration:
                                const InputDecoration(labelText: 'Genre'),
                            icon: const Icon(Icons.transgender_rounded),
                            onChanged: (String? value) => vm.sexe = value,
                            value: vm.sexe,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Merci de renseigner le genre de l'abonné";
                              }
                              return null;
                            },
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem<String>(
                                value: 'Homme',
                                child: Text('Homme'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Femme',
                                child: Text('Femme'),
                              ),
                            ]),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextFormField(
                            initialValue: vm.nom,
                            autofocus: true,
                            onChanged: (String value) => vm.nom = value,
                            decoration: const InputDecoration(labelText: 'Nom'),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le nom du abonne.';
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: vm.prenom,
                            onChanged: (String? value) => vm.prenom = value,
                            decoration:
                                const InputDecoration(labelText: 'Prénom'),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Merci de renseigner le prénom de l'abonné.";
                              }
                              return null;
                            }),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          maxLength: 10,
                          initialValue: vm.dateNaissance,
                          onChanged: (String? value) =>
                              vm.dateNaissance = value,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (String? value) {
                            if (value?.length != null && value!.length >= 8) {
                              DateTime time;
                              final DateTime today = DateTime.now();
                              try {
                                time =
                                    DateFormat('dd/MM/yyyy').parseStrict(value);
                              } on Exception {
                                return 'Date incorrecte. Format accepté dd/mm/aaaa.';
                              }
                              if (time.isAfter(today)) {
                                return 'Date supérieure à la date du jour';
                              }
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.event_note),
                              hintText: 'dd/mm/aaaa',
                              labelText: 'Date de naissance'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          initialValue: vm.email,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (String? value) => vm.email = value,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Merci de renseigner l'email de l'abonné.";
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
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: (vm.telephone1) != null
                            ? vm.telephone1.toString()
                            : '',
                        onChanged: (String value) =>
                            vm.telephone1 = int.tryParse(value),
                        decoration:
                            const InputDecoration(labelText: 'Téléphone fixe'),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: (vm.telephone2) != null
                            ? vm.telephone2.toString()
                            : '',
                        onChanged: (value) =>
                            vm.telephone2 = int.tryParse(value),
                        decoration:
                            InputDecoration(labelText: 'Téléphone mobile'),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                TextFormField(
                  maxLength: 50,
                  initialValue: vm.adresse1,
                  onChanged: (String value) => vm.adresse1 = value,
                  decoration: const InputDecoration(
                      alignLabelWithHint: true, labelText: 'Adresse ligne 1'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: vm.adresse2,
                  onChanged: (String value) => vm.adresse2 = value,
                  decoration: const InputDecoration(
                      alignLabelWithHint: true, labelText: 'Adresse ligne 2'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: vm.adresse3,
                  onChanged: (String value) => vm.adresse3 = value,
                  decoration: const InputDecoration(
                      alignLabelWithHint: true, labelText: 'Adresse ligne 3'),
                ),
              ]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            vm
                .saveAbonne()
                .then((value) async => Navigator.pop(context))
                .catchError((error) async => print(error.toString()));
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

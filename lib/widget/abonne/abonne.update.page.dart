import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/controller/abonne/abonne_update.vm.dart';
import 'package:fitnc_trainer/widget/widgets/generic_update.widget.dart';
import 'package:fitness_domain/domain/abonne.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AbonneUpdatePage extends StatefulWidget {
  AbonneUpdatePage({Key? key, this.abonne}) : super(key: key);

  final AbonneUpdateController controller = Get.put(AbonneUpdateController());
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
    void deletePhoto() {
      widget.controller.setImage(null, null);
    }

    void callPhotoPicker() {
      FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'gif']).then((FilePickerResult? result) {
        if (result != null) {
          widget.controller.setImage(result.files.first.bytes, result.files.first.name);
        }
      });
    }

    widget.controller.init(widget.abonne);
    final String appBarTitle = widget.controller.abonne.uid != null ? '${widget.controller.nom!} ${widget.controller.prenom!}' : 'Nouveau abonné';
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
                      stream: widget.controller.selectedImageObs,
                      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                        ImageProvider? provider;
                        if (snapshot.hasData && snapshot.data != null) {
                          provider = MemoryImage(snapshot.data!);
                        }

                        return InkWell(
                          onTap: callPhotoPicker,
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
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
                            decoration: const InputDecoration(labelText: 'Genre'),
                            icon: const Icon(Icons.transgender_rounded),
                            onChanged: (String? value) => widget.controller.sexe = value,
                            value: widget.controller.sexe,
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
                            initialValue: widget.controller.nom,
                            autofocus: true,
                            onChanged: (String value) => widget.controller.nom = value,
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            initialValue: widget.controller.prenom,
                            onChanged: (String? value) => widget.controller.prenom = value,
                            decoration: const InputDecoration(labelText: 'Prénom'),
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
                          initialValue: widget.controller.dateNaissance,
                          onChanged: (String? value) => widget.controller.dateNaissance = value,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (String? value) {
                            if (value?.length != null && value!.length >= 8) {
                              DateTime time;
                              final DateTime today = DateTime.now();
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
                          decoration:
                              const InputDecoration(suffixIcon: Icon(Icons.event_note), hintText: 'dd/mm/aaaa', labelText: 'Date de naissance'),
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
                          initialValue: widget.controller.email,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (String? value) => widget.controller.email = value,
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        initialValue: (widget.controller.telephone1) != null ? widget.controller.telephone1.toString() : '',
                        onChanged: (String value) => widget.controller.telephone1 = int.tryParse(value),
                        decoration: const InputDecoration(labelText: 'Téléphone fixe'),
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
                        initialValue: (widget.controller.telephone2) != null ? widget.controller.telephone2.toString() : '',
                        onChanged: (value) => widget.controller.telephone2 = int.tryParse(value),
                        decoration: InputDecoration(labelText: 'Téléphone mobile'),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.controller.adresse1,
                  onChanged: (String value) => widget.controller.adresse1 = value,
                  decoration: const InputDecoration(alignLabelWithHint: true, labelText: 'Adresse ligne 1'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.controller.adresse2,
                  onChanged: (String value) => widget.controller.adresse2 = value,
                  decoration: const InputDecoration(alignLabelWithHint: true, labelText: 'Adresse ligne 2'),
                ),
                TextFormField(
                  maxLength: 50,
                  initialValue: widget.controller.adresse3,
                  onChanged: (String value) => widget.controller.adresse3 = value,
                  decoration: const InputDecoration(alignLabelWithHint: true, labelText: 'Adresse ligne 3'),
                ),
              ]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.controller.saveAbonne().then((value) async => Navigator.pop(context)).catchError((error) async => print(error.toString()));
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExerciceUpdatePage extends StatefulWidget {
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();

  final double containerHeight = 240;

  ExerciceUpdatePage({Key? key, Exercice? exercice}) : super(key: key) {
    bloc.init(exercice);
  }

  @override
  _ExerciceUpdatePageState createState() {
    return new _ExerciceUpdatePageState();
  }
}

class _ExerciceUpdatePageState extends State<ExerciceUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _ExerciceUpdatePageState();

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.bloc.getExercice()?.uid != null
        ? widget.bloc.getExercice()!.name
        : 'Nouveau exercice';
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.bloc
                  .saveExercice()
                  .then((value) => Navigator.pop(context))
                  .catchError((error) => print(error.toString()));
            }
          },
          child: Icon(Icons.check),
        ),
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
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://s3.envato.com/files/189120872/0Q7A7108.jpg"),
                  fit: BoxFit.cover)),
          child: getFirstPanel(),
        ));
  }

  LayoutBuilder getFirstPanel() {
    return LayoutBuilder(builder: (context, constraints) {
      double leftAndRightPadding = 5;
      double topAndBottomPadding = 5;

      if (constraints.maxWidth > 600) {
        leftAndRightPadding = 10;
        topAndBottomPadding = 10;
      }

      if (constraints.maxWidth > 800) {
        leftAndRightPadding = 25;
        topAndBottomPadding = 25;
      }

      if (constraints.maxWidth > 1200) {
        leftAndRightPadding = 50;
        topAndBottomPadding = 50;
      }

      return Padding(
        padding: EdgeInsets.only(
            left: leftAndRightPadding,
            right: leftAndRightPadding,
            top: topAndBottomPadding,
            bottom: topAndBottomPadding),
        child: Card(
          shadowColor: Color(Colors.black.value),
          clipBehavior: Clip.antiAlias,
          color: Color(Colors.white.value).withOpacity(0.85),
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamBuilder<Uint8List?>(
                              stream: widget.bloc.selectedImageObs,
                              builder: (context, snapshot) {
                                ImageProvider? provider;
                                if (snapshot.hasData &&
                                    snapshot.data != null) {
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
                                      backgroundColor:
                                          Color(Colors.amber.value)),
                                  onTap: callPhotoPicker,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                );
                              }),
                          IconButton(
                              tooltip: 'Supprimer la photo',
                              onPressed: () => deletePhoto(),
                              icon: Icon(
                                Icons.delete,
                                color: Color(Colors.amber.value),
                              )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: TextFormField(
                                  initialValue:
                                      widget.bloc.getExercice()?.name,
                                  autofocus: true,
                                  onChanged: (value) =>
                                      widget.bloc.changeName(value),
                                  decoration:
                                      InputDecoration(helperText: 'Nom'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Merci de renseigner le nom du exercice.';
                                    }
                                    return null;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: widget.bloc.getExercice()?.description,
                        maxLength: 2000,
                        minLines: 5,
                        maxLines: 20,
                        onChanged: (value) =>
                            widget.bloc.changeDescription(value),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            helperText: 'Description (optionel)'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void deletePhoto() {
    widget.bloc.setImage(null, null);
  }

  void callPhotoPicker() {
    FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'gif']).then((result) {
      if (result != null) {
        widget.bloc.setImage(result.files.first.bytes, result.files.first.name);
      }
    });
  }
}

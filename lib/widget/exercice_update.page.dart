import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fitnc_trainer/bloc/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/generic_update.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;

  _ExerciceUpdatePageState();

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.bloc.getExercice()?.uid != null ? widget.bloc.getExercice()!.name : 'Nouveau exercice';
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.bloc.saveExercice().then((value) => Navigator.pop(context)).catchError((error) => print(error.toString()));
            }
          },
          child: Icon(Icons.check),
        ),
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
        body: GenericContainerWidget(child: getFirstPanel()));
  }

  Widget getFirstPanel() {
    return GenericUpdateWidget(
      child: getMainColumn(),
    );
  }

  Widget getMainColumn() {
    return Form(
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
                          backgroundColor: Color(Colors.amber.value)),
                      onTap: callPhotoPicker,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
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
                      initialValue: widget.bloc.getExercice()?.name,
                      autofocus: true,
                      onChanged: (value) => widget.bloc.changeName(value),
                      decoration: InputDecoration(helperText: 'Nom'),
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
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: TextFormField(
              initialValue: widget.bloc.getExercice()?.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (value) => widget.bloc.changeDescription(value),
              decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Description (optionel)'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<dynamic>(
                    future: widget.bloc.paramService.getParamAsDropdown('type_exercice'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                            icon: Icon(Icons.track_changes),
                            onChanged: (String? value) => widget.bloc.exercice.typeExercice = value,
                            value: widget.bloc.exercice.typeExercice,
                            items: snapshot.data);
                      }
                      return Container();
                    }),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.bloc.exercice.videoUrl,
                  onChanged: (value) => widget.bloc.setVideoUrl(value),
                  decoration: InputDecoration(helperText: 'URL de la vidéo - Optionnel'),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.bloc.exercice.youtubeUrl,
                  onChanged: (value) {
                    widget.bloc.setYoutubeUrl(value);
                  },
                  decoration: InputDecoration(helperText: 'URL d\'une vidéo Youtube - Optionnel'),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<String?>(
                stream: widget.bloc.selectedVideoUrlObs,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _videoController = VideoPlayerController.network(snapshot.data!);
                    return FutureBuilder(
                      builder: (context, snapshot) {
                        if (_videoController?.value.isInitialized == true) {
                          return LimitedBox(
                            maxWidth: 500,
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                      future: _videoController!.initialize(),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<String?>(
                stream: widget.bloc.selectedYoutubeUrlObs,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _youtubeController = YoutubePlayerController(initialVideoId: snapshot.data!);
                    return LimitedBox(
                      maxWidth: 500,
                      child: YoutubePlayerIFrame(
                        controller: _youtubeController,
                        aspectRatio: 16 / 9,
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ],
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

import 'package:fitnc_trainer/bloc/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/widget/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/generic_update.widget.dart';
import 'package:fitnc_trainer/widget/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'firestore_param_dropdown.widget.dart';

class ExerciceUpdatePage extends StatefulWidget {
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();

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
    String appBarTitle = widget.bloc.exercice.uid != null ? widget.bloc.exercice.name : 'Nouveau exercice';
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
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StorageImageWidget(
                  onSaved: (storagePair) => widget.bloc.setStoragePair(storagePair),
                  streamInitialStoragePair: widget.bloc.obsStoragePair,
                  onDeleted: (storagePair) => widget.bloc.setStoragePair(null),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextFormField(
                        initialValue: widget.bloc.exercice.name,
                        autofocus: true,
                        onChanged: (value) => widget.bloc.setName(value),
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
          ),
          TextFormField(
            initialValue: widget.bloc.exercice.description,
            maxLength: 2000,
            minLines: 5,
            maxLines: 20,
            onChanged: (value) => widget.bloc.setDescription(value),
            decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Description (optionel)'),
          ),
          Row(
            children: [
              Expanded(
                  child: ParamDropdownButton(
                paramName: 'type_exercice',
                initialValue: widget.bloc.exercice.typeExercice,
                onChanged: (onChangedValue) => widget.bloc.exercice.typeExercice = onChangedValue,
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.bloc.exercice.videoUrl,
                  onChanged: (value) => widget.bloc.setVideoUrl(value),
                  decoration: InputDecoration(helperText: 'URL de la vidéo - Exemple : https://myStorage.com/squat_video.mp4'),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.bloc.exercice.youtubeUrl,
                  onChanged: (value) => widget.bloc.setYoutubeUrl(value),
                  decoration: InputDecoration(helperText: 'Identifiant vidéo Youtube - Exemple : v-7oKGvVADk'),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vous pouvez joindre ici un vidéo au format MP4, si celle ci est directement accessible depuis internet. Exemple : https://firebasestorage.googleapis.com/v0/b/fitnc-7be2e.appspot.com/o/YZBEpGXXvI.mp4',
                  maxLines: 5,
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
                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    _youtubeController = YoutubePlayerController(
                      initialVideoId: snapshot.data!,
                      params: YoutubePlayerParams(
                        autoPlay: false,
                        showControls: true,
                        showFullscreenButton: true,
                      ),
                    );
                    _youtubeController!.pause();
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

  FutureBuilder<dynamic> getDropdown(String paramName, dynamic initialValue) {
    return FutureBuilder<dynamic>(
        future: widget.bloc.paramService.getParamAsDropdown(paramName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<String>(
                icon: Icon(Icons.track_changes),
                onChanged: (String? value) => widget.bloc.exercice.typeExercice = value,
                value: initialValue,
                items: snapshot.data);
          }
          return Container();
        });
  }
}

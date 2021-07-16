import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExerciceFormBuilder {
  static Widget getForm(GlobalKey<FormState> _formKey, ExerciceUpdateBloc bloc) {
    VideoPlayerController? _videoController;
    YoutubePlayerController? _youtubeController;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 800),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StorageStreamImageWidget(
                    onSaved: (storagePair) => bloc.setStoragePair(storagePair),
                    streamInitialStoragePair: bloc.obsStoragePair,
                    onDeleted: (storagePair) => bloc.setStoragePair(null),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                          initialValue: bloc.exercice.name,
                          autofocus: true,
                          onChanged: (value) => bloc.setName(value),
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
            Row(
              children: [
                Expanded(
                    child: ParamDropdownButton(
                  hint: Text('Type d\'exercice', style: TextStyle(fontStyle: FontStyle.italic)),
                  paramName: 'type_exercice',
                  initialValue: bloc.exercice.typeExercice,
                  onChanged: (onChangedValue) => bloc.exercice.typeExercice = onChangedValue,
                ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: bloc.exercice.description,
                maxLength: 2000,
                minLines: 5,
                maxLines: 20,
                onChanged: (value) => bloc.setDescription(value),
                decoration: InputDecoration(border: OutlineInputBorder(), alignLabelWithHint: true, helperText: 'Description (optionel)'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: bloc.exercice.videoUrl,
                    onChanged: (value) => bloc.setVideoUrl(value),
                    decoration: InputDecoration(helperText: 'URL de la vidéo - Exemple : https://myStorage.com/squat_video.mp4'),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: bloc.exercice.youtubeUrl,
                    onChanged: (value) => bloc.setYoutubeUrl(value),
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
                  stream: bloc.selectedVideoUrlObs,
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
                  stream: bloc.selectedYoutubeUrlObs,
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
      ),
    );
  }
}

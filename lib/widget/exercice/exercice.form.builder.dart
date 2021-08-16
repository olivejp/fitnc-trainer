import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExerciceBuilderPage {
  /// Permet de créer une AlertDialog pour la création d'un exercice.
  static void create(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
            title: Text("Création de l'exercice"),
            content: ExerciceGeneric(isCreation: true)));
  }

  /// Permet de créer une AlertDialog pour la mise à jour d'un exercice.
  static void update(
      {required BuildContext context, required Exercice exercice}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text("Mise à jour d'un exercice"),
            content: ExerciceGeneric(
              isCreation: false,
              exercice: exercice,
            )));
  }
}

/// Composant générique pour l'exercice (Mise à jour / Création).
class ExerciceGeneric extends StatefulWidget {
  const ExerciceGeneric({Key? key, required this.isCreation, this.exercice})
      : super(key: key);

  final bool isCreation;
  final Exercice? exercice;

  @override
  State<ExerciceGeneric> createState() => _ExerciceGenericState();
}

class _ExerciceGenericState extends State<ExerciceGeneric> {
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();

  late VideoPlayerController? _videoController;
  late YoutubePlayerController? _youtubeController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bloc.init(widget.exercice);

    final Widget saveButton = ElevatedButton.icon(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            bloc.saveExercice().then((_) {
              showToast(
                  widget.isCreation ? 'Exercice créé' : 'Exercice mis à jour',
                  backgroundColor: Colors.green);

              if (widget.isCreation) {
                Navigator.of(context).pop();
              }
            }).catchError((_) => showToast("Erreur lors de la sauvegarde",
                backgroundColor: Colors.redAccent));
          }
        },
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Créer', style: TextStyle(color: Colors.white)));

    final Widget closeButton = ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white),
        label: const Text('Fermer', style: TextStyle(color: Colors.white)));

    final List<Widget> buttons = <Widget>[saveButton, closeButton];

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: buttons,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    StorageStreamImageWidget(
                      onSaved: (StorageFile? storagePair) =>
                          bloc.setStoragePair(storagePair),
                      streamInitialStorageFile: bloc.obsStoragePair,
                      onDeleted: (StorageFile? storagePair) =>
                          bloc.setStoragePair(null),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: FitnessDecorationTextFormField(
                            initialValue: bloc.name,
                            autofocus: true,
                            onChanged: (String value) => bloc.name = value,
                            labelText: 'Nom',
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Merci de renseigner le nom du exercice.';
                              }
                              return null;
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: ParamDropdownButton(
                decoration: const InputDecoration(
                    labelText: "Type d'exercice",
                    constraints: BoxConstraints(
                        maxHeight: FitnessConstants.textFormFieldHeight),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                paramName: 'type_exercice',
                initialValue: bloc.typeExercice,
                onChanged: (String? onChangedValue) =>
                    bloc.typeExercice = onChangedValue,
              ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              initialValue: bloc.description,
              maxLength: 2000,
              minLines: 5,
              maxLines: 20,
              onChanged: (String value) => bloc.description = value,
              decoration: const InputDecoration(
                  labelText: 'Description', helperText: 'Optionnel'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: FitnessDecorationTextFormField(
                      initialValue: bloc.videoUrl,
                      onChanged: (String value) => bloc.videoUrl = value,
                      labelText: 'URL vidéo',
                      hintText:
                          'Exemple : https://myStorage.com/squat_video.mp4',
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: FitnessDecorationTextFormField(
                      initialValue: bloc.youtubeUrl,
                      onChanged: (String value) => bloc.youtubeUrl = value,
                      hintText: 'Identifiant vidéo Youtube',
                      labelText: 'Youtube',
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            children: const <Widget>[
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
            children: <Widget>[
              StreamBuilder<String?>(
                stream: bloc.selectedVideoUrlObs,
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    _videoController =
                        VideoPlayerController.network(snapshot.data!);
                    return FutureBuilder<Object?>(
                      builder: (BuildContext context,
                          AsyncSnapshot<Object?> snapshot) {
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
            children: <Widget>[
              StreamBuilder<String?>(
                stream: bloc.selectedYoutubeUrlObs,
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    _youtubeController = YoutubePlayerController(
                      initialVideoId: snapshot.data!,
                      params: const YoutubePlayerParams(
                        autoPlay: false,
                        showFullscreenButton: true,
                      ),
                    );
                    _youtubeController!.pause();
                    return LimitedBox(
                      maxWidth: 500,
                      child: YoutubePlayerIFrame(
                        controller: _youtubeController,
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
}

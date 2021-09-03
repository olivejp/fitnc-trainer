import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/exercice.update.controller.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constants/constants.dart';

class ExerciceBuilderPage {
  /// Permet de créer une AlertDialog pour la création d'un exercice.
  static void create(BuildContext context) {
    showDialog(
        context: context, builder: (BuildContext context) => AlertDialog(title: const Text("Création d'un exercice"), content: ExerciceCreate()));
  }

  /// Permet de créer une AlertDialog pour la mise à jour d'un exercice.
  static void update({required BuildContext context, required Exercice exercice}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Mise à jour'),
            content: ExerciceUpdate(
              exercice: exercice,
            )));
  }
}

/// Composant Création
class ExerciceCreate extends StatefulWidget {
  ExerciceCreate({Key? key, this.isCreation = true, this.displayCloseButton = true}) : super(key: key);

  final bool isCreation;
  final bool displayCloseButton;

  @override
  State<ExerciceCreate> createState() => _ExerciceCreateState();
}

class _ExerciceCreateState extends State<ExerciceCreate> {
  late VideoPlayerController? _videoController;
  late GlobalKey<FormState> _formKey;
  final ExerciceController controller = Get.put(ExerciceController());
  YoutubePlayerController? youtubeController;

  @override
  Widget build(BuildContext context) {
    _formKey = GlobalKey<FormState>();
    final Widget saveButton = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.saveExercice().then((_) {
              showToast(widget.isCreation ? 'Exercice créé' : 'Exercice mis à jour', backgroundColor: Colors.green);
              if (widget.isCreation) {
                Navigator.of(context).pop();
              }
            }).catchError((_) => showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent));
          }
        },
        child: Text(widget.isCreation ? 'Créer' : 'Enregistrer', style: TextStyle(color: Colors.white)),
      ),
    );

    final Widget closeButton = TextButton(
      style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Fermer',
        style: TextStyle(color: Colors.white),
      ),
    );

    final List<Widget> buttons = widget.displayCloseButton ? <Widget>[saveButton, closeButton] : <Widget>[saveButton];

    return FormExercice(buttons: buttons, formKey: _formKey);
  }
}

/// Composant Mise à jour
class ExerciceUpdate extends StatefulWidget {
  ExerciceUpdate({Key? key, required this.exercice, this.displayCloseButton = false}) : super(key: key);

  final bool displayCloseButton;
  final Exercice exercice;
  final ExerciceUpdateController controller = Get.put(ExerciceUpdateController());

  @override
  State<ExerciceUpdate> createState() => _ExerciceUpdateState();
}

class _ExerciceUpdateState extends State<ExerciceUpdate> {
  late GlobalKey<FormState> _formKey;
  final ExerciceUpdateController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.init(widget.exercice);

    _formKey = GlobalKey<FormState>();

    final Widget saveButton = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            controller.saveExercice().then((_) {
              showToast('Exercice mis à jour', backgroundColor: Colors.green);
            }).catchError((_) => showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent));
          }
        },
        child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
      ),
    );

    final Widget closeButton = TextButton(
      style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Fermer',
        style: TextStyle(color: Colors.white),
      ),
    );

    final List<Widget> buttons = widget.displayCloseButton ? <Widget>[saveButton, closeButton] : <Widget>[saveButton];

    return Obx(
      () {
        if (controller.isSet.value) {
          return FormExercice(buttons: buttons, formKey: _formKey);
        } else {
          return Container();
        }
      },
    );
  }
}

class FormExercice extends StatefulWidget {
  const FormExercice({Key? key, required this.buttons, required this.formKey}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final List<Widget> buttons;

  @override
  State<FormExercice> createState() => _FormExerciceState();
}

class _FormExerciceState extends State<FormExercice> {
  final ExerciceUpdateController controller = Get.find();
  VideoPlayerController? _videoController;
  YoutubePlayerController? youtubeController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Obx(
                      () => StorageFutureImageWidget(
                        futureInitialStorageFile: UtilService.getFutureStorageFile(controller.exercice.value),
                        onSaved: controller.setStoragePair,
                        onDeleted: controller.setStoragePair,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Obx(
                          () {
                            final TextEditingController ctrl = TextEditingController(text: controller.exercice.value.name);
                            return FitnessDecorationTextFormField(
                                controller: ctrl,
                                autofocus: true,
                                onChanged: (String name) => controller.exercice.value.name = name,
                                labelText: 'Nom',
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Merci de renseigner le nom du exercice.';
                                  }
                                  return null;
                                });
                          },
                        ),
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
                  child: Obx(
                () => ParamDropdownButton(
                  decoration: const InputDecoration(
                      labelText: "Type d'exercice",
                      constraints: BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  paramName: 'type_exercice',
                  initialValue: controller.exercice.value.typeExercice,
                  onChanged: (String? onChangedValue) => controller.exercice.value.typeExercice = onChangedValue,
                ),
              ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Obx(
              () {
                final TextEditingController ctrlDescription = TextEditingController(text: controller.exercice.value.description);
                return TextFormField(
                  controller: ctrlDescription,
                  maxLength: 2000,
                  minLines: 5,
                  maxLines: 20,
                  onChanged: (String description) => controller.exercice.value.description = description,
                  decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionnel'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Obx(() {
                      final TextEditingController ctrlVideoUrl = TextEditingController(text: controller.exercice.value.videoUrl);
                      return FitnessDecorationTextFormField(
                        controller: ctrlVideoUrl,
                        onChanged: (String videoUrl) => controller.exercice.value.videoUrl = videoUrl,
                        labelText: 'URL vidéo',
                        hintText: 'Exemple : https://myStorage.com/squat_video.mp4',
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Obx(() {
                      final String? youtube = controller.exercice.value.youtubeUrl;
                      final TextEditingController ctrlYoutubeUrl = TextEditingController(text: youtube);
                      return FitnessDecorationTextFormField(
                        controller: ctrlYoutubeUrl,
                        onChanged: (String youtubeUrl) => controller.exercice.value.youtubeUrl = youtubeUrl,
                        hintText: 'Identifiant vidéo Youtube',
                        labelText: 'Youtube',
                      );
                    }),
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
              Obx(
                () {
                  if (controller.exercice.value.videoUrl != null) {
                    _videoController = VideoPlayerController.network(controller.exercice.value.videoUrl!);
                    return FutureBuilder<Object?>(
                      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
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
              Obx(
                () {
                  if (controller.exercice.value.youtubeUrl != null) {
                    if (youtubeController == null) {
                      youtubeController = YoutubePlayerController(
                        initialVideoId: controller.exercice.value.youtubeUrl!,
                        params: const YoutubePlayerParams(
                          autoPlay: false,
                        ),
                      );
                    } else {
                      youtubeController!.cue(controller.exercice.value.youtubeUrl!);
                    }
                    youtubeController!.pause();
                    return LimitedBox(
                      maxWidth: 500,
                      child: YoutubePlayerIFrame(
                        controller: youtubeController,
                      ),
                    );
                  } else {
                    if (youtubeController != null) {
                      youtubeController!.reset();
                      youtubeController = null;
                    }
                    return Container();
                  }
                },
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: widget.buttons),
          ),
        ],
      ),
    );
  }
}

import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/exerciceUpdate.controller.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/widgets/firestore_param_dropdown.widget.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constants/constants.dart';

/// Controller de la page mise à jour d'un exercice.
class ExerciceGenericPageVm extends GetxController {
  final ExerciceService exerciceService = Get.find();
  final Rx<Exercice?> _exercice = Rx<Exercice?>(null);
  final RxBool _sendStorage = false.obs;

  set sendStorage(bool send) {
    _sendStorage.value = send;
  }

  bool get sendStorage => _sendStorage.value;

  set exercice(Exercice? exo) {
    _exercice.value = exo;
  }

  Exercice? get exercice => _exercice.value;

  void changeStorageFile(StorageFile? storageFile) {
    _exercice.value!.storageFile = storageFile;
    _sendStorage.value = true;
  }

  set videoUrl(String? videoUrl) {
    _exercice.value!.videoUrl = videoUrl;
  }

  String? get videoUrl => _exercice.value!.videoUrl;

  set youtubeUrl(String? youtubeUrl) {
    _exercice.value!.youtubeUrl = youtubeUrl;
  }

  String? get youtubeUrl => _exercice.value!.youtubeUrl;

  Future<void> saveExercice() async {
    final bool isUpdate = exercice!.uid != null;
    if (isUpdate) {
      if (_sendStorage.value) {
        return exerciceService.eraseAndReplaceStorage(exercice!).then((_) => exerciceService.save(exercice!));
      } else {
        return exerciceService.save(exercice!);
      }
    } else {
      exercice!.uid = exerciceService.getCollectionReference().doc().id;
      return exerciceService.createStorage(exercice!).then((_) => exerciceService.create(exercice!));
    }
  }
}

class ExerciceBuilderPage {
  /// Permet de créer une AlertDialog pour la création d'un exercice.
  static void create(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text("Création d'un exercice"),
            content: ExerciceUpdateCreateGeneric(
              isCreation: true,
              exercice: Exercice(),
            )));
  }

  /// Permet de créer une AlertDialog pour la mise à jour d'un exercice.
  static void update({required BuildContext context, required Exercice exercice}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Mise à jour'),
            content: ExerciceUpdateCreateGeneric(
              isCreation: false,
              exercice: exercice,
            )));
  }
}

/// Composant générique pour l'exercice (Mise à jour / Création).
class ExerciceUpdateCreateGeneric extends StatefulWidget {
  ExerciceUpdateCreateGeneric({Key? key, required this.isCreation, this.displayCloseButton = false}) : super(key: key);

  final bool isCreation;
  final bool displayCloseButton;
  final ExerciceUpdateController controller = Get.find();

  @override
  State<ExerciceUpdateCreateGeneric> createState() => _ExerciceUpdateCreateGenericState();
}

class _ExerciceUpdateCreateGenericState extends State<ExerciceUpdateCreateGeneric> {
  late VideoPlayerController? _videoController;
  late YoutubePlayerController? _youtubeController;
  late GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    _formKey = GlobalKey<FormState>();

    return ChangeNotifierProvider<ExerciceGenericPageVm>(
      create: (BuildContext context) => ExerciceGenericPageVm(widget.exercice),
      builder: (BuildContext context, Widget? child) {
        final ExerciceGenericPageVm vm = Provider.of<ExerciceGenericPageVm>(context, listen: false);

        vm.changeExercice(widget.exercice);

        final Widget saveButton = Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                vm.saveExercice().then((_) {
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

        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        StorageFutureImageWidget(
                          futureInitialStorageFile: UtilService.getFutureStorageFile(vm.exercice),
                          onSaved: vm.changeStorageFile,
                          onDeleted: (StorageFile? storageFile) => vm.changeStorageFile(null),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: FitnessDecorationTextFormField(
                                initialValue: vm.exercice.name,
                                autofocus: true,
                                onChanged: (String value) => vm.exercice.name = value,
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
                        constraints: BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    paramName: 'type_exercice',
                    initialValue: vm.exercice.typeExercice,
                    onChanged: (String? onChangedValue) => vm.exercice.typeExercice = onChangedValue,
                  ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  initialValue: vm.exercice.description,
                  maxLength: 2000,
                  minLines: 5,
                  maxLines: 20,
                  onChanged: (String description) => vm.exercice.description = description,
                  decoration: const InputDecoration(labelText: 'Description', helperText: 'Optionnel'),
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
                          initialValue: vm.exercice.videoUrl,
                          onChanged: (String videoUrl) => vm.exercice.videoUrl = videoUrl,
                          labelText: 'URL vidéo',
                          hintText: 'Exemple : https://myStorage.com/squat_video.mp4',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: FitnessDecorationTextFormField(
                          initialValue: vm.exercice.youtubeUrl,
                          onChanged: (String youtubeUrl) => vm.changeYoutubeUrl(youtubeUrl),
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
                  Consumer<ExerciceGenericPageVm>(
                    builder: (_, ExerciceGenericPageVm consumeVm, __) {
                      if (consumeVm.exercice.videoUrl != null) {
                        _videoController = VideoPlayerController.network(consumeVm.exercice.videoUrl!);
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
                  Consumer<ExerciceGenericPageVm>(
                    builder: (_, ExerciceGenericPageVm consumeVm, __) {
                      if (consumeVm.exercice.youtubeUrl != null) {
                        _youtubeController = YoutubePlayerController(
                          initialVideoId: consumeVm.exercice.youtubeUrl!,
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
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons),
              ),
            ],
          ),
        );
      },
    );
  }
}

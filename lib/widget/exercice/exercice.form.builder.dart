import 'package:fitnc_trainer/service/exercice.controller.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/widget/firestore_param_dropdown.widget.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExerciceBuilderPage {
  /// Permet de créer une AlertDialog pour la création d'un exercice.
  static void create(BuildContext context) {
    showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('createExercise'.tr),
        content: ExerciceCreate(),
      ),
    );
  }

  /// Permet de créer une AlertDialog pour la mise à jour d'un exercice.
  static void update({required BuildContext context, required Exercice exercice}) {
    showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('update'.tr),
        content: ExerciceUpdate(
          exercice: exercice,
        ),
      ),
    );
  }
}

/// Composant Création
class ExerciceCreate extends StatefulWidget {
  ExerciceCreate({Key? key, this.isCreation = true}) : super(key: key);

  final bool isCreation;
  final ExerciceCreateController controller = Get.put(ExerciceCreateController());

  @override
  State<ExerciceCreate> createState() => _ExerciceCreateState();
}

class _ExerciceCreateState extends State<ExerciceCreate> {
  late GlobalKey<FormState> _formKey;
  YoutubePlayerController? youtubeController;

  @override
  Widget build(BuildContext context) {
    widget.controller.init(Exercice());

    _formKey = GlobalKey<FormState>();

    final Widget saveButton = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.controller.saveExercice().then((_) {
              showToast('exerciseCreated'.tr, backgroundColor: Colors.green);
                Navigator.of(context).pop();
            }).catchError((_) => showToast('errorWhileSaving'.tr, backgroundColor: Colors.redAccent));
          }
        },
        child: Text('create'.tr, style: const TextStyle(color: Colors.white)),
      ),
    );

    return FormExercice(
      buttons: [saveButton, CloseButton()],
      formKey: _formKey,
      controller: widget.controller,
    );
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
      onPressed: () => Navigator.pop(context),
      child: Text(
        'close'.tr,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Composant Mise à jour
class ExerciceUpdate extends StatefulWidget {
  ExerciceUpdate({Key? key, required this.exercice, this.displayCloseButton = false}) : super(key: key);

  final bool displayCloseButton;
  final Exercice exercice;
  final ExerciceUpdateController controller = Get.find();

  @override
  State<ExerciceUpdate> createState() => _ExerciceUpdateState();
}

class _ExerciceUpdateState extends State<ExerciceUpdate> {
  late GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    widget.controller.init(widget.exercice);

    _formKey = GlobalKey<FormState>();

    final Widget saveButton = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            widget.controller.saveExercice().then((_) {
              showToast('exerciseUpdated'.tr, backgroundColor: Colors.green);
            }).catchError((_) => showToast('errorWhileSaving'.tr, backgroundColor: Colors.redAccent));
          }
        },
        child: Text('save'.tr, style: TextStyle(color: Colors.white)),
      ),
    );

    final List<Widget> buttons = widget.displayCloseButton ? <Widget>[saveButton, CloseButton()] : <Widget>[saveButton];

    return GetBuilder<ExerciceUpdateController>(
      init: widget.controller,
      builder: (ExerciceUpdateController controller) {
        if (controller.isSet.value) {
          return FormExercice(
            buttons: buttons,
            formKey: _formKey,
            controller: controller,
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  Icons.mouse,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                ),
              ),
              Text('clickToUpdateExercise'.tr)
            ],
          );
        }
      },
    );
  }
}

class FormExercice extends StatefulWidget {
  const FormExercice({Key? key, required this.buttons, required this.formKey, required this.controller})
      : super(key: key);

  final GlobalKey<FormState> formKey;
  final List<Widget> buttons;
  final AbstractExerciceController controller;

  @override
  State<FormExercice> createState() => _FormExerciceState();
}

class _FormExerciceState extends State<FormExercice> {
  // VideoPlayerController? _videoController;
  YoutubePlayerController? youtubeController;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(50),
      controller: scrollController,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: scrollController,
        child: Form(
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
                          () => StorageImageWidget(
                            imageUrl: widget.controller.exercise.value.imageUrl,
                            storageFile: widget.controller.exercise.value.storageFile,
                            onSaved: widget.controller.setStoragePair,
                            onDeleted: () => widget.controller.setStoragePair(null),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Obx(
                              () => FitnessDecorationTextFormField(
                                  controller: TextEditingController(text: widget.controller.exercise.value.name),
                                  autofocus: true,
                                  onChanged: (String name) => widget.controller.exercise.value.name = name,
                                  labelText: 'name'.tr,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'fillName'.tr;
                                    }
                                    return null;
                                  }),
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
                      decoration: InputDecoration(
                          labelText: 'exerciseType'.tr,
                          constraints: const BoxConstraints(maxHeight: FitnessConstants.textFormFieldHeight),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                      paramName: 'type_exercice',
                      initialValue: widget.controller.exercise.value.typeExercice,
                      onChanged: (String? onChangedValue) =>
                          widget.controller.changeExerciceType(context, onChangedValue),
                    ),
                  ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Obx(
                  () => TextFormField(
                    controller: TextEditingController(text: widget.controller.exercise.value.description),
                    maxLength: 2000,
                    minLines: 5,
                    maxLines: 20,
                    onChanged: (String description) => widget.controller.exercise.value.description = description,
                    decoration: InputDecoration(labelText: 'description'.tr, helperText: 'optional'.tr),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    /// TODO Uncomment when videoUrl has been implemented.
                    ///
                    // Expanded(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 5),
                    //     child: Obx(
                    //       () => FitnessDecorationTextFormField(
                    //         controller: TextEditingController(text: widget.controller.exercise.value.videoUrl),
                    //         onChanged: (String videoUrl) => widget.controller.exercise.value.videoUrl = videoUrl,
                    //         labelText: 'URL vidéo',
                    //         hintText: 'Exemple : https://myStorage.com/squat_video.mp4',
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Obx(() {
                          final String? youtube = widget.controller.exercise.value.youtubeUrl;
                          final TextEditingController ctrlYoutubeUrl = TextEditingController(text: youtube);
                          return FitnessDecorationTextFormField(
                            controller: ctrlYoutubeUrl,
                            onChanged: (String youtubeUrl) {
                              widget.controller.exercise.update((Exercice? val) {
                                if (val != null) {
                                  val.youtubeUrl = youtubeUrl;
                                }
                              });
                            },
                            hintText: 'youtubeId'.tr,
                            labelText: 'youtubeLabel'.tr,
                          );
                        }),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: Text(
                        'youtubeVideoHelper'.tr,
                        maxLines: 5,
                      ),
                    ),
                  )
                ],
              ),
              /// TODO A remettre quand la fonctionnalité des vidéos sera mise en place.
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Obx(
              //       () {
              //         if (widget.controller.exercise.value.videoUrl != null) {
              //           _videoController = VideoPlayerController.network(widget.controller.exercise.value.videoUrl!);
              //           return FutureBuilder<Object?>(
              //             builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              //               if (_videoController?.value.isInitialized == true) {
              //                 return LimitedBox(
              //                   maxWidth: 500,
              //                   child: AspectRatio(
              //                     aspectRatio: _videoController!.value.aspectRatio,
              //                     child: VideoPlayer(_videoController!),
              //                   ),
              //                 );
              //               } else {
              //                 return Container();
              //               }
              //             },
              //             future: _videoController!.initialize(),
              //           );
              //         } else {
              //           return Container();
              //         }
              //       },
              //     )
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Obx(
                    () {
                      if (widget.controller.exercise.value.youtubeUrl != null &&
                          widget.controller.exercise.value.youtubeUrl!.isNotEmpty) {
                        return FutureBuilder<void>(
                          future: closeYoutubeController(),
                          builder: (_, AsyncSnapshot<void> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              youtubeController = YoutubePlayerController(
                                initialVideoId: widget.controller.exercise.value.youtubeUrl!,
                                params: const YoutubePlayerParams(
                                  autoPlay: false,
                                  showControls: false
                                ),
                              );
                              return LimitedBox(
                                maxWidth: 500,
                                child: YoutubePlayerIFrame(
                                  controller: youtubeController,
                                ),
                              );
                            }
                            return Container();
                          },
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
                child: Row(children: widget.buttons),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> closeYoutubeController() {
    if (youtubeController != null) {
      return youtubeController!.close();
    } else {
      return Future<void>.value();
    }
  }
}

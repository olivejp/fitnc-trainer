import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/constants/constants.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/published_programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class ProfilPageController extends GetxController {
  ProfilPageController() {
    if (authService.isConnected()) {
      trainersService
          .getCurrentTrainerRef()
          .get()
          .then((DocumentSnapshot<Object?> value) => Trainers.fromJson(value.data() as Map<String, dynamic>))
          .then((Trainers trainerRead) {
        trainer.update((Trainers? val) {
          if (val != null) {
            val.uid = trainerRead.uid;
            val.name = trainerRead.name;
            val.prenom = trainerRead.prenom;
            val.telephone = trainerRead.telephone;
            val.email = trainerRead.email;
            val.imageUrl = trainerRead.imageUrl;
          }
        });
      });
    } else {
      throw Exception('Aucun utilisateur connecté. Impossible de construire le ProfilePageController.');
    }
  }

  final FirebaseStorageService storageService = Get.find();
  final TrainersService trainersService = Get.find();
  final ProgrammeService programmeService = Get.find();
  final AuthService authService = Get.find();
  final Rx<Trainers?> trainer = Trainers().obs;

  void setStoragePair(StorageFile? stFile) {
    trainer.update((Trainers? user) {
      if (user != null) {
        user.storageFile = stFile ?? StorageFile();
        user.imageUrl = null;
      }
    });
  }

  Future<void> save() async {
    if (trainer.value != null) {
      await trainersService.save(trainer.value!);
      await programmeService.refreshAllPublished();
    } else {
      throw Exception('Aucun domain Trainer a sauvegardé');
    }
  }
}

class ProfilPage extends StatelessWidget {
  ProfilPage({Key? key}) : super(key: key);
  final ProfilPageController controller = Get.put(ProfilPageController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Obx(
                        () => StorageImageWidget(
                          imageUrl: controller.trainer.value?.imageUrl,
                          storageFile: controller.trainer.value?.storageFile,
                          onSaved: controller.setStoragePair,
                          onDeleted: () => controller.setStoragePair(null),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            controller.save().then((_) {
                              showToast('Vos informations ont été mises à jour', backgroundColor: Colors.green);
                            }).catchError(
                              (_) => showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                        child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(
                () => FitnessDecorationTextFormField(
                    controller: TextEditingController(text: controller.trainer.value?.email),
                    autofocus: true,
                    onChanged: (String email) => controller.trainer.value?.email = email,
                    labelText: 'Email',
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Merci de renseigner votre adresse mail.';
                      }
                      return null;
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(
                () => FitnessDecorationTextFormField(
                    controller: TextEditingController(text: controller.trainer.value?.name),
                    autofocus: true,
                    onChanged: (String name) => controller.trainer.value?.name = name,
                    labelText: 'Nom',
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Merci de renseigner votre nom.';
                      }
                      return null;
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(
                () => FitnessDecorationTextFormField(
                    controller: TextEditingController(text: controller.trainer.value?.prenom),
                    autofocus: true,
                    onChanged: (String prenom) => controller.trainer.value?.prenom = prenom,
                    labelText: 'Prénom',
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Merci de renseigner votre prénom.';
                      }
                      return null;
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(
                () => TextFormField(
                  maxLength: 6,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: (controller.trainer.value?.telephone) != null ? controller.trainer.value!.telephone.toString() : '',
                  onChanged: (String value) => controller.trainer.value?.telephone = value,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

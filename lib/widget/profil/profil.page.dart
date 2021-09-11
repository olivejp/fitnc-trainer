import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/constants/constants.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/generic_container.widget.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class ProfilPageController extends GetxController {
  ProfilPageController() {
    if (authService.isConnected()) {
      trainersService
          .getCurrentTrainerRef()
          .get()
          .then((DocumentSnapshot<Object?> value) => Trainers.fromJson(value.data() as Map<String, dynamic>))
          .then((Trainers trainerRead) => trainer.value = trainerRead);
    } else {
      throw Exception('Aucun utilisateur connecté. Impossible de construire le ProfilePageController.');
    }
  }

  final FirebaseStorageService storageService = Get.find();
  final TrainersService trainersService = Get.find();
  final AuthService authService = Get.find();
  final Rx<Trainers?> trainer = Trainers().obs;
  bool sendStorage = false;

  void setStoragePair(StorageFile? stFile) {
    sendStorage = true;
    trainer.update((Trainers? user) {
      if (user != null) {
        user.storageFile = stFile ?? StorageFile();
        user.imageUrl = null;
      }
    });
  }

  Future<void> save() async {
    if (trainer.value != null) {
      return trainersService.getCurrentTrainerRef().update(trainer.value!.toJson());
    } else {
      throw Exception('Aucun domain Trainer a sauvegardé');
    }
  }
}

class ProfilPage extends StatelessWidget {
  ProfilPage({Key? key}) : super(key: key);
  final ProfilPageController controller = Get.put(ProfilPageController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: FitnessNcColors.blue600),
              onPressed: () {
                controller.save().then((_) {
                  showToast('Vos informations ont été mises à jour', backgroundColor: Colors.green);
                }).catchError((_) => showToast('Erreur lors de la sauvegarde', backgroundColor: Colors.redAccent));
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
        Obx(
          () => StorageImageWidget(
            imageUrl: controller.trainer.value?.imageUrl,
            storageFile: controller.trainer.value?.storageFile,
            onSaved: controller.setStoragePair,
            onDeleted: () => controller.setStoragePair(null),
          ),
        ),
        FitnessDecorationTextFormField(
            controller: TextEditingController(text: controller.trainer.value?.name),
            autofocus: true,
            onChanged: (String name) => controller.trainer.value?.name = name,
            labelText: 'Nom',
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Merci de renseigner votre nom.';
              }
              return null;
            })
      ],
    );
  }
}

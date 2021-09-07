import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/service/exercice.controller.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart' as getRx;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../constants/constants.dart';
import 'exercice.form.builder.dart';

class ExercicePageController extends GetxController {
  final ExerciceService exerciceService = Get.find();

  RxList<bool> toggleSelections = <bool>[true, false].obs;

  void toggleSelection(int index) {
    toggleSelections.clear();
    toggleSelections.addAll(<bool>[false, false]);
    toggleSelections[index] = true;
  }

  RxBool dualScreen = true.obs;

  void setDualScreen({required bool isDualScreen}) {
    if (dualScreen.value != isDualScreen) {
      dualScreen.value = isDualScreen;
    }
  }

  final RxInt display = 0.obs;

  void changeDisplay(int newDisplay) {
    display.value = newDisplay;
  }

  getRx.Rx<Exercice> exerciceSelected = Exercice().obs;

  void selectExercice(Exercice exercice) {
    exerciceSelected.value = exercice;
  }
}

class ExercicePage extends StatelessWidget {
  final List<Exercice> listCompleteExercice = <Exercice>[];
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final ExerciceService service = Get.find();
  final DisplayTypeController displayTypeController = Get.find();
  final ExercicePageController controller = Get.put(ExercicePageController());
  final ExerciceUpdateController updateController = Get.put(ExerciceUpdateController());

  @override
  Widget build(BuildContext context) {
    controller.setDualScreen(isDualScreen: displayTypeController.displayType.value == DisplayType.desktop);
    displayTypeController.displayType.listen((DisplayType displayType) {
      controller.setDualScreen(isDualScreen: displayType == DisplayType.desktop);
    });

    return RoutedPage(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SelectableText(
                  'Exercice',
                  style: Theme.of(context).textTheme.headline1,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    maximumSize: const Size(200, 50),
                  ),
                  onPressed: () => ExerciceBuilderPage.create(context),
                  child: Text(
                    'Créer un exercice',
                    style: GoogleFonts.roboto(color: Color(Colors.white.value), fontSize: 15),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: GetX<ExercicePageController>(
                init: controller,
                builder: (ExercicePageController controller) {
                  final List<Widget> list = <Widget>[
                    Expanded(flex: 2, child: ExerciceListSearch()),
                  ];

                  if (controller.dualScreen.value) {
                    list.add(
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration:
                              const BoxDecoration(color: FitnessNcColors.blue50, borderRadius: BorderRadius.only(topLeft: Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: ExerciceUpdate(exercice: controller.exerciceSelected.value),
                          ),
                        ),
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list,
                  );
                }),
          ),
        ],
      ),
    ));
  }
}

class ExerciceListSearch extends StatefulWidget {
  ExerciceListSearch({
    Key? key,
  }) : super(key: key);

  final ExerciceService service = Get.find();
  final ExercicePageController vm = Get.find();

  @override
  State<ExerciceListSearch> createState() => _ExerciceListSearchState();
}

class _ExerciceListSearchState extends State<ExerciceListSearch> {
  final BehaviorSubject<List<Exercice>> _streamListExercice = BehaviorSubject<List<Exercice>>();
  final List<Exercice> listCompleteExercice = <Exercice>[];

  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, listCompleteExercice, _streamListExercice);
  }

  String? get query => _query;

  @override
  Widget build(BuildContext context) {
    widget.service.listenAll().listen((List<Exercice> event) {
      listCompleteExercice.clear();
      listCompleteExercice.addAll(event);
      _streamListExercice.sink.add(listCompleteExercice);
      UtilService.search(_query, listCompleteExercice, _streamListExercice);
    });

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconTheme(
                  data: const IconThemeData(size: 15),
                  child: Obx(
                    () => ToggleButtons(
                      color: Colors.grey,
                      selectedColor: FitnessNcColors.blue300,
                      borderColor: Colors.grey,
                      borderWidth: 1,
                      selectedBorderColor: FitnessNcColors.orange400,
                      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                      borderRadius: BorderRadius.circular(5),
                      isSelected: widget.vm.toggleSelections,
                      onPressed: (int index) {
                        widget.vm.toggleSelection(index);
                        widget.vm.changeDisplay(index);
                      },
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.grid_view),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.list),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    constraints: const BoxConstraints(maxHeight: 43),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Recherche...',
                  ),
                  onChanged: (String value) {
                    query = value;
                  },
                  textAlignVertical: TextAlignVertical.bottom,
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: ExerciceStreamBuilder(
          streamListExercice: _streamListExercice,
        )),
      ],
    );
  }
}

class ExerciceStreamBuilder extends StatelessWidget {
  ExerciceStreamBuilder({
    Key? key,
    required BehaviorSubject<List<Exercice>> streamListExercice,
  })  : _streamListExercice = streamListExercice,
        super(key: key);

  final BehaviorSubject<List<Exercice>> _streamListExercice;
  final ExerciceService service = Get.find();
  final ExercicePageController pageController = Get.find();
  final ExerciceUpdateController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    void selectExercice(Exercice exercice) {
      controller.init(exercice);

      if (!pageController.dualScreen.value) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            content: ExerciceUpdate(exercice: exercice, displayCloseButton: true),
          ),
        );
      }
    }

    return StreamBuilder<List<Exercice>>(
      stream: _streamListExercice,
      builder: (BuildContext context, AsyncSnapshot<List<Exercice>> snapshot) {
        if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
          return const Center(child: Text('Aucun exercice trouvé.'));
        } else {
          final List<Exercice> list = snapshot.data!;
          return Obx(() {
            return (pageController.display.value == 0)
                ? FitnessGridView<Exercice>(
                    defaultDesktopColumns: 3,
                    defaultTabletColumns: 2,
                    domains: list,
                    bloc: service,
                    onTap: (Exercice exercice) => selectExercice(exercice),
                  )
                : ExerciceListViewSeparated(list: list);
          });
        }
      },
    );
  }
}

class ExerciceListViewSeparated extends StatelessWidget {
  ExerciceListViewSeparated({
    Key? key,
    required this.list,
  }) : super(key: key);

  final List<Exercice> list;
  final ExerciceService bloc = Get.find();
  final ExercicePageController vm = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final Exercice exercice = list.elementAt(index);
          return ExerciceListTile(exercice: exercice);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
              height: 2,
            ),
        itemCount: list.length);
  }
}

class ExerciceListTile extends StatelessWidget {
  ExerciceListTile({
    Key? key,
    required this.exercice,
  }) : super(key: key);

  final Exercice exercice;
  final ExercicePageController pageController = Get.find();
  final ExerciceService service = Get.find();
  final ExerciceUpdateController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    void selectExercice(Exercice exercice) {
      pageController.selectExercice(exercice);
      controller.init(exercice);
      if (!pageController.dualScreen.value) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            content: ExerciceUpdate(exercice: exercice, displayCloseButton: true),
          ),
        );
      }
    }

    return Obx(
      () => ListTile(
        contentPadding: const EdgeInsets.all(20),
        selected: pageController.exerciceSelected.value.uid == exercice.uid,
        selectedTileColor: FitnessNcColors.blue50,
        leading: CircleAvatar(foregroundImage: exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null),
        title: Text(exercice.name),
        trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: RichText(
                      text: TextSpan(text: 'Êtes-vous sûr de vouloir supprimer : ', children: <InlineSpan>[
                    TextSpan(text: exercice.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' ?'),
                  ])),
                  actions: <Widget>[
                    TextButton(onPressed: () => service.delete(exercice).then((_) => Navigator.pop(context)), child: const Text('Oui')),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete)),
        onTap: () => selectExercice(exercice),
      ),
    );
  }
}

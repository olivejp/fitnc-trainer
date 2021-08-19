import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'exercice.form.builder.dart';

class ExercicePage extends StatefulWidget {
  const ExercicePage({Key? key}) : super(key: key);

  @override
  State<ExercicePage> createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  final HomePageBloc homePageBloc = HomePageBloc.instance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();
  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> _streamListExercice = BehaviorSubject<List<Exercice>>();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final ValueNotifier<int> _vnDisplay = ValueNotifier<int>(0);
  final ValueNotifier<Exercice?> _vnExerciceSelected = ValueNotifier<Exercice?>(null);
  final ValueNotifier<List<bool>> _vnToggleSelections = ValueNotifier<List<bool>>([true, false]);

  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, listCompleteExercice, _streamListExercice);
  }

  String? get query => _query;

  @override
  void initState() {
    super.initState();
    bloc.listenAll().listen((List<Exercice> event) {
      listCompleteExercice.clear();
      listCompleteExercice.addAll(event);
      _streamListExercice.sink.add(listCompleteExercice);
      UtilService.search(_query, listCompleteExercice, _streamListExercice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget streamListExercice = StreamBuilder<List<Exercice>>(
      stream: _streamListExercice,
      builder: (BuildContext context, AsyncSnapshot<List<Exercice>> snapshot) {
        if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
          return const Center(child: Text('Aucun exercice trouvé.'));
        } else {
          final List<Exercice> list = snapshot.data!;

          final Widget gridExercice = FitnessGridView<Exercice>(
            domains: list,
            bloc: bloc,
            onTap: (Exercice exercice) => _vnExerciceSelected.value = exercice,
          );

          final Widget listExercice = ValueListenableBuilder<Exercice?>(
              valueListenable: _vnExerciceSelected,
              builder: (BuildContext context, Exercice? exerciceSelected, Widget? child) => ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final Exercice exercice = list.elementAt(index);
                    return ListTile(
                      contentPadding: EdgeInsets.all(20),
                      selected: exerciceSelected?.uid == exercice.uid,
                      selectedTileColor: FitnessNcColors.blue50,
                      leading: CircleAvatar(foregroundImage: exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null),
                      title: Text(exercice.name!),
                      trailing: IconButton(onPressed: () => UtilService.showDeleteDialog(context, exercice, bloc), icon: const Icon(Icons.delete)),
                      onTap: () => _vnExerciceSelected.value = exercice,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const Divider(
                        height: 2,
                      ),
                  itemCount: list.length));

          return ValueListenableBuilder<int>(
              valueListenable: _vnDisplay,
              builder: (BuildContext context, int value, Widget? child) {
                if (value == 0) {
                  return gridExercice;
                } else {
                  return listExercice;
                }
              });
        }
      },
    );

    final Widget listSearchExercice = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10,right: 10, left: 10),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconTheme(
                  data: const IconThemeData(size: 15),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _vnDisplay,
                    builder: (BuildContext context, int value, Widget? child) => ValueListenableBuilder<List<bool>>(
                      valueListenable: _vnToggleSelections,
                      builder: (BuildContext context, List<bool> selections, Widget? child) => ToggleButtons(
                        color: Colors.grey,
                        selectedColor: FitnessNcColors.blue300,
                        borderColor: Colors.grey,
                        borderWidth: 1,
                        selectedBorderColor: FitnessNcColors.orange400,
                        constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                        borderRadius: BorderRadius.circular(5),
                        isSelected: selections,
                        onPressed: (int index) {
                          final List<bool> selectionsFalse = List<bool>.generate(2, (_) => false);
                          selectionsFalse[index] = !selectionsFalse[index];
                          _vnToggleSelections.value = selectionsFalse;
                          _vnDisplay.value = index;
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
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    constraints: BoxConstraints(maxHeight: 43),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Recherche...',
                  ),
                  onChanged: (String value) => query = value,
                  textAlignVertical: TextAlignVertical.bottom,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: streamListExercice),
      ],
    );

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 2, child: listSearchExercice),
                  Expanded(
                      flex: 3,
                      child: ValueListenableBuilder<Exercice?>(
                        valueListenable: _vnExerciceSelected,
                        builder: (BuildContext context, Exercice? exercice, Widget? child) {
                          if (exercice != null) {
                            bloc.init(exercice);
                            return Container(
                              decoration: const BoxDecoration(color: FitnessNcColors.blue50),
                              child: Padding(
                                padding: const EdgeInsets.all(60.0),
                                child: ExerciceGeneric(
                                  isCreation: false,
                                  exercice: exercice,
                                ),
                              ),
                            );
                          } else {
                            return child!;
                          }
                        },
                        child: Container(decoration: const BoxDecoration(color: FitnessNcColors.blue50),),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'exercice.form.builder.dart';

class ExercicePageViewModel extends ChangeNotifier {
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();

  List<bool> toggleSelections = <bool>[true, false];

  void toggleSelection(int index) {
    toggleSelections.clear();
    toggleSelections.addAll(<bool>[false, false]);
    toggleSelections[index] = true;
    notifyListeners();
  }

  int display = 0;

  void setDisplay(int display) {
    this.display = display;
    notifyListeners();
  }

  Exercice? exerciceSelected;

  void selectExercice(Exercice? exercice) {
    exerciceSelected = exercice;
    bloc.init(exercice);
    notifyListeners();
  }
}

class ExercicePage extends StatefulWidget {
  const ExercicePage({Key? key}) : super(key: key);

  @override
  State<ExercicePage> createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  final HomePageBloc homePageBloc = HomePageBloc.instance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();
  final List<Exercice> listCompleteExercice = <Exercice>[];
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExercicePageViewModel>(
      create: (BuildContext context) => ExercicePageViewModel(),
      builder: (BuildContext context, Widget? child) => RoutedPage(
        child: Consumer<ExercicePageViewModel>(builder: (BuildContext context, ExercicePageViewModel vm, Widget? child) {
          return Scaffold(
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
                      Expanded(flex: 2, child: ExerciceListSearch(vm: vm, bloc: bloc)),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: const BoxDecoration(color: FitnessNcColors.blue50),
                          child: (vm.exerciceSelected != null)
                              ? Padding(
                                  padding: const EdgeInsets.all(60.0),
                                  child: ExerciceUpdateCreateGeneric(
                                    isCreation: false,
                                    exercice: vm.exerciceSelected,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class ExerciceListSearch extends StatefulWidget {
  const ExerciceListSearch({
    Key? key,
    required this.bloc,
    required this.vm,
  }) : super(key: key);

  final ExerciceUpdateBloc bloc;
  final ExercicePageViewModel vm;

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
    widget.bloc.listenAll().listen((List<Exercice> event) {
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
                  child: ToggleButtons(
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
                      widget.vm.setDisplay(index);
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
          bloc: widget.bloc,
          vm: widget.vm,
        )),
      ],
    );
  }
}

class ExerciceStreamBuilder extends StatelessWidget {
  const ExerciceStreamBuilder({
    Key? key,
    required BehaviorSubject<List<Exercice>> streamListExercice,
    required this.bloc,
    required this.vm,
  })  : _streamListExercice = streamListExercice,
        super(key: key);

  final BehaviorSubject<List<Exercice>> _streamListExercice;
  final ExerciceUpdateBloc bloc;
  final ExercicePageViewModel vm;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Exercice>>(
      stream: _streamListExercice,
      builder: (BuildContext context, AsyncSnapshot<List<Exercice>> snapshot) {
        if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
          return const Center(child: Text('Aucun exercice trouvé.'));
        } else {
          final List<Exercice> list = snapshot.data!;
          return (vm.display == 0)
              ? FitnessGridView<Exercice>(
                  domains: list,
                  bloc: bloc,
                  onTap: (Exercice exercice) => vm.selectExercice(exercice),
                )
              : ExerciceListViewSeparated(
                  list: list,
                  bloc: bloc,
                  vm: vm,
                );
        }
      },
    );
  }
}

class ExerciceListViewSeparated extends StatelessWidget {
  const ExerciceListViewSeparated({
    Key? key,
    required this.list,
    required this.bloc,
    required this.vm,
  }) : super(key: key);

  final List<Exercice> list;
  final ExerciceUpdateBloc bloc;
  final ExercicePageViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final Exercice exercice = list.elementAt(index);
          return ExerciceListTile(vm: vm, exercice: exercice, bloc: bloc);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
              height: 2,
            ),
        itemCount: list.length);
  }
}

class ExerciceListTile extends StatelessWidget {
  const ExerciceListTile({
    Key? key,
    required this.vm,
    required this.exercice,
    required this.bloc,
  }) : super(key: key);

  final ExercicePageViewModel vm;
  final Exercice exercice;
  final ExerciceUpdateBloc bloc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(20),
      selected: vm.exerciceSelected?.uid == exercice.uid,
      selectedTileColor: FitnessNcColors.blue50,
      leading: CircleAvatar(foregroundImage: exercice.imageUrl != null ? NetworkImage(exercice.imageUrl!) : null),
      title: Text(exercice.name!),
      trailing: IconButton(onPressed: () => UtilService.showDeleteDialog(context, exercice, bloc), icon: const Icon(Icons.delete)),
      onTap: () => vm.selectExercice(exercice),
    );
  }
}

import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.form.builder.dart';
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

import 'exercice.create.page.dart';

class ExercicePage extends StatefulWidget {
  const ExercicePage({Key? key}) : super(key: key);

  @override
  State<ExercicePage> createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  final HomePageBloc homePageBloc = HomePageBloc.instance();
  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();
  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> _streamListExercice =
      BehaviorSubject<List<Exercice>>();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final List<bool> _toggleSelections = List<bool>.generate(3, (_) => false);
  final ValueNotifier<int> _vnDisplay = ValueNotifier<int>(0);
  final ValueNotifier<Exercice?> _vnExercice = ValueNotifier<Exercice?>(null);

  String? _query;

  set query(String? text) {
    _query = text;
    UtilSearch.search(_query, listCompleteExercice, _streamListExercice);
  }

  String? get query => _query;

  @override
  void initState() {
    super.initState();
    bloc.listenAll().listen((List<Exercice> event) {
      listCompleteExercice.clear();
      listCompleteExercice.addAll(event);
      _streamListExercice.sink.add(listCompleteExercice);
      UtilSearch.search(_query, listCompleteExercice, _streamListExercice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => ExerciceCreatePage.showCreate(context),
          label: Text(
            'Créer un exercice',
            style: GoogleFonts.roboto(
                fontSize: 15, color: Color(Colors.white.value)),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 25.0,
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: SelectableText(
                        'Exercice',
                        style: Theme.of(context).textTheme.headline1,
                      )),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: IconTheme(
                            data: const IconThemeData(size: 15),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _vnDisplay,
                              builder: (BuildContext context, int value,
                                      Widget? child) =>
                                  ToggleButtons(
                                color: FitnessNcColors.blue200,
                                selectedColor: FitnessNcColors.blue800,
                                constraints: const BoxConstraints(
                                    minHeight: 40, maxHeight: 40),
                                borderRadius: BorderRadius.circular(5),
                                isSelected: _toggleSelections,
                                onPressed: (int index) {
                                  _toggleSelections.map((_) => false).toList();
                                  _toggleSelections[index] =
                                      !_toggleSelections[index];
                                  _vnDisplay.value = index;
                                },
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.list),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.grid_view),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.grid_4x4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
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
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Exercice>>(
                stream: _streamListExercice,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Exercice>> snapshot) {
                  if (!snapshot.hasData ||
                      (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun exercice trouvé.'));
                  } else {
                    final List<Exercice> list = snapshot.data!;
                    return ValueListenableBuilder<int>(
                        valueListenable: _vnDisplay,
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          if (value == 0) {
                            return FitnessGridView<Exercice>(
                              domains: list,
                              bloc: bloc,
                            );
                          } else if (value == 1) {
                            return Column(children: <Widget>[
                              HorizontalGridView<Exercice>(
                                  listDomains: list,
                                  onChanged: (Exercice exercice) =>
                                      _vnExercice.value = exercice),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: ValueListenableBuilder<Exercice?>(
                                        builder: (BuildContext context,
                                            Exercice? exercice, Widget? child) {
                                          final ExerciceUpdateBloc bloc =
                                              ExerciceUpdateBloc.instance();
                                          bloc.init(exercice);
                                          return ExerciceFormBuilder.getForm(
                                              context,
                                              GlobalKey<FormState>(),
                                              bloc);
                                        },
                                        valueListenable: _vnExercice),
                                  ),
                                ),
                              ),
                            ]);
                          } else {
                            return ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  final Exercice exercice =
                                      list.elementAt(index);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      foregroundImage: exercice.imageUrl != null
                                          ? NetworkImage(exercice.imageUrl!)
                                          : null,
                                    ),
                                    title: Text(list.elementAt(index).name!),
                                    trailing: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.clear)),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                          height: 2,
                                        ),
                                itemCount: list.length);
                          }
                        });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalGridView<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridView(
      {Key? key, required this.listDomains, required this.onChanged})
      : super(key: key);

  final List<T> listDomains;
  final void Function(T domain) onChanged;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 300,
      child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisExtent: 200, childAspectRatio: 1 / 4),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: listDomains
              .map((T e) =>
                  HorizontalGridCard<T>(domain: e, onChanged: onChanged))
              .toList()),
    );
  }
}

class HorizontalGridCard<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridCard(
      {Key? key, required this.domain, required this.onChanged})
      : super(key: key);

  final T domain;
  final void Function(T domain) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        onTap: () => onChanged(domain),
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: (domain.imageUrl?.isNotEmpty == true)
                  ? Ink.image(
                      image: NetworkImage(domain.imageUrl!), fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(color: Colors.amber)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(domain.name!,
                        style: const TextStyle(fontSize: 15)),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: () {},
                    icon:
                        const Icon(Icons.delete, color: Colors.grey, size: 24),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

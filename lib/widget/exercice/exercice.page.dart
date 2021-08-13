import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
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
                          child: ToggleButtons(
                            children: [
                              Icon(Icons.list),
                              Icon(Icons.grid_view),
                              Icon(Icons.grid_4x4),
                            ],
                            isSelected: _toggleSelections,
                            onPressed: (int index) {
                              _toggleSelections[index] =
                                  !_toggleSelections[index];
                              _vnDisplay.value = index;
                            },
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
            StreamBuilder<List<Exercice>>(
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
                          return HorizontalGridView<Exercice>(
                              listDomains: list);
                        } else {
                          return ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                final Exercice exercice = list.elementAt(index);
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
          ],
        ),
      ),
    );
  }
}

class HorizontalGridView<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridView({Key? key, required this.listDomains})
      : super(key: key);

  final List<T> listDomains;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 200,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, mainAxisExtent: 200, childAspectRatio: 1 / 4),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children:
            listDomains.map((T e) => HorizontalGridCard<T>(domain: e)).toList(),
      ),
    );
  }
}

class HorizontalGridCard<T extends AbstractFitnessStorageDomain>
    extends StatelessWidget {
  const HorizontalGridCard({Key? key, required this.domain}) : super(key: key);

  final T domain;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
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

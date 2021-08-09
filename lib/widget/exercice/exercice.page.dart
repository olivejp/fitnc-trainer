import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
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
  ExercicePage({Key? key}) : super(key: key);

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  @override
  State<ExercicePage> createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  final HomePageBloc homePageBloc = HomePageBloc.instance();

  final ExerciceUpdateBloc bloc = ExerciceUpdateBloc.instance();
  final List<Exercice> listCompleteExercice = <Exercice>[];
  final BehaviorSubject<List<Exercice>> _streamListExercice = BehaviorSubject<List<Exercice>>();
  String? _query;

  set query(String? text) {
    _query = text;
    searchExercice();
  }

  String? get query => _query;

  /// Recherche des exercices.
  void searchExercice() {
    final String? text = _query?.toUpperCase();
    List<Exercice> listFiltered;
    if (text != null &&  text.isNotEmpty) {
      listFiltered = listCompleteExercice.where((Exercice element) {
        final bool inName = element.name != null && element.name!.toUpperCase().contains(text);
        final bool inDescription = element.description != null && element.description!.toUpperCase().contains(text);
        return inName || inDescription;
      }).toList();
    } else {
      listFiltered = listCompleteExercice;
    }
    _streamListExercice.sink.add(listFiltered);
  }

  @override
  void initState() {
    super.initState();
    bloc.getStreamExercice().listen((List<Exercice> event) {
      listCompleteExercice.clear();
      listCompleteExercice.addAll(event);
      _streamListExercice.sink.add(listCompleteExercice);
    });
  }


  @override
  void dispose() {
    _streamListExercice.close();
    super.dispose();
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
            style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20.0,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: SelectableText(
                        'Exercice',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline1,
                      )),
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
            Expanded(
              child: StreamBuilder<List<Exercice>>(
                stream: _streamListExercice,
                builder: (BuildContext context, AsyncSnapshot<List<Exercice>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun exercice trouvé.'));
                  } else {
                    final List<Exercice> listExercice = snapshot.data!;
                    return FitnessGridView<Exercice>(
                      domains: listExercice,
                      bloc: bloc,
                    );
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

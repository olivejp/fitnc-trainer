import 'package:fitnc_trainer/bloc/home.page.bloc.dart';
import 'package:fitnc_trainer/bloc/programme/programme_update.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/main.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/programme/programme.update.page.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'programme.create.page.dart';

class ProgrammePage extends StatefulWidget {
  const ProgrammePage({Key? key}) : super(key: key);

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> with SingleTickerProviderStateMixin {
  final HomePageBloc homePageBloc = HomePageBloc.instance();
  final ProgrammeUpdateBloc bloc = ProgrammeUpdateBloc.instance();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final List<Programme> listCompleteProgramme = <Programme>[];
  final BehaviorSubject<List<Programme>> _streamListProgramme = BehaviorSubject<List<Programme>>();

  late AnimationController _animationController;
  late Animation<double> _animation;

  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, listCompleteProgramme, _streamListProgramme);
  }

  String? get query => _query;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    bloc.listenAll().listen((List<Programme> event) {
      listCompleteProgramme.clear();
      listCompleteProgramme.addAll(event);
      _streamListProgramme.sink.add(listCompleteProgramme);
      UtilService.search(_query, listCompleteProgramme, _streamListProgramme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => ProgrammeCreatePage.showCreate(context),
          label: Text(
            'Créer un programme',
            style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
          ),
          icon: Icon(
            Icons.add,
            color: Color(Colors.white.value),
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
                      flex: 3,
                      child: Text(
                        'Programme',
                        style: Theme.of(context).textTheme.headline1,
                      )),
                  Expanded(
                    child: TextFormField(
                      onChanged: (String text) => query = text,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Recherche...',
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Programme>>(
                stream: _streamListProgramme,
                builder: (BuildContext context, AsyncSnapshot<List<Programme>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun programme trouvé.'));
                  } else {
                    final List<Programme> programmes = snapshot.data!;
                    return FitnessGridView<Programme>(
                      domains: programmes,
                      bloc: bloc,
                      onTap: (Programme programme) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                AlertDialog(
                                  contentPadding: EdgeInsets.all(20),
                                  content: SizedBox(width: 1280,child: ProgrammeUpdatePage(programme: programme)),
                                ));
                      },
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

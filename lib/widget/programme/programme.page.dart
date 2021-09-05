import 'package:fitnc_trainer/bloc/programme/programme.controller.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/util.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/programme/programme.update.page.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'programme.create.page.dart';

class ProgrammePage extends StatefulWidget {
  ProgrammePage({Key? key}) : super(key: key);
  final ProgrammeController controller = Get.put(ProgrammeController());

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final List<Programme> listCompleteProgramme = <Programme>[];
  final BehaviorSubject<List<Programme>> _streamListProgramme = BehaviorSubject<List<Programme>>();

  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, listCompleteProgramme, _streamListProgramme);
  }

  String? get query => _query;

  @override
  Widget build(BuildContext context) {
    final ProgrammeService service = Get.find();

    /// Ecoute tous les programmes et met à jour la liste locale des programmes.
    service.listenAll().listen((List<Programme> event) {
      listCompleteProgramme.clear();
      listCompleteProgramme.addAll(event);
      _streamListProgramme.sink.add(listCompleteProgramme);
      UtilService.search(_query, listCompleteProgramme, _streamListProgramme);
    });

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
                    decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 43),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                      prefixIcon: const Icon(Icons.search),
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
                    defaultDesktopColumns: 6,
                    childAspectRatio: 15 / 16,
                    domains: programmes,
                    bloc: service,
                    getCard: (Programme pgm) => getProgrammeCard(pgm, context),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ));
  }

  Card getProgrammeCard(Programme programme, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Expanded(
                flex: 3,
                child: (programme.imageUrl?.isNotEmpty == true)
                    ? Ink.image(image: NetworkImage(programme.imageUrl!), fit: BoxFit.cover)
                    : Container(decoration: const BoxDecoration(color: Colors.amber)),
              ),
              Expanded(
                child: Center(child: Text(programme.name)),
              )
            ]),
            if (programme.publishDate != null)
              const Positioned(
                  top: 5,
                  right: 5,
                  child: Chip(
                    backgroundColor: Colors.green,
                    label: Text('Publié'),
                    avatar: Icon(Icons.public),
                  ))
            else
              Container()
          ],
        ),
        onTap: () => onTap(context, programme),
      ),
    );
  }

  Future<dynamic> onTap(BuildContext context, Programme programme) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                width: 1280,
                child: ProgrammeUpdatePage(programme: programme),
              ),
            ));
  }
}

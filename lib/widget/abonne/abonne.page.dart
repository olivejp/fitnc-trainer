
import 'package:fitnc_trainer/service/abonne.service.dart';
import 'package:fitness_domain/service/util.service.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:fitness_domain/domain/abonne.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../generic.grid.card.dart';
import 'abonne.create.page.dart';

class AbonnePage extends StatefulWidget {
  AbonnePage({Key? key}) : super(key: key);

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final List<Abonne> listCompleteAbonne = <Abonne>[];
  final BehaviorSubject<List<Abonne>> _streamListAbonne = BehaviorSubject<List<Abonne>>();

  @override
  _AbonnePageState createState() {
    return _AbonnePageState();
  }
}

class _AbonnePageState extends State<AbonnePage> {
  String? _query;

  set query(String? text) {
    _query = text;
    UtilService.search(_query, widget.listCompleteAbonne, widget._streamListAbonne);
  }

  String? get query => _query;

  @override
  Widget build(BuildContext context) {
    final AbonneService service = Get.find();

    service.listenAll().listen((List<Abonne> event) {
      widget.listCompleteAbonne.clear();
      widget.listCompleteAbonne.addAll(event);
      UtilService.search(_query, widget.listCompleteAbonne, widget._streamListAbonne);
    });

    return RoutedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onPressed: () => AbonneCreatePage.showCreate(context),
          label: Text(
            'Créer un abonne',
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
                      child: SelectableText(
                        'Abonne',
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
              child: StreamBuilder<List<Abonne>>(
                stream: widget._streamListAbonne,
                builder: (BuildContext context, AsyncSnapshot<List<Abonne>> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!.isEmpty)) {
                    return const Center(child: Text('Aucun abonne trouvé.'));
                  } else {
                    final List<Abonne> listAbonne = snapshot.data!;
                    return FitnessGridView<Abonne>(
                      domains: listAbonne,
                      bloc: service,
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

import 'package:fitnc_trainer/controller/programme/programme.controller.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/program/program.update.page.dart';
import 'package:fitnc_trainer/widget/widgets/routed.page.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'program.create.page.dart';

class ProgramPage extends StatefulWidget {
  ProgramPage({Key? key}) : super(key: key);
  final ProgrammeController controller = Get.put(ProgrammeController());
  final ProgrammeService service = Get.find();

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');
  final TextEditingController textSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widget.controller.initSearchList(getStreamList: widget.service.listenAll);
    return RoutedPage(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: () => ProgrammeCreatePage.showCreate(context),
        label: Text(
          'createProgram'.tr,
          style: GoogleFonts.roboto(
              fontSize: 15, color: Color(Colors.white.value)),
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
                      'program'.tr,
                      style: Theme.of(context).textTheme.headline1,
                    )),
                Expanded(
                  child: TextFormField(
                    controller: textSearchController,
                    onChanged: (String text) => widget.controller.search(text),
                    decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 43),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: () {
                          widget.controller.clearSearch();
                          textSearchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      hintText: 'search'.tr,
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Programme>>(
              stream: widget.controller.streamList,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Programme>> snapshot) {
                if (!snapshot.hasData ||
                    (snapshot.hasData && snapshot.data!.isEmpty)) {
                  return Center(child: Text('noProgramFound'.tr));
                } else {
                  final List<Programme> programmes = snapshot.data!;
                  return FitnessGridView<Programme>(
                    defaultDesktopColumns: 6,
                    childAspectRatio: 15 / 16,
                    domains: programmes,
                    service: widget.service,
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
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                Widget>[
              Expanded(
                flex: 3,
                child: (programme.imageUrl?.isNotEmpty == true)
                    ? Ink.image(
                        image: NetworkImage(programme.imageUrl!),
                        fit: BoxFit.cover)
                    : Container(
                        decoration: const BoxDecoration(color: Colors.amber)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Text(
                        programme.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      PopupMenuButton<dynamic>(
                        iconSize: 24,
                        tooltip: 'showMore'.tr,
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        itemBuilder: (_) => <PopupMenuItem<dynamic>>[
                          PopupMenuItem<dynamic>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('delete'.tr),
                                const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: RichText(
                                      text: TextSpan(
                                          text: 'wantToDelete'.tr,
                                          children: <InlineSpan>[
                                        TextSpan(
                                            text: programme.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ' ?'),
                                      ])),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () => widget.service
                                            .delete(programme)
                                            .then(
                                                (_) => Navigator.pop(context)),
                                        child: Text('yes'.tr)),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('cancel'.tr))
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
            if (programme.available == true && programme.publishDate != null)
              Positioned(
                top: 5,
                right: 5,
                child: Chip(
                  backgroundColor: Colors.green,
                  label: Text(
                    'published'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                  avatar: const Icon(
                    Icons.public,
                    color: Colors.white,
                  ),
                ),
              )
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
          child: ProgramUpdatePage(programme: programme),
        ),
      ),
    );
  }
}

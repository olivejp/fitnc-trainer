import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() {
    return new _CalendarPageState();
  }
}

class _CalendarPageState extends State<CalendarPage> {
  DateFormat dateFormat = DateFormat('dd/MM/yyyy - kk:mm');

  _CalendarPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_appointment');
        },
        label: Text(
          'Créer un rappel',
          style: GoogleFonts.roboto(fontSize: 15, color: Color(Colors.white.value)),
        ),
        icon: Icon(
          Icons.add,
          color: Color(Colors.white.value),
          size: 20.0,
        ),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
      ),
    );
  }
}

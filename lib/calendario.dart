import 'package:agenda/calendar_client.dart';
import 'package:agenda/event.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Calendario extends StatefulWidget {
  @override
  _Calendario createState() => new _Calendario();
}

class _Calendario extends State<Calendario> {
  CalendarClient calendarClient = CalendarClient();
  List<EventInfo> aniversarios = new List();

  @override
  void initState() {
    super.initState();
    calendarClient.getCalendarEvents().then((aniversario) {
      if (!mounted) return;
      setState(() {
        aniversario.forEach((aniver) {
          aniversarios.add(aniver);
          aniversarios.sort((a, b) => a.date.compareTo(b.date));
          print(aniversarios.length);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: aniversarios.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Card(
            elevation: 8.0,
            color: HexColor("#365261"),
            child: ListTile(
              title: Text('${aniversarios[i].title}',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              subtitle: Text('${aniversarios[i].date}', style:
                  TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  )),
            ),
          ),
        );
      },
    );
  }
}

import 'package:agenda/event.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarClient {
  static var calendar;
  Future<String> insert({
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  }) async {
    String eventData;

    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    event.description = description;

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT-03:00";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT-03:00";
    end.dateTime = endTime;
    event.end = end;

    try {
      await calendar.events.insert(event, calendarId).then((value) {
        print("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String eventId;
          eventId = value.id;
          eventData = eventId;

          print('Evento adicionado ao Google Calendário');
        } else {
          print("Não foi possível adcionar o evento no Google Calendário");
        }
      });
    } catch (e) {
      print('Erro criando o evento: $e');
    }
    return eventData;
  }

  Future<dynamic> getCalendarEvents() async {
    Map<String, String> eventData;
    List<EventInfo> aniversarios = [];

    initializeDateFormatting('pt_BR', null);

    var calEvents = calendar.events.list("primary");
    await calEvents.then((Events events) {
      events.items.forEach((Event event) {
        if (event.summary.contains("Aniversário")) {
          var titulo = event.summary;
          var dianiver = "";
          EventDateTime data = EventDateTime();
          data = (event.start);
          dianiver = DateFormat.yMMMMd('pt_BR').format(data.dateTime);
          eventData = {'title': titulo, 'date': dianiver};
          EventInfo ev = EventInfo.fromMap(eventData);
          aniversarios.add(ev);
        }
      });
    });
    return aniversarios;
  }

  Future<String> modify({
    String id,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  }) async {
    String eventData;

    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    event.description = description;

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT-03:00";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT-03:00";
    end.dateTime = endTime;
    event.end = end;

    try {
      await calendar.events.patch(event, calendarId, id).then((value) {
        print("Status Evento: ${value.status}");
        if (value.status == "confirmed") {
          String eventId;
          eventId = value.id;
          eventData = eventId;

          print('Evento atualizado no google calendar');
        } else {
          print("Não foi possível atualizar o evento no google calendar");
        }
      });
    } catch (e) {
      print('Erro atualizando o evento $e');
    }

    return eventData;
  }

  Future<void> delete(String eventId) async {
    String calendarId = "primary";
    try {
      await calendar.events.delete(calendarId, eventId).then((value) {
        print('Evento deletado do Google Calendar');
      });
    } catch (e) {
      print('Erro deletando evento: $e');
    }
  }
}

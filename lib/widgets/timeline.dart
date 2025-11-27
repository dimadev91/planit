import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/timeline_event_class.dart';

class TimelineWidget extends StatelessWidget {
  final String tripId;
  final List<TimelineEvent> events;
  TimelineWidget({required this.events, required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final bool isEven = index % 2 == 0;
        final event = events[index];
        final isLast = index == events.length - 1;

        return Center(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 2,
                    color: Colors.transparent,
                  ),
                  // Icona del nodo
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: !isEven ? Colors.white : Color(0xFF155A75),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      event.icon,
                      size: 35,
                      color: !isEven ? Color(0xFF155A75) : Colors.white,
                    ),
                  ),

                  // Linea verso il nodo successivo
                  if (!isLast)
                    Container(width: 3, height: 40, color: Color(0xFF155A75)),
                ],
              ),
              Padding(
                padding: !isEven
                    ? EdgeInsets.only(left: 200)
                    : EdgeInsets.only(),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: Text(
                    textAlign: isEven ? TextAlign.end : TextAlign.start,
                    '${event.title.replaceAll('\n', ' ')}\n'
                    '${DateFormat('dd/MM/yyyy').format(event.datetime)}\n'
                    '${DateFormat('HH:mm').format(event.datetime)}',
                    style: TextStyle(
                      height: 0.95,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

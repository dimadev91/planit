import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/timeline_event_class.dart';

//---------------------------------------------------------------PICCOLE CARD EVENTI
class MiniCard extends StatelessWidget {
  final Function(TimelineEvent) onTap;
  final List<TimelineEvent> events;

  MiniCard({required this.events, required this.onTap, super.key});

  String formatDateTime(DateTime dateTime) {
    final String data = DateFormat('dd-MM-yy').format(dateTime);
    final String ora = DateFormat('HH:mm').format(dateTime);
    return '$data \n $ora';
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTap(events[index]),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kColorMiniCard,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: double.infinity),
                    Text(
                      textAlign: TextAlign.center,
                      '${events[index].title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xCF21373D),
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      '${events[index].description}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xCF21373D),
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 1),
                    Text(formatDateTime(events[index].datetime)),
                  ],
                ),
                if (events[index].price != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 27,
                      width: 63,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color(0xFFDFE6E7),
                      ),
                      child: Center(
                        child: Text(
                          '\$${events[index].price}',

                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

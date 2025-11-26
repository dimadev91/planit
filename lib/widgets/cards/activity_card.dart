import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/widgets/timeline.dart';

class ActivityCard extends StatefulWidget {
  final String? tripId;
  final List<Activity>? activityDetails;
  final String imageAsset;
  final String title;
  final Function(TimelineEvent) onTap; // modifica evento
  final VoidCallback onAdd; // aggiungi nuovo evento

  ActivityCard({
    this.tripId,
    this.activityDetails,
    required this.imageAsset,
    required this.title,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? activityTime;
  String? activityTitle;
  String? budget;
  String activityLocation = '';
  List<TimelineEvent> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents(); // Carica gli eventi all'inizio
  }

  Future<void> loadEvents() async {
    // Se la lista è null o vuota, pulisci e esci
    if (widget.activityDetails == null || widget.activityDetails!.isEmpty) {
      print('1 riga');
      setState(() {
        events = [];
      });
      return;
    }

    List<TimelineEvent> tempEvents = [];

    // Itera su TUTTE le attività nella lista
    for (var activity in widget.activityDetails!) {
      print('2 riga');
      if (activity.activityTime != null && activity.activityName != null) {
        print('3 riga');
        // Mappa i dettagli di Activity a TimelineEvent
        tempEvents.add(
          TimelineEvent(
            datetime: activity.activityTime!,
            title: activity.activityName!,
            icon: Icons.directions_run_outlined,
            description: activity.activityLocation,
            price: activity.activityPrice,
            duration: activity.activityDuration?.toString(),
          ),
        );
        print(activity.activityLocation);
      }
    }
    print('4 riga');

    // Ordina gli eventi per data/ora
    tempEvents.sort((a, b) => a.datetime.compareTo(b.datetime));

    setState(() {
      events = tempEvents;
    });
  }

  String formatDateTime(DateTime dateTime) {
    final String data = DateFormat('dd-MM-yyyy').format(dateTime);
    final String ora = DateFormat('HH:mm').format(dateTime);
    return 'date: $data \n time:$ora';
  }

  @override
  void didUpdateWidget(covariant ActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Confronta la lista di activity
    if (widget.activityDetails != oldWidget.activityDetails) {
      loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 5.1,
        width: MediaQuery.of(context).size.width / 2.30,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Stack(
          children: [
            //----------------------------------------------------------------LISTA EVENTI
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 3, left: 3),
              child: SizedBox(
                height: 220,
                child: ActivityTag(events: events, onTap: widget.onTap),
              ),
            ),

            //---------------------------------------------------------------BUDGET
            if (budget != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 20,
                  width: 63,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xFFC2CCCB),
                  ),
                  child: Center(
                    child: Text(
                      '\$$budget',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),

            //---------------------------------------------------------------TESTO ATTIVITÀ
            Column(
              children: [
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(widget.imageAsset, height: 25),
                    SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xCF21373D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width / 3,
                  color: kColorDivider,
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        activityTime == null
                            ? ''
                            : formatDateTime(activityTime!),
                        style: TextStyle(
                          color: Color(0xCF21373D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //---------------------------------------------------------------BOTTONE +
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: widget.onAdd,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.orangeAccent,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------------------------------------------PICCOLE CARD EVENTI
class ActivityTag extends StatelessWidget {
  final Function(TimelineEvent) onTap;
  final List<TimelineEvent> events;

  ActivityTag({required this.events, required this.onTap, super.key});

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
              color: Color(0xFFBCD0CF),
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

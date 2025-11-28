import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/timeline_event_class.dart';
import 'package:plan_it/widgets/cards/mini_card.dart';

class FoodCard extends StatefulWidget {
  final String? tripId;
  final List<Food>? foodDetails;
  final String imageAsset;
  final String title;
  final Function(TimelineEvent) onTap; // modifica evento
  final VoidCallback onAdd; // aggiungi nuovo evento

  FoodCard({
    required this.tripId,
    this.foodDetails,
    required this.imageAsset,
    required this.title,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  DateTime? restTime;
  String? restName;
  String? budget;
  String restLocation = '';
  List<TimelineEvent> events = [];

  Future<void> loadEvents() async {
    final list = widget.foodDetails ?? [];
    setState(() {
      events = TimelineEventMapper.fromFood(list);
    });
  }

  String formatDateTime(DateTime dateTime) {
    final String data = DateFormat('dd-MM-yyyy').format(dateTime);
    final String ora = DateFormat('HH:mm').format(dateTime);
    return 'date: $data \n time:$ora';
  }

  @override
  void initState() {
    super.initState();

    loadEvents();
  }

  @override
  void didUpdateWidget(covariant FoodCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se i dettagli dell’attività cambiano, aggiorna la UI
    if (widget.foodDetails != oldWidget.foodDetails) {
      final food = widget.foodDetails;

      setState(() {
        restTime = food![0].restTime;
        restName = food[0].restName;
        restLocation = food[0].restLocation ?? '';
        budget = food[0].restPriceRange?.toStringAsFixed(0);
      });
    }

    // Se cambia l’ID del trip → ricarica gli eventi
    if (widget.tripId != oldWidget.tripId) {
      loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
                child: MiniCard(events: events, onTap: widget.onTap),
              ),
            ),

            //---------------------------------------------------------------BUDGET
            if (budget != null)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 23,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xD3C2CCCB),
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

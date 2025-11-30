import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/destination_firestore.dart';

class DestinationCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String title;
  Destination? destinationDetails;
  List<Destination>? destinations;
  void Function(String)? setDesId;

  DestinationCard({
    required this.title,
    required this.destinationDetails,
    this.destinations,
    this.setDesId,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  List<Destination> destinationsCard = [];

  //----------------------------------------------------------------------------funzione per evitare crush in caso di list null
  Future<void> loadDestinations() async {
    final list =
        widget.destinations ??
        []; //vuota per evitare crush se non ci sono destinazioni
    setState(() {
      destinationsCard = list;
    });
  }

  //----------------------------------------------------------------------------funzione per assegnare il primo id in caso non si sia ancora girata pagina-che lo assegna-
  Future<void> loadFirstId() async {
    if (widget.destinations == null) return;

    final firstDestination = await widget.destinations![0];
    final firstId = firstDestination.id;
    widget.setDesId?.call(firstId!); // callback verso il padre
  }

  @override
  void initState() {
    super.initState();
    loadDestinations();
    loadFirstId();
  }

  @override
  void didUpdateWidget(covariant DestinationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationDetails != oldWidget.destinationDetails) {
      loadDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: MediaQuery.of(context).size.height / 20,
        width: MediaQuery.of(context).size.width / 2.30,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: PageView.builder(
          onPageChanged: (index) {
            final destination = destinationsCard[index];
            widget.setDesId?.call(destination.id!); // callback verso il padre
          },
          itemCount: destinationsCard.length,
          itemBuilder: (context, index) {
            final destination =
                destinationsCard[index]; //mettiamo qui lindex per evitarlo di riscriverlo poi, potremmo riscriverlo per ogni variabile listName[index].proprietà
            return Center(
              child: Text(
                '${destination.cityName}, ${destination.countryName}',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xCF21373D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

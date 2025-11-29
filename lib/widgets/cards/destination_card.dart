import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/destination_firestore.dart';

class DestinationCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String title;
  Destination? destinationDetails;
  List<Destination>? destinations;

  DestinationCard({
    required this.title,
    required this.destinationDetails,
    this.destinations,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  String? city;
  String? country;

  @override
  void initState() {
    super.initState();
    final dest = widget.destinationDetails;
    if (dest != null) {
      city = dest.cityName;
      country = dest.countryName;
    }
    print('City: $city, Country: $country');
  }

  @override
  void didUpdateWidget(covariant DestinationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationDetails != oldWidget.destinationDetails) {
      //se quello vecchio e nuovo non corrispondono riesgue la riassegnazione delle variabili
      final dest = widget.destinationDetails;
      if (dest != null) {
        setState(() {
          city = dest.cityName;
          country = dest.countryName;
        });
      }
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
          itemCount: widget.destinations?.length,
          itemBuilder: (context, index) {
            final destination = widget.destinations![index];
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

import 'package:plan_it/resource/exports.dart';

class SampleFlightCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  final String? tripId;
  Flight? flightDetails;

  SampleFlightCard({
    this.tripId,
    required this.imageAsset,
    required this.title,
    this.flightDetails,
  });

  @override
  State<SampleFlightCard> createState() => _SampleFlightCardState();
}

class _SampleFlightCardState extends State<SampleFlightCard> {
  bool isSelected = false;
  DateTime? outDate;
  DateTime? outTime;
  String? outDetail;
  DateTime? inDate;
  DateTime? inTime;
  String? inDetail;
  String inTimeString = '';
  String outTimeString = '';
  String? budget;
  String? outIata;
  String? inIata;
  String? outCity;
  String? inCity;
  String? outAirport;
  String? inAirport;

  String formatDateTime(DateTime dateTime) {
    // 1. Formatta la parte DATA nel formato "dd-MM-yyyy"
    final String data = DateFormat('dd-MMM').format(dateTime);

    // 2. Formatta la parte ORA nel formato "HH:mm"
    final String ora = DateFormat('HH:mm').format(dateTime);

    // 3. Ritorna la singola stringa che combina i due risultati con il tuo layout richiesto.
    return '$ora  $data';
  }

  @override
  void initState() {
    super.initState();
    final flight = widget.flightDetails;
    if (flight == null) return;

    outDate = flight.outboundDateTime;
    inDate = flight.returnDateTime;
    outDetail = flight.outboundDetails;
    inDetail = flight.returnDetails;
    outIata = flight.departureIata;
    inIata = flight.returnIata;
    outCity = flight.departureCity;
    inCity = flight.returnCity;
    outAirport = flight.departureAirport;
    inAirport = flight.returnAirport;

    final double outboundBudget = flight.outboundPrice ?? 0;
    final double returnBudget = flight.returnPrice ?? 0;
    final double totalAmount = outboundBudget + returnBudget;

    budget = totalAmount.toStringAsFixed(0);

    if (outDate != null) {
      outTimeString = formatDateTime(outDate!);
    }

    if (inDate != null) {
      inTimeString = formatDateTime(inDate!);
    }
  }

  //serve per aggiornare i dati in caso di modifica di ciò che è specificato
  @override
  void didUpdateWidget(covariant SampleFlightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flightDetails != oldWidget.flightDetails) {
      final flight = widget.flightDetails;
      if (flight == null) return;
      setState(() {
        outDate = flight.outboundDateTime;
        inDate = flight.returnDateTime;
        outDetail = flight.outboundDetails;
        inDetail = flight.returnDetails;
        outIata = flight.departureIata;
        inIata = flight.returnIata;
        outCity = flight.departureCity;
        inCity = flight.returnCity;
        outAirport = flight.departureAirport;
        inAirport = flight.returnAirport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        height: MediaQuery.of(context).size.height / 9,
        width: MediaQuery.of(context).size.width / 1.1,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Stack(
          children: [
            budget == null
                ? Container()
                : Padding(
                    //-----------------------------------budget
                    padding: const EdgeInsets.only(right: 5.0, top: 3),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 27,
                        width: 63,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: kColorBudget,
                        ),
                        child: Center(
                          child: Text(
                            '\$$budget',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
            Column(
              children: [
                SizedBox(height: 5),
                //-------------------------------------------testo
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
                SizedBox(height: 5), //--------------------divider
                Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width,
                  color: kColorDivider,
                ),
                SizedBox(height: 5),
                //-----------------------------------riga aeroporiti e date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //----------------------------------------AEROPORTI
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text(
                            outIata ?? '',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.airplanemode_on_sharp, size: 40),
                          SizedBox(width: 5),
                          Text(
                            inIata ?? '',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    //---------------------------------------------DATE
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            outTimeString,
                            style: TextStyle(
                              color: Color(0xCF21373D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            inTimeString,
                            style: TextStyle(
                              color: Color(0xCF21373D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

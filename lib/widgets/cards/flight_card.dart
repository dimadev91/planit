import 'package:plan_it/resource/exports.dart';

class FlightCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  final String? tripId;
  Flight? flightDetails;

  FlightCard({
    this.tripId,
    required this.imageAsset,
    required this.title,
    this.flightDetails,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
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

  String formatDateTime(DateTime dateTime) {
    // 1. Formatta la parte DATA nel formato "dd-MM-yyyy"
    final String data = DateFormat('dd-MM-yy').format(dateTime);

    // 2. Formatta la parte ORA nel formato "HH:mm"
    final String ora = DateFormat('HH:mm').format(dateTime);

    // 3. Ritorna la singola stringa che combina i due risultati con il tuo layout richiesto.
    return 'date: $data \n time:$ora';
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
            budget == null
                ? Container()
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 27,
                      width: 63,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                        outTimeString,
                        style: TextStyle(
                          color: Color(0xCF21373D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.black12, thickness: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        inTimeString,
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
          ],
        ),
      ),
    );
  }
}

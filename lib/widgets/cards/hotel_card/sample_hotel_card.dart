import 'package:plan_it/resource/exports.dart';

class SampleHotelCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  final String? tripId;
  Hotel? hotelDetails;

  SampleHotelCard({
    this.tripId,
    required this.imageAsset,
    required this.title,
    this.hotelDetails,
  });

  @override
  State<SampleHotelCard> createState() => _SampleHotelCardState();
}

class _SampleHotelCardState extends State<SampleHotelCard> {
  bool isSelected = false;
  DateTime? checkIn;
  DateTime? checkOut;
  String? hotelName;
  String hotelLocation = '';
  String? budget;

  String formatDateTime(DateTime dateTime) {
    // 1. Formatta la parte DATA nel formato "dd-MM-yyyy"
    final String data = DateFormat('dd-MMM').format(dateTime);
    final String time = DateFormat('HH:mm').format(dateTime);

    // 3. Ritorna la singola stringa che combina i due risultati con il tuo layout richiesto.
    return '$time, $data';
  }

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotelDetails;
    if (hotel != null) {
      checkIn = hotel.checkIn;
      checkOut = hotel.checkOut;
      hotelName = hotel.hotelName;
      hotelLocation = hotel.hotelLocation ?? '';
      budget = hotel.hotelPrice != null
          ? hotel.hotelPrice!.toStringAsFixed(0)
          : ''; // fallback vuoto se null
    }
  }

  @override
  void didUpdateWidget(covariant SampleHotelCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hotelDetails != oldWidget.hotelDetails) {
      final hotel = widget.hotelDetails;
      if (hotel != null) {
        setState(() {
          checkIn = hotel.checkIn;
          checkOut = hotel.checkOut;
          hotelName = hotel.hotelName;
          hotelLocation = hotel.hotelLocation ?? '';
          budget = hotel.hotelPrice != null
              ? hotel.hotelPrice!.toStringAsFixed(0)
              : '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: MediaQuery.of(context).size.height / 2.4,
        width: MediaQuery.of(context).size.width / 2.3,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Stack(
          children: [
            budget == ''
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 27,
                        width: 63,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                //-----------------------------------------------------divisore
                Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width / 3,
                  color: kColorDivider,
                ),
                Flexible(
                  child: SizedBox(
                    //--------------------serve per fissare la pageview
                    child: PageView(
                      children: [
                        SizedBox(
                          height:
                              300, //--------------------serve per fissare la pageview
                          child: Column(
                            //--------------------------------------prima pagina
                            children: [
                              SizedBox(height: 5),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //--------------------------------immagine
                                      Flexible(
                                        child: Center(
                                          child: Image.asset(widget.imageAsset),
                                        ),
                                      ),
                                      SizedBox(height: 10),

                                      Text(
                                        //--------------------------------HOTEL NAME
                                        hotelName == null ? '' : hotelName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xCF21373D),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        hotelLocation,
                                        style: TextStyle(
                                          color: Color(0xCF21373D),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Center(
                                        child: Text(
                                          checkIn == null
                                              ? ''
                                              : formatDateTime(checkIn!),
                                          style: TextStyle(
                                            color: Color(0xCF21373D),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),

                                      //_------------------CHECK OUT
                                      Center(
                                        child: Text(
                                          checkIn == null
                                              ? ''
                                              : formatDateTime(checkOut!),
                                          style: TextStyle(
                                            color: Color(0xCF21373D),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

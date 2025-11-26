import 'package:plan_it/resource/exports.dart';

class HotelCard extends StatefulWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  final String? tripId;
  Hotel? hotelDetails;

  HotelCard({
    this.tripId,
    required this.imageAsset,
    required this.title,
    this.hotelDetails,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool isSelected = false;
  DateTime? checkIn;
  DateTime? checkOut;
  String? hotelName;
  String hotelLocation = '';
  String? budget;

  String formatDateTime(DateTime dateTime) {
    // 1. Formatta la parte DATA nel formato "dd-MM-yyyy"
    final String data = DateFormat('dd-MM-yy').format(dateTime);

    // 3. Ritorna la singola stringa che combina i due risultati con il tuo layout richiesto.
    return '$data';
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
  void didUpdateWidget(covariant HotelCard oldWidget) {
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
                Flexible(
                  child: SizedBox(
                    //--------------------serve per fissare la pageview
                    child: PageView(
                      children: [
                        SizedBox(
                          height:
                              120, //--------------------serve per fissare la pageview
                          child: Column(
                            //--------------------------------------prima pagina
                            children: [
                              SizedBox(height: 5),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotelName == null ? '' : hotelName!,

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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Center(
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
                                          ),
                                          Container(
                                            height: 10,
                                            width: 2,
                                            color: kColorDivider,
                                          ),
                                          Expanded(
                                            child: Center(
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
                                          ),
                                        ],
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

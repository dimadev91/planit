import 'package:plan_it/resource/exports.dart';

class SaveUpdateHotel extends StatefulWidget {
  final String tripDocId;
  final VoidCallback?
  onDataSaved; // Manteniamo la callback per il refresh esterno

  SaveUpdateHotel({required this.tripDocId, this.onDataSaved});

  @override
  State<SaveUpdateHotel> createState() => _SaveUpdateHotelState();
}

class _SaveUpdateHotelState extends State<SaveUpdateHotel> {
  Hotel? hotelDetails;
  DateTime? checkinDateTime;
  DateTime? checkoutDateTime;
  String? accomodationName;
  String? hotelLocation;
  // bool _mapReady = false;
  Map<String, dynamic>? searchedLocation;
  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController hotelLocationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  MapController mapPickerController = MapController();
  final TextEditingController priceController = TextEditingController();

  Future<void> _loadHotel() async {
    hotelDetails = await Trip.fetchHotelDetails(widget.tripDocId);
    if (hotelDetails != null) {
      checkinDateTime = hotelDetails!.checkIn;
      checkoutDateTime = hotelDetails!.checkOut;
      hotelNameController.text = hotelDetails!.hotelName ?? '';
      hotelLocationController.text = hotelDetails!.hotelLocation ?? '';
      accomodationName = hotelDetails!.hotelName;
      hotelLocation = hotelDetails!.hotelLocation;
      priceController.text = hotelDetails!.hotelPrice?.toString() ?? '';
    }
    setState(() {}); // aggiorna la UI
  }

  //------------------------------------------------------------------------------
  Future<void> _saveHotelDetails() async {
    if (checkinDateTime == null &&
        checkoutDateTime == null &&
        hotelNameController.text.trim().isEmpty &&
        hotelLocationController.text.trim().isEmpty &&
        priceController.text.trim().isEmpty) {
      print("Nessun dato volo da salvare o modificare. Chiudo il Dialog.");
      Navigator.pop(context);
      return;
    }

    // 1. Crea l'oggetto Hotel
    final hotel = Hotel(
      checkIn: checkinDateTime,
      hotelName: hotelNameController.text.trim().isEmpty
          ? null
          : hotelNameController.text,
      checkOut: checkoutDateTime,
      hotelLocation: hotelLocationController.text.trim().isEmpty
          ? null
          : hotelLocationController.text,
      hotelPrice: priceController.text.trim().isEmpty
          ? null
          : double.tryParse(priceController.text),
    );

    // 2. la mappa da salvare
    final hotelMap = hotel.toMap();

    // 3. Aggiorna il documento Trip in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripDocId) // Usa l'ID del viaggio ricevuto
          .update({
            'hotel': hotelMap, // Salva la Mappa 'hotel' nel documento Trip
          });
      print("✅ Hotel updated successfully.");

      // ✅ CHIAMATA DI CALLBACK: Chiamiamo il refresh della schermata padre
      if (widget.onDataSaved != null) {
        widget.onDataSaved!();
      }
    } catch (e) {
      print("!!! Error during hotel update: $e");
    }
  }

  String _formattaPlacemark(Placemark p) {
    final city = p.locality ?? '';
    final street = p.street ?? '';

    // street spesso è già "via + civico", quindi basta dividere
    final parts = street.split(',');
    final onlyStreet = parts.first.trim();

    return "$onlyStreet, $city";
  }

  // ---------------------------------------------------------------------------Funzione di Geocoding per la Ricerca
  Future<void> searchLocation(
    String query,
    BuildContext context, {
    String? hotelName,
  }) async {
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No results found.')));
        }
        return;
      }

      final loc = locations.first;
      final placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );

      String formattedAddress = placemarks.isNotEmpty
          ? _formattaPlacemark(placemarks.first)
          : query;

      // Se vuoi includere anche il nome dell’hotel
      if (hotelName != null && hotelName.isNotEmpty) {
        formattedAddress = '$hotelName, $formattedAddress';
      }

      // aggiorno la mappa
      mapPickerController.move(LatLng(loc.latitude, loc.longitude), 16);

      // salvo per il bottone
      searchedLocation = {
        'lat': loc.latitude,
        'lon': loc.longitude,
        'adress': formattedAddress,
      };
      hotelLocation = formattedAddress;
      accomodationName = query;
      setState(() {}); // aggiorna la UI del dialog
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  //----------------------------------------------------------------------------MAPPA
  void openMapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          //--------------------------------------------------------------------contenitore esterno
          child: Container(
            height: 350,
            width: 340,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Container(
                  //------------------------------------------------------------contenitore interno
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xFF7D9EA2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: SizedBox(
                          height: 300,
                          width: 300,
                          child: FlutterMap(
                            mapController: mapPickerController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                41.9027835,
                                12.4963655,
                              ), // Roma
                              initialZoom: 14.0,
                              onMapReady: () {
                                setState(() {
                                  // _mapReady = true;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                // Questo è l'URL per le tessere di OpenStreetMap, gratuito
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.plan_it',
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                child: Card(
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search for your accomadation',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) async {
                                        accomodationName = searchController
                                            .text; // aggiorno sempre
                                        setState(
                                          () {},
                                        ); // forza aggiornamento UI

                                        await searchLocation(
                                          searchController.text,
                                          context,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // 2. Livello delle Tessere (Mappa Base)

                              // 3. L'Icona Fissa al Centro dello Schermo
                              const Center(
                                child: Icon(
                                  Icons.location_pin,
                                  size: 45,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  //-----------------------------------------------------------BOTTONE CHIUSURA
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          //----------------------------------------botton search
                          child: GestureDetector(
                            onTap: () async {
                              accomodationName =
                                  searchController.text; // aggiorno sempre
                              setState(() {});

                              await searchLocation(
                                searchController.text,
                                context,
                              );
                            },

                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5AD2B),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                ),
                              ),
                              width: double.infinity,
                              height: 45,
                              child: const Center(
                                child: Icon(Icons.search, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 2, height: 45, color: Colors.white),
                        Expanded(
                          //-----------------------------------------bottone chiusura
                          child: GestureDetector(
                            onTap: () async {
                              accomodationName =
                                  searchController.text; // aggiorno sempre
                              setState(() {});
                              await searchLocation(
                                searchController.text,
                                context,
                              );
                              Navigator.of(context).pop();

                              final locToUse =
                                  searchedLocation?['adress'] ?? '';
                              hotelLocationController.text = locToUse;
                              hotelNameController.text = accomodationName ?? '';
                              hotelLocation = locToUse;
                              accomodationName = accomodationName ?? '';

                              setState(() {});
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5AD2B),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              width: double.infinity,
                              height: 45,
                              child: const Center(
                                child: Icon(Icons.check, color: Colors.white),
                              ),
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
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHotel();
  }

  @override
  Widget build(BuildContext context) {
    // // Mostra il caricamento mentre il Dialog fa il fetch
    // if (_isLoading) {
    //   return const Center(
    //     child: CircularProgressIndicator(color: Colors.white),
    //   );
    // }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: 310,
                  decoration: BoxDecoration(
                    //------------------------------------------------------------colore di sfondo
                    color: const Color(0xFF7E9FA3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF0D2025),
                      width: 0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      //------------------------------------------------------------prima sezione
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              openMapDialog();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              width: 290,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            SizedBox(height: 10),

                            //-------------------------------------------------TITOLO/VIA
                            IgnorePointer(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 50,
                                      right: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.local_hotel_outlined,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          accomodationName ??
                                              hotelDetails?.hotelName ??
                                              'Hotel\'s name',
                                          style: kDialogTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ), //---------------------------------------------STREET
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 55,
                                      right: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_sharp,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          hotelLocationController.text.isEmpty
                                              ? 'Street\'s name'
                                              : hotelLocationController.text,
                                          style: kDialogTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //----------------------------------------------------DATE
                            SizedBox(height: 25),
                            Container(
                              height: 2,
                              width: 210,
                              color: Color(0xFF9AB5B9),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  //----------------------------------------------CHECK-IN
                                  child: GestureDetector(
                                    onTap: () async {
                                      final selectedDate =
                                          await showOmniDateTimePicker(
                                            initialDate: checkinDateTime,
                                            context: context,
                                            is24HourMode: true,
                                          );
                                      if (selectedDate != null) {
                                        checkinDateTime = selectedDate;
                                      }
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 3,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'check-in',
                                            style: kDialogTextStyle,
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            height: 70,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF9AB5B9),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                top: 12,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    checkinDateTime == null
                                                        ? 'date: --/--/--\n'
                                                              'time: --:--'
                                                        : 'date: ${DateFormat('dd/MM/yy').format(checkinDateTime!)}\n'
                                                              'time: ${DateFormat('HH:mm').format(checkinDateTime!)}',
                                                    style: kDialogTextStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final selectedDate =
                                          await showOmniDateTimePicker(
                                            initialDate: checkoutDateTime,
                                            context: context,
                                            is24HourMode: true,
                                          );
                                      if (selectedDate != null) {
                                        checkoutDateTime = selectedDate;
                                      }
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 10,
                                        left: 3,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'check-out',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            height: 70,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF9AB5B9),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15.0,
                                                top: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    checkoutDateTime == null
                                                        ? 'date: --/--/--\n'
                                                              'time: --:--'
                                                        : 'date: ${DateFormat('dd/MM/yy').format(checkoutDateTime!)}\n'
                                                              'time: ${DateFormat('HH:mm').format(checkoutDateTime!)}',
                                                    style: kDialogTextStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ), //-----------------------------------------------BUDGET
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.attach_money_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 80,
                                  child: TextField(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    controller: priceController,
                                    decoration: kTextFieldAdd.copyWith(
                                      hintText: priceController.text.isEmpty
                                          ? 'price'
                                          : priceController.text,
                                      contentPadding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                    ),
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //--------------------------------------------------------CONFERMA button
                          GestureDetector(
                            onTap: () async {
                              await _saveHotelDetails();
                              if (!mounted)
                                return; // se il widget è già smontato non fare nulla
                              await _loadHotel();
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5AD2B),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              width: double.infinity,
                              height: 45,
                              child: const Center(
                                child: Text(
                                  'CONFIRM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
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
        ],
      ),
    );
  }
}

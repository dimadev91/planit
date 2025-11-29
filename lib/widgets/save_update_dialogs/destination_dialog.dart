import 'dart:async';

import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/destination_firestore.dart';

class DestinationDialog extends StatefulWidget {
  final String tripDocId;
  final VoidCallback?
  onDataSaved; // Manteniamo la callback per il refresh esterno

  DestinationDialog({required this.tripDocId, this.onDataSaved});

  @override
  State<DestinationDialog> createState() => _DestinationDialogState();
}

class _DestinationDialogState extends State<DestinationDialog> {
  Destination? destinationDetails;
  final Destination newDestination = Destination();
  String? cityName;
  String? countryName;
  Map<String, dynamic>? searchedLocation;
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  MapController mapPickerController = MapController();

  // Future<void> _loadDestination() async {
  //   destinationDetails = await Trip.fetchDestinationDetails(widget.tripDocId);
  //   if (destinationDetails != null) {
  //     cityNameController.text = destinationDetails!.cityName ?? '';
  //     countryNameController.text = destinationDetails!.countryName ?? '';
  //   }
  //   setState(() {}); // aggiorna la UI
  // }

  void emptyAllFields() {
    cityNameController.clear();
    countryNameController.clear();
  }

  Future<void> saveUpdateDestination() async {
    await Destination.saveUpdateDestination(
      cityNameController.text,
      countryNameController.text,
      widget.tripDocId,
      context,
    );
    if (widget.onDataSaved != null) {
      widget.onDataSaved!();
    }
  }

  //----------------------------------------------------------------------------MAPPA
  void openMapDialog() async {
    //-------------------------------------------assegnamo il valore dei risultati della mappa e poi elaboriamo la funzione if per assegnarli alle variabile del widget dialog
    final Map<String, dynamic>? result =
        await showDialog<Map<String, dynamic>?>(
          context: context,
          builder: (context) {
            return MapDialog(
              location: cityNameController.text.isEmpty
                  ? null
                  : cityNameController.text,
              title: countryNameController.text.isEmpty
                  ? null
                  : countryNameController.text,
              searchedLocation: searchedLocation,
              locationController: cityNameController,
            );
          },
        );
    // 2. Se il risultato è valido, AGGIORNA lo stato locale del genitore
    if (result != null) {
      setState(() {
        cityNameController.text = result['city'] ?? '';
        countryNameController.text = result['country'] ?? '';
        cityName = result['address'];
        searchedLocation = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadDestination();
  }

  @override
  void dispose() {
    cityNameController.dispose();
    countryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                  color: Colors
                      .transparent, //--------------------------------dimensioni dialog
                  child: Container(
                    width: 240,
                    height: 160,
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
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            //----------------------------------------wrap per aprire la mappa
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
                          padding: EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10),

                              //---------------------------------------------------CITY
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
                                            Icons.place_sharp,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 17),
                                          Text(
                                            cityNameController.text.isEmpty
                                                ? 'City\' name'
                                                : cityNameController.text,
                                            style: kDialogTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ), //---------------------------------------------COUNTRY
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
                                            Icons.map_outlined,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            countryNameController.text.isEmpty
                                                ? 'Country\' name'
                                                : countryNameController.text,
                                            style: kDialogTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //--------------------------------------------------BUTTONS
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                children: [
                                  Expanded(
                                    //------------------------------------------- bottone add new
                                    child: GestureDetector(
                                      onTap: () async {
                                        emptyAllFields();
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
                                          child: Text(
                                            'ADD NEW',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 45,
                                    color: Colors.white,
                                  ),

                                  //----------------------------------------------bottone confirm
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await saveUpdateDestination();
                                        if (!mounted)
                                          return; // se il widget è già smontato non fare nulla
                                        // await _loadDestination();
                                        Navigator.pop(context);
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
                                  ),
                                ],
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
    );
  }
}

import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/widgets/timeline.dart';

class SaveUpdateActivity extends StatefulWidget {
  final String? tripDocId;
  final VoidCallback? onDataSaved;
  final TimelineEvent? existingEvent; // <-- nuovo parametro

  SaveUpdateActivity({this.tripDocId, this.onDataSaved, this.existingEvent});

  @override
  State<SaveUpdateActivity> createState() => _SaveUpdateActivityState();
}

class _SaveUpdateActivityState extends State<SaveUpdateActivity> {
  DateTime? activityTime;
  String? activityTitle;
  String? activityLocation;
  String? activityPeriod;
  Map<String, dynamic>? searchedLocation;
  String? activityPrice;

  final TextEditingController activityTitleController = TextEditingController();
  final TextEditingController activityLocationController =
      TextEditingController();
  final TextEditingController searchController = TextEditingController();
  MapController mapPickerController = MapController();
  final TextEditingController priceController = TextEditingController();

  Future<void> _loadActivity() async {
    if (widget.existingEvent != null) {
      // Inizializza dai dati dell'evento esistente (EDIT)
      final e = widget.existingEvent!;
      activityTime = e.datetime;
      activityTitleController.text = e.title;
      activityLocationController.text = e.description!;
      activityTitle = e.title;
      activityLocation = e.description;
      priceController.text = e.price?.toString() ?? '';
      activityPeriod = e.duration;
    }
    // Rimosso il vecchio blocco 'else if' per caricare una singola Activity.
    // Se existingEvent è null, è una nuova Activity (ADD), quindi non si carica nulla.
    setState(() {});
  }

  Future<void> _saveActivityDetails() async {
    // Fallback per la location
    String finalLocation =
        (searchedLocation != null &&
            (searchedLocation!['adress']?.isNotEmpty ?? false))
        ? searchedLocation!['adress']
        : activityLocationController.text;

    // Creo l'oggetto Activity
    final newActivity = Activity(
      activityTime: activityTime,
      activityName: activityTitleController.text.trim().isEmpty
          ? null
          : activityTitleController.text,
      activityLocation: finalLocation.trim().isEmpty ? null : finalLocation,
      activityPrice: priceController.text.trim().isEmpty
          ? null
          : double.tryParse(priceController.text),
      activityDuration: activityPeriod == null
          ? null
          : double.tryParse(activityPeriod!),
    );

    // Trasforma in mappa, convertendo activityTime in Timestamp
    final activityMap = newActivity.toMap();
    if (activityMap['activityTime'] is DateTime) {
      activityMap['activityTime'] = Timestamp.fromDate(
        activityMap['activityTime'],
      );
    }

    try {
      if (widget.tripDocId != null) {
        final tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripDocId);
        final doc = await tripRef.get();

        if (doc.exists) {
          final docData = doc.data() as Map<String, dynamic>?;
          List existingActivities = [];
          if (docData != null && docData.containsKey('activities')) {
            existingActivities = List.from(docData['activities']);
          }

          if (widget.existingEvent != null) {
            final index = existingActivities.indexWhere((a) {
              final aTime = a['activityTime'];
              if (aTime is Timestamp) {
                return aTime.toDate() == widget.existingEvent!.datetime &&
                    a['activityName'] == widget.existingEvent!.title;
              } else if (aTime is DateTime) {
                return aTime == widget.existingEvent!.datetime &&
                    a['activityName'] == widget.existingEvent!.title;
              } else if (aTime is String) {
                return DateTime.tryParse(aTime) ==
                        widget.existingEvent!.datetime &&
                    a['activityName'] == widget.existingEvent!.title;
              }
              return false;
            });

            if (index != -1) {
              existingActivities[index] = activityMap;
            } else {
              existingActivities.add(activityMap);
            }
          } else {
            existingActivities.add(activityMap);
          }

          await tripRef.update({'activities': existingActivities});
          print("✅ Activity saved/updated successfully.");
        }
      } else {
        await FirebaseFirestore.instance.collection('trips').add({
          'activities': [activityMap],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ New trip created with activity.");
      }

      if (widget.onDataSaved != null) widget.onDataSaved!();
      Navigator.pop(context);
    } catch (e) {
      print("!!! Error during activity save: $e");
      Navigator.pop(context); // chiude comunque il dialog
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
    String? activityName,
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

      // Se vuoi includere anche il nome dell’attività
      if (activityName != null && activityName.isNotEmpty) {
        formattedAddress = '$activityName, $formattedAddress';
      }

      // aggiorno la mappa
      mapPickerController.move(LatLng(loc.latitude, loc.longitude), 16);

      // salvo per il bottone
      searchedLocation = {
        'lat': loc.latitude,
        'lon': loc.longitude,
        'adress': formattedAddress,
      };
      activityLocation = formattedAddress;
      activityTitle = query;
      setState(() {}); // aggiorna la UI del dialog
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  // Aggiungi questa funzione dentro _SaveUpdateActivityState
  Future<void> _deleteActivity() async {
    if (widget.tripDocId == null || widget.existingEvent == null) return;

    try {
      final tripRef = FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripDocId);
      final doc = await tripRef.get();

      if (doc.exists) {
        List existingActivities = List.from(doc['activities'] ?? []);

        // Confronta usando Timestamp invece di stringa
        existingActivities.removeWhere((a) {
          final aTime = a['activityTime'];
          if (aTime is Timestamp) {
            return aTime.toDate() == widget.existingEvent!.datetime &&
                a['activityName'] == widget.existingEvent!.title;
          } else if (aTime is String) {
            return DateTime.tryParse(aTime) == widget.existingEvent!.datetime &&
                a['activityName'] == widget.existingEvent!.title;
          }
          return false;
        });

        await tripRef.update({'activities': existingActivities});
      }

      if (widget.onDataSaved != null) widget.onDataSaved!();

      Navigator.pop(context);
      print("✅ Activity deleted successfully.");
    } catch (e) {
      print("!!! Error during activity deletion: $e");
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
                                setState(() {});
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
                                        hintText: 'Search for your destination',

                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) async {
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
                  //-----------------------------------------------------------BOTTONI CHIUSURA
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          //----------------------------------------------bottone ricerca
                          child: GestureDetector(
                            onTap: () async {
                              // CHIAMA LA FUNZIONE DI RICERCA
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
                          //------------------------------------------- bottone chiusura
                          child: GestureDetector(
                            onTap: () async {
                              // Chiudo il dialog
                              Navigator.of(context).pop();

                              // Se la ricerca ha funzionato, uso searchedLocation; altrimenti testo del controller
                              final locToUse =
                                  searchedLocation?['adress'] ??
                                  activityLocationController.text;

                              // Aggiorno il controller principale
                              activityLocationController.text = locToUse;

                              // Aggiorno variabile interna
                              activityLocation = locToUse;

                              setState(() {});
                              print(activityLocationController.text);
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
  @override
  void initState() {
    super.initState();
    _loadActivity();
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
                  height: 300,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            SizedBox(height: 10),

                            //-------------------------------------------------TITOLO/VIA
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32,
                                    right: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.directions_run_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        height: 40,
                                        width: 140,
                                        child: TextField(
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          controller: activityTitleController,
                                          decoration: kTextFieldAdd.copyWith(
                                            hintText: 'Activity\'s title',

                                            contentPadding:
                                                const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                          ),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ), //---------------------------------------------STREET
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 40,
                                    right: 5,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      openMapDialog();
                                    },
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
                                        SizedBox(
                                          height: 30,
                                          width: 160,
                                          child: Text(
                                            activityLocationController
                                                    .text
                                                    .isEmpty
                                                ? 'Location'
                                                : activityLocationController
                                                      .text,
                                            style: kDialogTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //----------------------------------------------------DATE
                            SizedBox(height: 10),
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
                                  //----------------------------------------------STARTING TIME
                                  child: GestureDetector(
                                    onTap: () async {
                                      final selectedDate =
                                          await showOmniDateTimePicker(
                                            initialDate: activityTime,
                                            context: context,
                                            is24HourMode: true,
                                          );
                                      if (selectedDate != null) {
                                        activityTime = selectedDate;
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
                                            'Activity\'s starting time',
                                            style: kDialogTextStyle,
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () async {
                                              final selectedDate =
                                                  await showOmniDateTimePicker(
                                                    initialDate: activityTime,
                                                    context: context,
                                                    is24HourMode: true,
                                                  );
                                              if (selectedDate != null) {
                                                activityTime = selectedDate;
                                              }
                                              setState(() {});
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(width: 45),
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  activityTime == null
                                                      ? 'date: --/--/--\n'
                                                            'time: --:--'
                                                      : 'date: ${DateFormat('dd/MM/yy').format(activityTime!)}\n'
                                                            'time: ${DateFormat('HH:mm').format(activityTime!)}',
                                                  style: kDialogTextStyle,
                                                ),
                                              ],
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
                          widget.existingEvent != null
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await _deleteActivity();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5AD2B),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(25),
                                          ),
                                        ),
                                        width: 155,
                                        height: 45,
                                        child: const Center(
                                          child: Text(
                                            'DELETE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 45,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await _saveActivityDetails();
                                        if (!mounted) return;
                                        _loadActivity();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5AD2B),
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(25),
                                          ),
                                        ),
                                        width: 155,
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
                                )
                              : GestureDetector(
                                  //-----------------------------senza delete
                                  onTap: () async {
                                    await _saveActivityDetails();
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

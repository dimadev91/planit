import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/timeline_event_class.dart';

class SaveUpdateFood extends StatefulWidget {
  final String? tripDocId;
  final VoidCallback? onDataSaved;
  final TimelineEvent? existingEvent; // <-- nuovo parametro

  SaveUpdateFood({this.tripDocId, this.onDataSaved, this.existingEvent});

  @override
  State<SaveUpdateFood> createState() => _SaveUpdateFoodState();
}

class _SaveUpdateFoodState extends State<SaveUpdateFood> {
  List<Food>? foodDetails;
  DateTime? restTime;
  String? restTitle;
  String? activityLocation;
  Map<String, dynamic>? searchedLocation;
  String? restRangePrice;

  final TextEditingController activityTitleController = TextEditingController();
  final TextEditingController activityLocationController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();
  //-----------------------------------------------------------------------load dati se ci sono aggiorna ui
  Future<void> _loadActivity() async {
    if (widget.existingEvent != null) {
      // inizializza dai dati dell'evento esistente
      final e = widget.existingEvent!;
      restTime = e.datetime;
      activityTitleController.text = e.title;
      activityLocationController.text = e.description ?? '';
      priceController.text = e.price?.toString() ?? '';
    } else {
      // nuovo evento: resetta tutto
      restTime = null;
      activityTitleController.clear();
      activityLocationController.clear();
      priceController.clear();
      searchedLocation = null;
    }

    setState(() {});
  }

  //---------------------------------------------------------------------------funzione aggiorna crea
  Future<void> _saveActivityDetails() async {
    // Fallback per la location
    String finalLocation =
        (searchedLocation != null &&
            (searchedLocation!['adress']?.isNotEmpty ?? false))
        ? searchedLocation!['adress']
        : activityLocationController.text;

    // Creo l'oggetto Activity
    final newFood = Food(
      restTime: restTime,
      restName: activityTitleController.text.trim().isEmpty
          ? null
          : activityTitleController.text,
      restLocation: finalLocation.trim().isEmpty ? null : finalLocation,
      restPriceRange: priceController.text.trim().isEmpty
          ? null
          : double.tryParse(priceController.text),
    );

    // Trasforma in mappa, convertendo restTime in Timestamp
    final activityMap = newFood.toMap();
    if (activityMap['restTime'] is DateTime) {
      activityMap['restTime'] = Timestamp.fromDate(activityMap['restTime']);
    }

    try {
      if (widget.tripDocId != null) {
        final tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripDocId);
        final doc = await tripRef.get();

        if (doc.exists) {
          final docData = doc.data();
          List existingFood = [];
          if (docData != null && docData.containsKey('food')) {
            existingFood = List.from(docData['food']);
          }

          if (widget.existingEvent != null) {
            final index = existingFood.indexWhere((a) {
              final aTime = a['restTime'];
              if (aTime is Timestamp) {
                return aTime.toDate() == widget.existingEvent!.datetime &&
                    a['restName'] == widget.existingEvent!.title;
              } else if (aTime is DateTime) {
                return aTime == widget.existingEvent!.datetime &&
                    a['restName'] == widget.existingEvent!.title;
              } else if (aTime is String) {
                return DateTime.tryParse(aTime) ==
                        widget.existingEvent!.datetime &&
                    a['restName'] == widget.existingEvent!.title;
              }
              return false;
            });

            if (index != -1) {
              existingFood[index] = activityMap;
            } else {
              existingFood.add(activityMap);
            }
          } else {
            existingFood.add(activityMap);
          }

          await tripRef.update({'food': existingFood});
          print("✅ Food saved/updated successfully.");
        }
      } else {
        await FirebaseFirestore.instance.collection('trips').add({
          'food': [activityMap],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ New food created with activity.");
      }

      if (widget.onDataSaved != null) widget.onDataSaved!();
      Navigator.pop(context);
    } catch (e) {
      print("!!! Error during food save: $e");
      Navigator.pop(context); // chiude comunque il dialog
    }
  }

  // ---------------------------------------------------------------------------funzione elimina
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
          final aTime = a['restTime'];
          if (aTime is Timestamp) {
            return aTime.toDate() == widget.existingEvent!.datetime &&
                a['restName'] == widget.existingEvent!.title;
          } else if (aTime is String) {
            return DateTime.tryParse(aTime) == widget.existingEvent!.datetime &&
                a['restName'] == widget.existingEvent!.title;
          }
          return false;
        });

        await tripRef.update({'food': existingActivities});
      }

      if (widget.onDataSaved != null) widget.onDataSaved!();

      Navigator.pop(context);
      print("✅ food deleted successfully.");
    } catch (e) {
      print("!!! Error during food deletion: $e");
    }
  }

  //----------------------------------------------------------------------------MAPPA
  void openMapDialog() async {
    final Map<String, dynamic>? result =
        await showDialog<Map<String, dynamic>?>(
          context: context,
          builder: (context) {
            return MapDialog(
              // Passiamo solo i dati attuali al dialogo
              activityLocation: activityLocationController.text.isEmpty
                  ? null
                  : activityLocationController.text,
              activityTitle: activityTitleController.text.isEmpty
                  ? null
                  : activityTitleController.text,
              searchedLocation: searchedLocation,
              activityLocationController: activityLocationController,
            );
          },
        );

    // 2. Se il risultato è valido, AGGIORNA lo stato locale del genitore
    if (result != null && result.containsKey('adress')) {
      setState(() {
        searchedLocation = result;
        // Aggiorna il controller di testo locale per aggiornare la UI
        activityLocationController.text = result['adress'];
        activityLocation =
            result['adress']; // Aggiorna anche la variabile di stato per coerenza
      });
    }
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
                                        Icons.restaurant,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        height: 40,
                                        width: 210,
                                        child: TextField(
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          controller: activityTitleController,
                                          decoration: kTextFieldAdd.copyWith(
                                            hintText: 'Where you want to eat?',

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
                                            initialDate: restTime,
                                            context: context,
                                            is24HourMode: true,
                                          );
                                      if (selectedDate != null) {
                                        restTime = selectedDate;
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
                                            'Insert here date and time!',
                                            style: kDialogTextStyle,
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () async {
                                              final selectedDate =
                                                  await showOmniDateTimePicker(
                                                    initialDate: restTime,
                                                    context: context,
                                                    is24HourMode: true,
                                                  );
                                              if (selectedDate != null) {
                                                restTime = selectedDate;
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
                                                  restTime == null
                                                      ? 'date: --/--/--\n'
                                                            'time: --:--'
                                                      : 'date: ${DateFormat('dd/MM/yy').format(restTime!)}\n'
                                                            'time: ${DateFormat('HH:mm').format(restTime!)}',
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
                                  width: 60,
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

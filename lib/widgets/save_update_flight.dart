import 'package:plan_it/resource/exports.dart';

class SaveUpdateFlights extends StatefulWidget {
  final String tripDocId;
  final VoidCallback?
  onDataSaved; // Manteniamo la callback per il refresh esterno

  // Non accettiamo più initialFlight, carichiamo i dati internamente.
  SaveUpdateFlights({required this.tripDocId, this.onDataSaved});

  @override
  State<SaveUpdateFlights> createState() => _SaveUpdateFlightsState();
}

class _SaveUpdateFlightsState extends State<SaveUpdateFlights> {
  bool isVisible = false;

  // STATO PER IL CARICAMENTO INTERNO DEL DIALOG
  bool _isLoading = true;

  // Dati del volo che saranno caricati e poi modificati
  DateTime? outboundDateTime;
  DateTime? returnDateTime;

  final TextEditingController outboundDetailsController =
      TextEditingController();
  final TextEditingController returnDetailsController = TextEditingController();
  final TextEditingController budgetOutbound = TextEditingController();
  final TextEditingController budgetReturn = TextEditingController();

  //---------------------------------------------------------------------formattazione data e orario
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  //----------------------------------------------------------------------METODO PER IL FETCH INTERNO
  Future<void> _fetchInitialFlight() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Scarica l'intero documento Trip
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripDocId)
          .get();

      if (doc.exists && doc.data() != null) {
        final tripData = doc.data() as Map<String, dynamic>;

        // 2. Estrai solo l'oggetto Flight (potrebbe essere null)
        final flightMap = tripData['flight'] as Map<String, dynamic>?;

        if (flightMap != null) {
          final initialFlightDetails = Flight.fromMap(flightMap);

          // 3. Pre-popola lo stato del Dialog
          outboundDateTime = initialFlightDetails.outboundDateTime;
          returnDateTime = initialFlightDetails.returnDateTime;

          if (initialFlightDetails.outboundDetails != null) {
            outboundDetailsController.text =
                initialFlightDetails.outboundDetails!;
          }
          if (initialFlightDetails.returnDetails != null) {
            returnDetailsController.text = initialFlightDetails.returnDetails!;
          }
          if (initialFlightDetails.outboundPrice != null) {
            budgetOutbound.text = initialFlightDetails.outboundPrice.toString();
          }
          if (initialFlightDetails.returnPrice != null) {
            budgetReturn.text = initialFlightDetails.returnPrice.toString();
          }
        }
      }
    } catch (e) {
      print("Errore nel fetch iniziale del volo: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //------------------------------------------------------------------------------
  Future<void> _saveFlightDetails() async {
    if (outboundDateTime == null &&
        returnDateTime == null &&
        outboundDetailsController.text.trim().isEmpty &&
        returnDetailsController.text.trim().isEmpty &&
        budgetOutbound.text.trim().isEmpty &&
        budgetReturn.text.trim().isEmpty) {
      print("Nessun dato volo da salvare o modificare. Chiudo il Dialog.");
      Navigator.pop(context);
      return;
    }

    // 1. Crea l'oggetto Flight
    final flight = Flight(
      outboundDateTime: outboundDateTime,
      outboundDetails: outboundDetailsController.text.trim().isEmpty
          ? null
          : outboundDetailsController.text,
      returnDateTime: returnDateTime,
      returnDetails: returnDetailsController.text.trim().isEmpty
          ? null
          : returnDetailsController.text,
      outboundPrice: budgetOutbound.text.trim().isEmpty
          ? null
          : double.tryParse(budgetOutbound.text),
      returnPrice: budgetReturn.text.trim().isEmpty
          ? null
          : double.tryParse(budgetReturn.text),
    );

    // 2. Ottieni la mappa da salvare
    final flightMap = flight.toMap();

    // 3. Aggiorna il documento Trip in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripDocId) // Usa l'ID del viaggio ricevuto
          .update({
            'flight': flightMap, // Salva la Mappa 'flight' nel documento Trip
          });
      print("✅ Dettagli Volo salvati/aggiornati con successo.");

      // ✅ CHIAMATA DI CALLBACK: Chiamiamo il refresh della schermata padre
      if (widget.onDataSaved != null) {
        widget.onDataSaved!();
      }

      // Chiudi la finestra dopo il salvataggio
      Navigator.pop(context);
    } catch (e) {
      print("!!! Errore durante il salvataggio dei dettagli volo: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Avvia il fetch dei dati del volo non appena il Dialog si apre
    _fetchInitialFlight();
  }

  // Pulizia delle risorse
  @override
  void dispose() {
    outboundDetailsController.dispose();
    returnDetailsController.dispose();
    budgetOutbound.dispose();
    budgetReturn.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------CALENDARIO overlay

  @override
  Widget build(BuildContext context) {
    // Mostra il caricamento mentre il Dialog fa il fetch
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
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
                  height: 430,
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
                      Column(
                        children: [
                          SizedBox(height: 150),
                          Container(
                            color: Colors.black.withOpacity(0.1),
                            height: 2,
                            width: double.infinity,
                          ),
                          SizedBox(height: 190),
                          Container(
                            color: Colors.black.withOpacity(0.1),
                            height: 2,
                            width: double.infinity,
                          ),
                        ],
                      ),
                      //------------------------------------------------------------prima sezione
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF9AB5B9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        width: double.infinity,
                        height: 45,
                      ),
                      //---------------------------------------------------------seconda sezione
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF9AB5B9),
                            ),
                            width: double.infinity,
                            height: 45,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 60, top: 7),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flight_takeoff,
                              color: Colors.black.withOpacity(0.3),
                              size: 30,
                            ),
                            SizedBox(height: 20),
                            Icon(
                              Icons.date_range_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 28),
                            Icon(
                              Icons.design_services,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 56),
                            Icon(
                              Icons.flight_land_rounded,
                              color: Colors.black.withOpacity(0.3),
                              size: 30,
                            ),
                            SizedBox(height: 20),
                            Icon(
                              Icons.date_range_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 24),
                            Icon(
                              Icons.design_services,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 75, right: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: [
                              //-------------------------------------------------ANDATA
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Outbound flight',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.4),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              //----------------------------------------------------DATE
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GestureDetector(
                                  onTap: () async {
                                    final selectedDate =
                                        await showOmniDateTimePicker(
                                          context: context,
                                          is24HourMode: true,
                                        );
                                    if (selectedDate != null) {
                                      outboundDateTime = selectedDate;
                                    }
                                    setState(() {});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 25),
                                      Text(
                                        outboundDateTime == null
                                            ? 'date: --/--/--\n'
                                                  'time: --:--'
                                            : 'date: ${formatDate(outboundDateTime!)}\n'
                                                  'time: ${formatTime(outboundDateTime!)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  SizedBox(
                                    height: 40,
                                    width: 100,

                                    child: TextField(
                                      //--------------------------------------------------dettagli opzionale
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      controller: outboundDetailsController,
                                      decoration: kTextFieldAdd.copyWith(
                                        hintText:
                                            'details (es. number of flight)',
                                      ),

                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 30),
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 70,
                                    child: TextField(
                                      //-----------------------------------------------prezzo andata
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      controller: budgetOutbound,
                                      decoration: kTextFieldAdd.copyWith(
                                        hintText: 'price',
                                        contentPadding: const EdgeInsets.only(
                                          left: 10,
                                          bottom: 10,
                                        ),
                                      ),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              //----------------------------------------------------RITORNO
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 12),
                                    Text(
                                      'Return flight',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.4),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //----------------------------------------------------DATE
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 18,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    final selectedDate =
                                        await showOmniDateTimePicker(
                                          context: context,
                                        );
                                    if (selectedDate != null) {
                                      returnDateTime = selectedDate;
                                    }
                                    setState(() {});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 5),
                                      Text(
                                        returnDateTime == null
                                            ? 'date: --/--/--\n'
                                                  'time: --:--'
                                            : 'date: ${formatDate(returnDateTime!)}\n'
                                                  'time: ${formatTime(returnDateTime!)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  SizedBox(
                                    height: 40,
                                    width: 100,
                                    child: TextField(
                                      //--------------------------------------------------dettagli opzionale
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      controller: returnDetailsController,
                                      decoration: kTextFieldAdd.copyWith(
                                        hintText:
                                            'details (es. number of flight)',
                                      ),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 30),
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 70,
                                    child: TextField(
                                      //-----------------------------------------------prezzo ritorno
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      controller: budgetReturn,
                                      decoration: kTextFieldAdd.copyWith(
                                        hintText: 'price',
                                        contentPadding: const EdgeInsets.only(
                                          left: 10,
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
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //--------------------------------------------------------CONFERMA button
                          GestureDetector(
                            onTap: () async {
                              await _saveFlightDetails();
                              // Navigator.pop è già in _saveFlightDetails
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

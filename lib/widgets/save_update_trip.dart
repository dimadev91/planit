import 'package:plan_it/resource/exports.dart';

class CreationDialog extends StatefulWidget {
  List<DateTime> dates;
  final Future<void> Function()?
  onTripSavedAndRefresh; // opzionale, per aggiornare la lista
  final String currentUserId;
  //--------------------------------------------------servono per rendere disponbile la modifica del trip
  final Trip? tripToEdit;
  final String? docIdToEdit;

  CreationDialog({
    required this.onTripSavedAndRefresh,
    required this.dates,
    required this.currentUserId,
    this.tripToEdit,
    this.docIdToEdit,
  });

  @override
  State<CreationDialog> createState() => _CreationDialogState();
}

class _CreationDialogState extends State<CreationDialog> {
  // Variabili di stato interne (rinominate con underscore)
  List<DateTime> _dates = [];
  bool isCalendarVisible = false;
  String _title = '';
  String _description = '';

  // Variabili relative all'Overlay (Non usate qui, ma lasciate per coerenza del file originale)
  late OverlayEntry _overlayEntry;
  bool isVisible = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Inizializza _dates con le date passate dal widget (dal chiamante)
    _dates = widget.dates;

    // ------------------------------------------------------------------
    // LOGICA DI PRE-COMPILAZIONE: IL BUG È SPESSO QUI
    if (widget.tripToEdit != null) {
      final trip = widget.tripToEdit!;

      // DEVI ASSEGNARE LE VARIABILI DI STATO INTERNE (_title, _description)
      _title = trip.title;
      _description = trip.description ?? ''; // Usa la descrizione salvata

      // Le date dovrebbero essere già qui, ma riassegnare per sicurezza
      _dates = [trip.startDate, trip.endDate];
    }
    // ------------------------------------------------------------------
  }

  OverlayEntry _createOverlayEntry() {
    //--------------------------------------------------------------------------OVERLAY/creation
    return OverlayEntry(
      builder: (context) => Material(
        color: Colors.black38, // sfondo semi-trasparente
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      //-----------------------------------------------------colore contorno
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF7D9EA2),
                    ),
                    height: 410,
                    width: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => showHideOverlay(),
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Material(
                child: SizedBox(
                  width: 345,
                  height: 330,
                  child: Column(
                    children: [
                      Expanded(
                        //----------------------------------------------------------CALENDARIO
                        child: CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            calendarType: CalendarDatePicker2Type.range,
                            selectedDayHighlightColor: Color(0xFFF3AC2B),
                            selectedDayTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            weekdayLabelTextStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: _dates, // Usa la variabile di stato
                          onValueChanged: (value) => setState(
                            () => _dates = value,
                          ), // Usa la variabile di stato
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showHideOverlay() {
    if (!isVisible) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      isVisible = true;
    } else {
      isVisible = false;
      _overlayEntry.remove();
    }
  }

  //----------------------------------------------------------------------------formattazione date
  String _formatDates(List<DateTime> selectedDates) {
    if (selectedDates.isEmpty) {
      return 'Select your dates!';
    }

    // Usiamo il formato giorno/mese/anno
    final formatter = DateFormat('dd/MM/yyyy');

    if (selectedDates.length == 1) {
      return 'Data selezionata: ${formatter.format(selectedDates.first)}';
    }

    // Per il range o multi-picker (ad esempio, le prime due date)
    final start = formatter.format(selectedDates.first);
    final end = formatter.format(selectedDates.last);

    // Mostra il range
    return '$start - $end';
  }

  //----------------------------------------------------------------------------FUNZIONE UPDATE O ADD
  Future<bool> _saveOrUpdateTrip(BuildContext context) async {
    // Costruzione dell'oggetto
    final DateTime startDate = _dates.first;
    final DateTime endDate = _dates.length > 1 ? _dates.last : _dates.first;

    // oggetto Trip
    // senza bisogno di una variabile intermedia aggiuntiva
    final newTrip = Trip(
      title: _title,
      description: _description.isNotEmpty ? _description : null,
      startDate: startDate,
      endDate: endDate,
      userId: widget.currentUserId,
      // ID non necessario qui, sarà usato solo per la query
    );

    //  Logica di Aggiornamento vs Creazione
    try {
      if (widget.docIdToEdit != null) {
        // MODIFICA (UPDATE): Manteniamo l'await
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.docIdToEdit)
            .update(newTrip.toMap());

        return true; // Ritorna true immediatamente
      } else {
        // CREAZIONE (ADD): Usiamo .then() per isolare l'esecuzione
        FirebaseFirestore.instance.collection('trips').add(newTrip.toMap());

        // Dato che abbiamo usato .then, il codice procede subito qui.
        return true; // Forziamo il ritorno true immediatamente
      }
    } catch (e) {
      print('Errore critico in _saveOrUpdateTrip: $e');
      return false;
    }
  }

  void closeOverlay() {
    final overlayProvider = context.read<OverlayProvider>();
    overlayProvider.isVisible = false;
    overlayProvider.notifyListeners(); // serve per far "sentire" il cambiamento
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/svg/valigia.svg', height: 60),
        SizedBox(
          height: 15,
        ), //-----------------------------------------------------pop up title
        Text(
          widget.docIdToEdit != null ? 'Modify your trip' : 'Plan a new trip',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        SizedBox(height: 20),
        Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              //------------------------------------------------------------colore di sfondo
              color: Color(0xFF7E9FA3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Color(0xFF0D2025), width: 0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 45, right: 40),
                  child: Column(
                    children: [
                      //-------------------------------------------------TITOLO
                      TextField(
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: kTextFieldAdd.copyWith(
                          prefixIcon: Icon(
                            Icons.place_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          hintText: widget.docIdToEdit != null
                              ? _title
                              : 'Your trip\'s title',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _title =
                                value; // Usa la variabile di stato corretta
                          });
                        },
                      ),
                      //--------------------------------------------------divisorio1
                      Container(
                        height: 1,
                        color: Color(0xBE061215),
                        width: 250,
                      ),
                      //--------------------------------------------------DESCRIZIONE
                      TextField(
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: kTextFieldAdd.copyWith(
                          prefixIcon: Icon(
                            Icons.note_alt_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          hintText: widget.docIdToEdit != null
                              ? _description
                              : 'Description (optional)',
                        ),
                        onChanged: (value) {
                          // AGGIUNTO onChanged per la descrizione
                          setState(() {
                            _description =
                                value; // Collega l'input alla variabile
                          });
                        },
                      ),
                      //--------------------------------------------------divisorio2
                      Container(
                        height: 1,
                        color: Color(0xBE061215),
                        width: 250,
                      ),
                      //----------------------------------------------------DATE
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: GestureDetector(
                          onTap: () {
                            // La funzione _showCalendarPicker è chiamata qui
                            showHideOverlay();
                            setState(() {
                              isCalendarVisible = true;
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                // Correzione dell'Overflow
                                child: Text(
                                  _formatDates(
                                    _dates,
                                  ), // Usa la variabile di stato corretta
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //--------------------------------------------------------CONFERMA button
                    GestureDetector(
                      onTap: () async {
                        final success = await _saveOrUpdateTrip(context);
                        if (success) {
                          await widget.onTripSavedAndRefresh
                              ?.call(); // ricarica lista
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5AD2B),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        width: double.infinity,
                        height: 45,
                        child: Center(
                          child: Text(
                            'CONFIRM',
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
    );
  }
}

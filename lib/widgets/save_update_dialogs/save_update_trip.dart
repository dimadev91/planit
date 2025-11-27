import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/widgets/calendare_range.dart';

class saveUpdateTripDialog extends StatefulWidget {
  List<DateTime> dates;
  final Future<void> Function()? onTripSavedAndRefresh; // aggiornare la lista
  final String currentUserId;
  final Trip? tripSelected;

  saveUpdateTripDialog({
    required this.onTripSavedAndRefresh,
    required this.dates,
    required this.currentUserId,
    this.tripSelected,
  });

  @override
  State<saveUpdateTripDialog> createState() => _saveUpdateTripDialogState();
}

class _saveUpdateTripDialogState extends State<saveUpdateTripDialog> {
  List<DateTime> _dates = [];
  bool isCalendarVisible = false;
  String _title = '';
  String _description = '';

  // Variabili relative all'Overlay
  late OverlayEntry _overlayEntry;
  bool isVisible = false;

  //--------------------------------------------------------------------------OVERLAY selezione date
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => CalendareRange(
        showHideOverlay: showHideOverlay,
        dates: _dates,
        onDatesChanged: (newDates) {
          setState(() => _dates = newDates);
          print('Date selezionate: $_dates');
        },
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

    //  Logica di Aggiornamento e Creazione
    try {
      if (widget.tripSelected != null) {
        // MODIFICA
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripSelected!.id)
            .update(newTrip.toMap());
        return true;
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

  @override
  void initState() {
    super.initState();
    _dates = List.from(widget.dates); // copia dei valori passati
    _title = widget.tripSelected?.title ?? '';
    _description = widget.tripSelected?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/svg/valigia.svg', height: 60),
                  SizedBox(
                    height: 15,
                  ), //-------------------------------------------------------------------pop-up title
                  Text(
                    (widget.tripSelected?.id ?? '').isNotEmpty
                        ? 'Modify your trip'
                        : 'Plan a new trip',
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
                        //----------------------------------------------------------------colore di sfondo
                        color: Color(0xFF7E9FA3),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Color(0xFF0D2025), width: 0),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                              left: 45,
                              right: 40,
                            ),
                            child: Column(
                              children: [
                                //--------------------------------------------------------TITOLO
                                TextField(
                                  // maxLength: 15,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  decoration: kTextFieldAdd.copyWith(
                                    prefixIcon: Icon(
                                      Icons.place_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    hintText:
                                        (widget.tripSelected?.id ?? '')
                                            .isNotEmpty
                                        ? widget.tripSelected!.title
                                        : 'Your trip\'s title',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _title =
                                          value; // Usa la variabile di stato corretta
                                    });
                                  },
                                ),
                                //--------------------------------------------------------divisorio1
                                Container(
                                  height: 1,
                                  color: Color(0xBE061215),
                                  width: 250,
                                ),
                                //--------------------------------------------------------DESCRIZIONE
                                TextField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  decoration: kTextFieldAdd.copyWith(
                                    prefixIcon: Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    hintText:
                                        (widget.tripSelected?.id ?? '')
                                            .isNotEmpty
                                        ? widget.tripSelected!.description
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
                                //--------------------------------------------------------divisorio2
                                Container(
                                  height: 1,
                                  color: Color(0xBE061215),
                                  width: 250,
                                ),
                                //--------------------------------------------------------DATE
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
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
                              //----------------------------------------------------------CONFERMA button
                              GestureDetector(
                                onTap: () async {
                                  final success = await _saveOrUpdateTrip(
                                    context,
                                  );
                                  if (success) {
                                    await widget.onTripSavedAndRefresh
                                        ?.call(); // ricarica lista
                                    Navigator.pop(context);
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
        ),
      ],
    );
  }
}

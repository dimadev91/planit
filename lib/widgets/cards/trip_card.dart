import 'package:plan_it/resource/exports.dart';

class TripCard extends StatelessWidget {
  final Trip
  trip; //usando la classe trip posso accedere a tutte le proprietà impostate e quindi ai dati provenienti da firestrore
  final Future<void> Function()? onUpdated;
  final currentUserId;

  TripCard({
    required this.trip,
    required this.onUpdated,
    required this.currentUserId,
  });
  //--------------------------------------------------------------------------formattare data
  String _formatDates(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return '${formatter.format(date)}';
  }

  //------------------------------------------------------------------funzione eliminazione
  Future<void> _deleteTrip(BuildContext context) async {
    final docId = trip.id;
    if (docId == null) return;

    // 1. Mostra un dialogo di conferma
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the trip "${trip.title}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onUpdated!();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // 2. Esegui l'eliminazione su Firestore se confermato
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(docId)
            .delete();
        print('Viaggio eliminato con successo: $docId');
      } catch (e) {
        print('Errore durante l\'eliminazione: $e');
      }
    }
  }

  //----------------------------------funzione per gestire il  menu impostazioni
  void _handleMenuSelection(BuildContext context, String action) {
    switch (action) {
      // ... (case 'image')

      case 'edit':
        final docId = trip.id;
        if (docId != null) {
          openTripDialog(context);
        }
        break;
      case 'delete':
        _deleteTrip(context); // CHIAMA LA FUNZIONE DI ELIMINAZIONE
        break;
    }
  }

  //----------------------------------------------------------------dialog
  void openTripDialog(BuildContext context) {
    showDialog(
      barrierColor: Colors.transparent, // rimuove il grigio
      context: context,
      builder: (context) {
        return saveUpdateTripDialog(
          onTripSavedAndRefresh: () {
            onUpdated!();
            return Future.value(true);
          },
          dates: [trip.startDate, trip.endDate],
          currentUserId: currentUserId,
          tripSelected: trip,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
              color: Colors.transparent,
              child: Stack(
                children: [
                  //------------------------------------------------------------NAVIGAZIONE
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return DetailsScreen(
                              tripId: trip.id,
                              title: trip.title,
                              dates:
                                  '${_formatDates(trip.startDate)} - ${_formatDates(trip.endDate)}',
                            );
                          },
                        ),
                      );
                    },
                    //-------------------------------------------------dimoensioni card
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFFAEC1C5).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Color(0xFF0D2025), width: 2),
                      ),
                      //--------------------------------------------------------card's images
                      child: Stack(
                        children: [
                          ClipRRect(
                            //TODO immagine che deve caricare l'utente
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/images/sfondo.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ClipRRect(
                            //tagli i bordi
                            borderRadius: BorderRadius.circular(23),
                            child: Image.asset(
                              width: double.infinity,
                              height: double.infinity,
                              'assets/images/shading/card_shade.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //------------------------------------------------sposta titoli a destra
                              Container(width: 100, height: double.infinity),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //--------------------------------------------TITOLO
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20.0,
                                      ),
                                      child: SizedBox(
                                        width: 200,
                                        child: Text(
                                          trip.title,
                                          style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 27,
                                            height: 1.2,
                                          ),
                                          maxLines: 2, // massimo 2 righe
                                          // overflow: TextOverflow
                                          //     .ellipsis, // mostra "..." se supera le righe
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    //--------------------------------------------------DESCRIZIONE
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              trip.description ?? '',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                              maxLines: 2, // massimo 2 righe
                                              overflow: TextOverflow
                                                  .ellipsis, // mostra "..." se supera le righe
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 2,
                                      color: Color(0xFF061215),
                                    ),
                                    //-------------------------------------divisorio
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Container(
                                          height: 2,
                                          width: 150,
                                          color: Color(0xFF274851),
                                        ),
                                      ],
                                    ),
                                    //--------------------------------------------DATE
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        left: 15,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '${_formatDates(trip.startDate)}\n${_formatDates(trip.endDate)}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          //----------------------------------------------------PULSANTE 3 DOTS
                          Align(
                            alignment: Alignment.topRight,

                            child: PopupMenuButton<String>(
                              onSelected: (String result) {
                                // La logica di gestione dell'opzione selezionata sarà qui (Passo 3)
                                print('Opzione selezionata: $result');
                                _handleMenuSelection(context, result);
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    // Opzione 1: Modifica Viaggio (Titolo, Descrizione, Date)
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text(
                                        'Modify trip',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuDivider(
                                      height: 1, // Linea sottile
                                    ),
                                    // Opzione 2: Modifica Immagine (richiederà Storage)
                                    const PopupMenuItem<String>(
                                      value: 'image',
                                      child: Text(
                                        'Modify image',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuDivider(
                                      height: 1, // Linea sottile
                                    ),
                                    // Opzione 3: Elimina Viaggio
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                              elevation: 8, // Ombreggiatura sotto il menu
                              shape: RoundedRectangleBorder(
                                // Bordo arrotondato
                                borderRadius: BorderRadius.circular(10),
                              ),
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white,
                              ),
                              color: Color(
                                0xFF8CAAAE,
                              ), // Colore di sfondo del menu a tendina
                            ),
                          ),
                          // FINE: POPUP MENU BUTTON]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ],
    );
  }
}

import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/widgets/cards/activity_card.dart';
import 'package:plan_it/widgets/cards/detailed_card.dart';
import 'package:plan_it/widgets/cards/hotel_card.dart';
import 'package:plan_it/widgets/timeline.dart';

class DetailsScreen extends StatefulWidget {
  static const id = 'details_screen';
  final String? title;
  final String? dates;
  final String? tripId;

  DetailsScreen({this.title, this.dates, this.tripId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Trip? _currentTrip;
  bool _isLoading = true;
  String? title;
  Flight? flightDetails;
  Hotel? hotelDetails;
  List<Activity> activityDetails = [];
  List<Food> foodDetails = [];
  TimelineService? timelineService;

  String toUpper() {
    title = _currentTrip!.title.toUpperCase();
    return title!;
  }

  //------------------------------------------------------------------------APRIRE I DIALOG
  void openFlightDialog(BuildContext context) {
    if (widget.tripId == null) {
      print("Errore: tripId è nullo, non posso aprire il dialogo.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SaveUpdateFlights(
          tripDocId: widget.tripId!,
          //----------------------------------------------------------Chiamerà _fetchTripDetails dopo il salvataggio
          onDataSaved: () async {
            _fetchTripDetails();
            await fetch(); // <-- aggiungi questo
            timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return; // ← controlla se il widget è ancora nel tree
            setState(() {});
          },
        );
      },
    );
  }

  void openHotelDialog(BuildContext context) {
    if (widget.tripId == null) {
      print("Errore: tripId è nullo, non posso aprire il dialogo.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SaveUpdateHotel(
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            await _fetchTripDetails();
            await fetch();
            timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return; // ← controlla se il widget è ancora nel tree
            setState(() {});
          },
        );
      },
    );
  }

  void openActivitiesDialog(BuildContext context, {TimelineEvent? event}) {
    if (widget.tripId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return SaveUpdateActivity(
          existingEvent:
              event, // qui passi l’event se c’è, altrimenti null per nuova attività
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            await _fetchTripDetails();
            await fetch();
            timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return;
            setState(() {});
          },
        );
      },
    );
  }

  void openFoodDialog(BuildContext context, {TimelineEvent? event}) {
    if (widget.tripId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return SaveUpdateFood(
          existingEvent:
              event, // qui passi l’event se c’è, altrimenti null per nuova attività
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            await _fetchTripDetails();
            await fetch();
            timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return;
            setState(() {});
          },
        );
      },
    );
  }

  //--------------------------------------------------------------------FUNZIONE PER PRENDERE I DETAILS
  Future<void> _fetchTripDetails() async {
    if (widget.tripId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.tripId != null) {
        final trip = await Trip.fetchTripDetails(widget.tripId!);

        setState(() {
          _currentTrip = trip;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _currentTrip = null; // Assicurati che sia nullo se il doc non esiste
        });
      }
    } catch (e) {
      print("Errore nel fetch del Trip: $e");
      setState(() {
        _isLoading = false;
        _currentTrip = null;
      });
    }
  }

  Future fetch() async {
    if (widget.tripId == null) return;
    final newFlight = await Trip.fetchFlightDetails(widget.tripId!);
    final newHotel = await Trip.fetchHotelDetails(widget.tripId!);
    // newActivity ora è List<Activity>
    final List<Activity> newActivity = await Trip.fetchActivityDetails(
      widget.tripId!,
    );
    final newFood = await Trip.fetchFoodDetails(widget.tripId!);

    setState(() {
      flightDetails = newFlight;
      hotelDetails = newHotel;
      activityDetails = newActivity; // Assegna la lista
      foodDetails = newFood;
    });
  }

  //-----------------------------------------------------------------------------refresh pagina
  Future<void> _handleRefresh() async {
    // Ricarica prima i dettagli base del viaggio
    await _fetchTripDetails();
    // Ricarica tutti i dettagli (Flight, Hotel, Activity, Food)
    await fetch();
    // Ricarica la Timeline
    await timelineService!.loadTimeline();

    // Forza il refresh dell'UI dopo il caricamento
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // ----------------------------------------------------------------Avvia il caricamento dei dettagli del viaggio all'apertura
    if (widget.tripId != null) {
      _fetchTripDetails();
    } else {
      // --------------------------------------------------------------Caso in cui tripId è nullo (dovrebbe essere evitato se possibile)
      setState(() {
        _isLoading = false;
      });
    }
    fetch();

    timelineService = TimelineService(tripId: widget.tripId!);
    timelineService!.loadTimeline().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = timelineService!.getTimeline();
    if (_isLoading) {
      // ---------------------------------------------------------------Mostra un indicatore di caricamento mentre i dati vengono scaricati
      return const Scaffold(
        backgroundColor: Color(0xFF0B161A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orangeAccent),
        ),
      );
    }

    // ---------------------------------------------------------------Se il viaggio non è stato trovato o ci sono stati errori
    if (_currentTrip == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F242A),
        appBar: AppBar(title: const Text('Trip Error')),
        body: const Center(
          child: Text(
            'Trip details not found or an error occurred.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F242A),
      body: Stack(
        children: [
          //--------------------------------------------------------------------SFONDO
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/images/sfondo4.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  //-----------------------------------------------------------TITOlO VIAGGIO
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Text(
                          // Usa _currentTrip.title per essere sicuro che sia l'ultimo dato
                          toUpper(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.0,
                            color: Colors.orangeAccent.withOpacity(0.8),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //------------------------------------------------------------DATE
                        Text(
                          widget.dates!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //--------------------------------------------------------------------BOTTOMSHEET fisso
              Container(height: 30),
              Container(
                height: MediaQuery.sizeOf(context).height / 1.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFDAD9D9),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                //--------------------------------------------------------------------CARDS
                child: RefreshIndicator(
                  color: Colors.orangeAccent,
                  onRefresh: _handleRefresh,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        openFlightDialog(context);
                                      },
                                      child:
                                          (flightDetails != null &&
                                              flightDetails!.outboundDateTime !=
                                                  null &&
                                              flightDetails!.returnDateTime !=
                                                  null)
                                          ? FlightCard(
                                              flightDetails: flightDetails,
                                              imageAsset:
                                                  'assets/images/cards/aereo.png',
                                              title: 'Flights',
                                            )
                                          : DetailsCard(
                                              imageAsset:
                                                  'assets/images/cards/aereo.png',
                                              title: 'Flight',
                                            ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          openHotelDialog(context);
                                        });
                                      },
                                      child:
                                          hotelDetails != null &&
                                              hotelDetails!.checkIn != null &&
                                              hotelDetails!.checkOut != null
                                          ? HotelCard(
                                              imageAsset:
                                                  'assets/images/cards/letto.png',
                                              title: 'Hotel',
                                              hotelDetails: hotelDetails,
                                            )
                                          : DetailsCard(
                                              imageAsset:
                                                  'assets/images/cards/letto.png',
                                              title: 'Hotel',
                                            ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    activityDetails.isNotEmpty
                                        ? ActivityCard(
                                            activityDetails: activityDetails,
                                            tripId: widget.tripId,
                                            imageAsset:
                                                'assets/images/cards/omino.png',
                                            title: 'Activities',
                                            onAdd: () {
                                              openActivitiesDialog(
                                                context,
                                              ); // aggiungi nuova attività
                                            },
                                            onTap: (TimelineEvent event) {
                                              openActivitiesDialog(
                                                context,
                                                event:
                                                    event, // passi l'evento selezionato per modifica
                                              );
                                            },
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                openActivitiesDialog(context);
                                              });
                                            },
                                            child: DetailsCard(
                                              imageAsset:
                                                  'assets/images/cards/omino.png',
                                              imageHeight: 80,
                                              title: 'Activities',
                                            ),
                                          ),
                                    foodDetails.isNotEmpty
                                        ? FoodCard(
                                            tripId: widget.tripId,
                                            imageAsset:
                                                'assets/images/cards/food.png',
                                            title: 'Food',
                                            onAdd: () {
                                              openFoodDialog(context);
                                            },
                                            onTap: (TimelineEvent event) {
                                              openFoodDialog(
                                                context,
                                                event:
                                                    event, // passi l'evento selezionato per modifica
                                              );
                                            },
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                openFoodDialog(context);
                                              });
                                            },
                                            child: DetailsCard(
                                              imageAsset:
                                                  'assets/images/cards/food.png',
                                              title: 'Food',
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TimelineWidget(
                            events: events,
                            tripId: widget.tripId!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //--------------------------------------------------------------------APPBAR
          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                Material(
                  elevation: 3,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 90,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xFF527882).withOpacity(0.30),
                          ),
                          height: 3,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //--------------------------------------------------------------------LOGO appbar
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 35.0, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'logoAccent',
                    child: Image(
                      image: AssetImage('assets/images/logo/loghiAccent.png'),
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //---------------------------------------------------------------------ICONE ACTIONS
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Usare pop per tornare indietro
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/services/firestore_services/destination_firestore.dart';
import 'package:plan_it/services/timeline_event_class.dart';
import 'package:plan_it/widgets/cards/activity_card.dart';
import 'package:plan_it/widgets/cards/destination_card.dart';
import 'package:plan_it/widgets/cards/detailed_card.dart';
import 'package:plan_it/widgets/cards/empty_destination_card.dart';
import 'package:plan_it/widgets/cards/flights_card/empty_flight_card.dart';
import 'package:plan_it/widgets/cards/flights_card/sample_flight_card.dart';
import 'package:plan_it/widgets/cards/hotel_card/empty_hotel_card.dart';
import 'package:plan_it/widgets/cards/hotel_card/sample_hotel_card.dart';
import 'package:plan_it/widgets/save_update_dialogs/destination_dialog.dart';

class CardSet extends StatefulWidget {
  VoidCallback? refreshScreen;
  final String? tripId;
  final TimelineService? timelineService;

  CardSet({
    required this.refreshScreen,
    required this.tripId,
    required this.timelineService,
  });

  @override
  State<CardSet> createState() => _CardSetState();
}

class _CardSetState extends State<CardSet> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //aggiungo mixin che permette allo stato di rimanere conervato anche quando la pageview cambia pagina

  List<Food> foodDetails = [];
  List<Activity> activityDetails = [];
  Hotel? hotelDetails;
  Flight? flightDetails;
  Destination? destinationDetails;
  List<Destination> destinationDetailsList = [];
  String? destinationId;

  //------------------------------------------------------------------------------FETCH DETAILS
  Future<void> fetchFoodDetails() async {
    final newFood = await Trip.fetchFoodDetails(widget.tripId!);
    setState(() {
      foodDetails = newFood;
    });
  }

  Future<void> fetchActivityDetails() async {
    final List<Activity> newActivity = await Trip.fetchActivityDetails(
      widget.tripId!,
    );
    setState(() {
      activityDetails = newActivity;
    });
  }

  Future<void> fetchHotelDetails() async {
    final newHotel = await Trip.fetchHotelDetails(
      widget.tripId!,
      destinationId ?? '',
    );
    setState(() {
      hotelDetails = newHotel;
    });
  }

  Future<void> fetchFlightDetails() async {
    final newFlight = await Trip.fetchFlightDetails(
      destinationId: destinationId ?? '',
      tripDocId: widget.tripId!,
    );
    setState(() {
      flightDetails = newFlight;
    });
    print(flightDetails);
  }

  Future<void> fetchDestinationDetails() async {
    final newDestination = await Trip.fetchDestinationDetails(widget.tripId!);
    setState(() {
      destinationDetailsList = newDestination;
    });
  }

  //------------------------------------------------------------------------------OPEN DIALOG
  void openDestinationDialog(BuildContext context) {
    if (widget.tripId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return DestinationDialog(
          destinationId: destinationId,
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            widget.refreshScreen?.call();
            await fetchDestinationDetails();
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
            // if (widget.fetchTripDetails != null) {
            //    widget.fetchTripDetails!();
            // }
            // ;
            widget.refreshScreen?.call();
            await fetchFoodDetails();
            widget.timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return;
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
            widget.refreshScreen?.call();
            await fetchActivityDetails();
            widget.timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return;
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
          destinationId: destinationId ?? '',
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            widget.refreshScreen?.call();
            await fetchHotelDetails();
            widget.timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return; // ← controlla se il widget è ancora nel tree
            setState(() {});
          },
        );
      },
    );
  }

  void openFlightDialog(BuildContext context) {
    if (widget.tripId == null) {
      print("Errore: tripId è nullo, non posso aprire il dialogo.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SaveUpdateFlights(
          destinationId: destinationId ?? '',
          tripDocId: widget.tripId!,
          onDataSaved: () async {
            await fetchFlightDetails();
            widget.refreshScreen?.call();
            widget.timelineService!.loadTimeline().then((_) {
              setState(() {});
            });
            if (!mounted) return; // ← controlla se il widget è ancora nel tree
            setState(() {});
          },
        );
      },
    );
  }

  //----------------------------------------------------------------------------
  void setDesId(String id) async {
    setState(() {
      destinationId = id;
    });
    fetchFlightDetails();
    fetchHotelDetails();
  }

  //------------------------------------------------------------------------------INIT E BUILD
  @override
  void initState() {
    super.initState();
    fetchDestinationDetails();
    fetchFoodDetails();
    fetchActivityDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                openDestinationDialog(context);
              },
              child: destinationDetailsList.isNotEmpty
                  // destinationDetails != null &&
                  //     destinationDetails!.cityName != null &&
                  //     destinationDetails!.countryName != null
                  ? DestinationCard(
                      setDesId: setDesId,
                      destinationDetails: destinationDetails,
                      destinations: destinationDetailsList,
                      title: 'Destination',
                    )
                  : EmptyDestinationCard(
                      imageAsset: 'assets/images/cards/destinazione.png',
                      title: 'Destination',
                    ),
            ),
            GestureDetector(
              onTap: () {
                openFlightDialog(context);
              },
              child:
                  (flightDetails != null &&
                      flightDetails!.outboundDateTime != null &&
                      flightDetails!.returnDateTime != null)
                  ? SampleFlightCard(
                      flightDetails: flightDetails,
                      imageAsset: 'assets/images/cards/aereo.png',
                      title: 'Flights',
                    )
                  : EmptyFlightCard(
                      imageAsset: 'assets/images/cards/aereo_in_volo.png',
                      title: 'Flights',
                    ),
            ),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     openFlightDialog(context);
                    //   },
                    //   child:
                    //       (flightDetails != null &&
                    //           flightDetails!.outboundDateTime != null &&
                    //           flightDetails!.returnDateTime != null)
                    //       ? FlightCard(
                    //           flightDetails: flightDetails,
                    //           imageAsset: 'assets/images/cards/aereo.png',
                    //           title: 'Flights',
                    //         )
                    //       : DetailsCard(
                    //           imageAsset: 'assets/images/cards/aereo.png',
                    //           title: 'Flight',
                    //         ),
                    // ),
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
                          ? SampleHotelCard(
                              imageAsset: 'assets/images/cards/hotel_house.png',
                              title: 'Hotel',
                              hotelDetails: hotelDetails,
                            )
                          : EmptyHotelCard(
                              imageAsset: 'assets/images/cards/hotel_house.png',
                              title: 'Hotel',
                            ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    activityDetails.isNotEmpty
                        ? ActivityCard(
                            activityDetails: activityDetails,
                            tripId: widget.tripId,
                            imageAsset: 'assets/images/cards/omino.png',
                            title: 'Activities',
                            onAdd: () {
                              openActivitiesDialog(
                                context,
                              ); // aggiungi nuova attività
                            },
                            onTap: (TimelineEvent event) {
                              openActivitiesDialog(context, event: event);
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              openActivitiesDialog(context);
                            },
                            child: DetailsCard(
                              imageAsset: 'assets/images/cards/omino.png',
                              imageHeight: 80,
                              title: 'Activities',
                            ),
                          ),
                    foodDetails.isNotEmpty
                        ? FoodCard(
                            foodDetails: foodDetails,
                            tripId: widget.tripId,
                            imageAsset: 'assets/images/cards/food.png',
                            title: 'Food',
                            onAdd: () {
                              openFoodDialog(context);
                            },
                            onTap: (TimelineEvent event) {
                              openFoodDialog(context, event: event);
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              openFoodDialog(context);
                            },
                            child: DetailsCard(
                              imageAsset: 'assets/images/cards/food.png',
                              title: 'Food',
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

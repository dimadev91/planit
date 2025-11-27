import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/services/timeline_event_class.dart';
import 'package:plan_it/widgets/cards/activity_card.dart';
import 'package:plan_it/widgets/cards/detailed_card.dart';
import 'package:plan_it/widgets/cards/hotel_card.dart';

class CardSet extends StatefulWidget {
  VoidCallback? openFlightDialog;
  VoidCallback? openHotelDialog;
  final void Function(BuildContext, {TimelineEvent? event})?
  openActivitiesDialog;
  final void Function(BuildContext, {TimelineEvent? event})? openFoodDialog;
  final String? tripId;
  final List<Activity> activityDetails;
  final List<Food> foodDetails;
  final Flight? flightDetails;
  final Hotel? hotelDetails;

  CardSet({
    required this.openFlightDialog,
    required this.openHotelDialog,
    required this.openActivitiesDialog,
    required this.openFoodDialog,
    required this.tripId,
    required this.activityDetails,
    required this.foodDetails,
    required this.flightDetails,
    required this.hotelDetails,
  });

  @override
  State<CardSet> createState() => _CardSetState();
}

class _CardSetState extends State<CardSet> {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
                      widget.openFlightDialog?.call();
                    },
                    child:
                        (widget.flightDetails != null &&
                            widget.flightDetails!.outboundDateTime != null &&
                            widget.flightDetails!.returnDateTime != null)
                        ? FlightCard(
                            flightDetails: widget.flightDetails,
                            imageAsset: 'assets/images/cards/aereo.png',
                            title: 'Flights',
                          )
                        : DetailsCard(
                            imageAsset: 'assets/images/cards/aereo.png',
                            title: 'Flight',
                          ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.openHotelDialog?.call();
                      });
                    },
                    child:
                        widget.hotelDetails != null &&
                            widget.hotelDetails!.checkIn != null &&
                            widget.hotelDetails!.checkOut != null
                        ? HotelCard(
                            imageAsset: 'assets/images/cards/letto.png',
                            title: 'Hotel',
                            hotelDetails: widget.hotelDetails,
                          )
                        : DetailsCard(
                            imageAsset: 'assets/images/cards/letto.png',
                            title: 'Hotel',
                          ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.activityDetails.isNotEmpty
                      ? ActivityCard(
                          activityDetails: widget.activityDetails,
                          tripId: widget.tripId,
                          imageAsset: 'assets/images/cards/omino.png',
                          title: 'Activities',
                          onAdd: () {
                            widget.openActivitiesDialog?.call(
                              context,
                            ); // aggiungi nuova attività
                          },
                          onTap: (TimelineEvent event) {
                            widget.openActivitiesDialog?.call(
                              context,
                              event: event,
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            widget.openActivitiesDialog?.call(context);
                          },
                          child: DetailsCard(
                            imageAsset: 'assets/images/cards/omino.png',
                            imageHeight: 80,
                            title: 'Activities',
                          ),
                        ),
                  widget.foodDetails.isNotEmpty
                      ? FoodCard(
                          foodDetails: widget.foodDetails,
                          tripId: widget.tripId,
                          imageAsset: 'assets/images/cards/food.png',
                          title: 'Food',
                          onAdd: () {
                            widget.openFoodDialog?.call(context);
                          },
                          onTap: (TimelineEvent event) {
                            widget.openFoodDialog?.call(context, event: event);
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            widget.openFoodDialog?.call(context);
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
        ),
      ],
    );
  }
}

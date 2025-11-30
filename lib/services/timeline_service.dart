import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/services/timeline_event_class.dart';

class TimelineService {
  String tripId = '';

  TimelineService({required this.tripId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TimelineEvent> timeline = [];

  /// Recupera la timeline di un trip
  Future<List<TimelineEvent>> fetchTimeline(String tripId) async {
    List<TimelineEvent> timelining = [];

    try {
      final docSnapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .get();
      final data = docSnapshot.data();
      if (data == null) return [];

      // -------------------- FLIGHT --------------------
      if (!kIsWeb) {
        final flights = await Trip.fetchFlightDetails(
          tripDocId: tripId,
          destinationId: '',
        );
        if (flights != null) {
          if (flights.outboundDateTime != null) {
            timelining.add(
              TimelineEvent(
                datetime: flights.outboundDateTime!,
                title: flights.departureAirport ?? '',
                icon: Icons.flight_takeoff,
                location: flights.departureCity ?? '',
              ),
            );
          }
          if (flights.returnDateTime != null) {
            timelining.add(
              TimelineEvent(
                datetime: flights.returnDateTime!,
                title: flights.returnAirport ?? '',
                icon: Icons.flight_land,
                location: flights.returnCity ?? '',
              ),
            );
          }
        }
      } else {
        // Web: leggi direttamente dalla mappa Firestore
        final flightMap = data['flight'] as Map<String, dynamic>?;
        if (flightMap != null) {
          if (flightMap['outboundDateTime'] != null) {
            timelining.add(
              TimelineEvent(
                datetime: _parseTimestamp(flightMap['outboundDateTime']),
                title: 'Outbound',
                icon: Icons.flight_takeoff,
                location: flightMap['location'] ?? '',
              ),
            );
          }
          if (flightMap['returnDateTime'] != null) {
            timelining.add(
              TimelineEvent(
                datetime: _parseTimestamp(flightMap['returnDateTime']),
                title: 'Return',
                icon: Icons.flight_land,
                location: flightMap['location'] ?? '',
              ),
            );
          }
        }
      }

      // -------------------- HOTEL --------------------
      if (!kIsWeb) {
        final hotel = await Trip.fetchHotelDetails(tripId, '');
        if (hotel != null) {
          if (hotel.checkIn != null) {
            timelining.add(
              TimelineEvent(
                datetime: hotel.checkIn!,
                title: 'Check-in',
                icon: Icons.local_hotel_outlined,
                location: hotel.hotelLocation ?? '',
              ),
            );
          }
          if (hotel.checkOut != null) {
            timelining.add(
              TimelineEvent(
                datetime: hotel.checkOut!,
                title: 'Check-out',
                icon: Icons.local_hotel_outlined,
                location: hotel.hotelLocation ?? '',
              ),
            );
          }
        }
      } else {
        final hotelMap = data['hotel'] as Map<String, dynamic>?;
        if (hotelMap != null) {
          if (hotelMap['checkIn'] != null) {
            timelining.add(
              TimelineEvent(
                datetime: _parseTimestamp(hotelMap['checkIn']),
                title: 'Check-in',
                icon: Icons.local_hotel_outlined,
                location: hotelMap['location'] ?? '',
              ),
            );
          }
          if (hotelMap['checkOut'] != null) {
            timelining.add(
              TimelineEvent(
                datetime: _parseTimestamp(hotelMap['checkOut']),
                title: 'Check-out',
                icon: Icons.local_hotel_outlined,
                location: hotelMap['location'] ?? '',
              ),
            );
          }
        }
      }
      // -------------------- FOOD ----------------------
      final foodList = await Trip.fetchFoodDetails(
        tripId,
      ); // Ritorna List<Food>
      if (foodList.isNotEmpty) {
        for (final food in foodList) {
          if (food.restTime != null && food.restName != null) {
            timelining.add(
              TimelineEvent(
                datetime: kIsWeb
                    ? _parseTimestamp(food.restTime)
                    : food.restTime!,
                title: food.restName!,
                description: food.restLocation,
                icon: Icons.restaurant, // Icona per il cibo
                price: food.restPriceRange,
                location: food.restLocation,
              ),
            );
          }
        }
      }
      // -------------------- ACTIVITIES --------------------
      final activityList = data['activities'] as List<dynamic>?;
      if (activityList != null) {
        for (var act in activityList) {
          final actMap = Map<String, dynamic>.from(act);
          final activity = kIsWeb
              ? Activity.fromMapWeb(actMap)
              : Activity.fromMap(actMap);

          if (activity.activityTime != null && activity.activityName != null) {
            timelining.add(
              TimelineEvent(
                datetime: kIsWeb
                    ? _parseTimestamp(activity.activityTime)
                    : activity.activityTime!,
                title: activity.activityName!,
                icon: Icons.directions_run_outlined,
                location: activity.activityLocation,
              ),
            );
          }
        }
      }

      // Ordina per data
      timelining.sort((a, b) => a.datetime.compareTo(b.datetime));
      return timelining;
    } catch (e) {
      print('Errore nel fetch della timeline: $e');
      return [];
    }
  }

  /// Metodo che carica la timeline e aggiorna la lista interna
  Future<void> loadTimeline() async {
    timeline = await fetchTimeline(tripId);
  }

  /// Getter sincrono (restituisce ciò che è già stato caricato)
  List<TimelineEvent> getTimeline() {
    return timeline;
  }

  /// Converte timestamp o string in DateTime a seconda della piattaforma
  DateTime _parseTimestamp(dynamic timestamp) {
    if (kIsWeb) {
      if (timestamp is int)
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (timestamp is String) return DateTime.parse(timestamp);
      if (timestamp is DateTime) return timestamp;
      throw Exception('Tipo timestamp non supportato su web: $timestamp');
    } else {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is DateTime) return timestamp;
      if (timestamp is int)
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      throw Exception('Tipo timestamp non supportato su mobile: $timestamp');
    }
  }
}

// File: trip_firestore.dart
import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';

class Trip {
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final String? id;
  // le seguenti non sono final, altrimenti per cambiare i valori bisognerebbe ricostruire da capo l'oggetto ---> non efficiente
  Flight? flightDetails; //---potrò poi chiamarli con trip.flightdetails
  Hotel? hotelDetails;
  List<Activity> activities = [];
  List<Food> food = [];

  Trip({
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.userId,
    this.id,
    // activities e food non sono nel costruttore perchè abbiamo assegnato dei valori momentanei come liste vuote
    this.flightDetails,
    this.hotelDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Trip.fromFirestore(Map<String, dynamic> firestore, String id) {
    final startTimestamp = firestore['startDate'] as Timestamp;
    final endTimestamp = firestore['endDate'] as Timestamp;

    final flightMap = firestore['flight'] as Map<String, dynamic>?;
    final hotelMap = firestore['hotel'] as Map<String, dynamic>?;

    final trip = Trip(
      id: id,
      title: firestore['title'] as String,
      description: firestore['description'] as String?,
      startDate: startTimestamp.toDate(),
      endDate: endTimestamp.toDate(),
      userId: firestore['userId'] as String,
      flightDetails: flightMap != null ? Flight.fromMap(flightMap) : null,
      hotelDetails: hotelMap != null ? Hotel.fromMap(hotelMap) : null,
    );
    // il seguente popola invece le liste
    final activitiesList = firestore['activities'] as List<dynamic>?;
    if (activitiesList != null) {
      trip.activities = activitiesList
          .whereType<Map<String, dynamic>>()
          .map((a) => Activity.fromMap(a))
          .toList();
    }

    final foodList = firestore['food'] as List<dynamic>?;
    if (foodList != null) {
      trip.food = foodList
          .whereType<Map<String, dynamic>>()
          .map((f) => Food.fromMap(f))
          .toList();
    }

    return trip;
  }

  // restituisce tripData: Map<String, dynamic>?)
  static Future<Map<String, dynamic>?> fetchTripData(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching the trip data: $e");
      return null;
    }
  }

  // -------------------------- Fetch Trip
  static Future<Trip?> fetchTripDetails(String id) async {
    try {
      // Usa la funzione base
      final tripData = await fetchTripData(id);

      // Controlla se tripData NON è nullo
      if (tripData != null) {
        return Trip.fromFirestore(tripData, id);
      }
      return null;
    } catch (e) {
      print("Error fetching the trip: $e");
      return null;
    }
  }

  // -------------------------- Fetch Flight
  static Future<Flight?> fetchFlightDetails(String tripDocId) async {
    try {
      // Usa la funzione base
      final tripData = await fetchTripData(tripDocId);

      // Controlla se tripData NON è nullo
      if (tripData != null) {
        final flightMap = tripData['flight'] as Map<String, dynamic>?;
        if (flightMap != null) return Flight.fromMap(flightMap);
      }
      return null;
    } catch (e) {
      print("Error fetching the flight: $e");
      return null;
    }
  }

  // -------------------------- Fetch Hotel
  static Future<Hotel?> fetchHotelDetails(String tripDocId) async {
    try {
      // Usa la funzione base
      final tripData = await fetchTripData(tripDocId);

      if (tripData != null) {
        final hotelMap = tripData['hotel'] as Map<String, dynamic>?;
        if (hotelMap != null) return Hotel.fromMap(hotelMap);
      }
      return null;
    } catch (e) {
      print("Error fetching the hotel: $e");
      return null;
    }
  }

  // -------------------------- Fetch Activity
  static Future<List<Activity>> fetchActivityDetails(String tripDocId) async {
    try {
      // Usa la funzione base
      final tripData = await fetchTripData(tripDocId);

      if (tripData != null) {
        final activityList = tripData['activities'] as List<dynamic>?;

        if (activityList != null && activityList.isNotEmpty) {
          // Mappa l'intera lista di Map<String, dynamic> in List<Activity>
          return activityList
              .whereType<Map<String, dynamic>>()
              .map((map) => Activity.fromMap(map))
              .toList();
        }
      }
      return []; // Restituisce una lista vuota se non ci sono attività
    } catch (e) {
      print("Error fetching the activity: $e");
      return []; // Restituisce una lista vuota in caso di errore
    }
  }

  // -------------------------- Fetch Food
  static Future<List<Food>> fetchFoodDetails(String tripDocId) async {
    try {
      // Usa la funzione base
      final tripData = await fetchTripData(tripDocId);

      if (tripData != null) {
        final foodList = tripData['food'] as List<dynamic>?;

        if (foodList != null && foodList.isNotEmpty) {
          return foodList
              .whereType<Map<String, dynamic>>()
              .map((f) => Food.fromMap(f))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching foods: $e");
      return [];
    }
  }
}

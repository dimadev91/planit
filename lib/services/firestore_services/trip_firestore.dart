// File: trip_firestore.dart
import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/firestore_services/activity_firestore.dart';
import 'package:plan_it/services/firestore_services/destination_firestore.dart';

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

  //------------------------------------------------------restituisce i data fino alla destination
  //   static Future<Map<String, dynamic>?> fetchDestinationData(
  //       String tripDocId) async {
  //     try {
  //       final doc = await FirebaseFirestore.instance
  //           .collection('trips')
  //           .doc(tripDocId)
  //           .collection('destination') // Naviga alla subcollezione
  //           .get(); // crea lo snapshot
  //
  //
  //
  //       if (doc.exists && doc.data() != null) {
  //         return doc.data() as Map<String, dynamic>;
  //       }}
  //     catch (e) {
  //       print("Error fetching destinations from subcollection: $e");
  //     }
  //     return null;
  //   }
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

  //---------------------------------Fetch Destination
  static Future<List<Destination>> fetchDestinationDetails(
    String tripDocId,
  ) async {
    try {
      // SNAPSHOT (risultato della query)

      final destinationData = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDocId)
          .collection('destination') // Naviga alla subcollezione
          .orderBy('createdAt', descending: true)
          .get(); // crea lo snapshot

      // destinationData.docs è l'elenco dei documenti trovati.
      return destinationData.docs
          .map(
            //itera su tutti i documenti e li mappa in un nuovo oggetto
            (doc) =>
                // Per ogni documento:
                Destination.fromMap(
                  doc.data(), // Primo parametro: i dati
                  doc.id, // Secondo parametro: l'ID del documento
                ),
          )
          .toList();
    } catch (e) {
      print("Error fetching destinations from subcollection: $e");
      return [];
    }
  }

  //----------------------------------------------------------per restituire un singolo oggetto
  static Future<Destination?> fetchSingleDestinationDetails(
    String tripDocId,
    String destinationId,
  ) async {
    final destinationData = await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripDocId)
        .collection('destination') // Naviga alla subcollezione
        .doc(destinationId)
        .get(); // crea lo snapshot
    if (destinationData.exists) {
      return Destination.fromMap(
        destinationData.data() as Map<String, dynamic>,
        destinationId,
      );
    } else {
      return null;
    }
  }

  // -------------------------- Fetch Flight
  static Future<Flight?> fetchFlightDetails({
    required String tripDocId,
    required String destinationId,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDocId)
          .collection('destination')
          .doc(destinationId)
          .get();

      if (doc.exists && doc.data()!.containsKey('flights')) {
        final flightMap = doc['flights'] as Map<String, dynamic>;
        return Flight.fromMap(flightMap);
      }

      return null;
    } catch (e) {
      print("Errore fetch flight: $e");
      return null;
    }
  }

  // -------------------------- Fetch Hotel
  static Future<Hotel?> fetchHotelDetails(
    String tripDocId,
    String destinationId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDocId)
          .collection('destination')
          .doc(destinationId)
          .get();

      if (doc.exists && doc.data()!.containsKey('hotel')) {
        final flightMap = doc['hotel'] as Map<String, dynamic>;
        return Hotel.fromMap(flightMap);
      }

      return null;
    } catch (e) {
      print("Errore fetch flight: $e");
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

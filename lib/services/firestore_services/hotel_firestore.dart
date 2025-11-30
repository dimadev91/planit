import 'package:cloud_firestore/cloud_firestore.dart' hide Query;

class Hotel {
  final DateTime? checkIn; // Data E ora di partenza
  final DateTime? checkOut; // Data E ora di ritorno
  final String? hotelName;
  final String? hotelLocation;
  final double? hotelPrice;

  Hotel({
    this.checkIn,
    this.checkOut,
    this.hotelName,
    this.hotelLocation,
    this.hotelPrice,
  });

  // Metodo per convertire in Map per l'aggiornamento di Firestore
  Map<String, dynamic> toMap() {
    return {
      'checkinTime': checkIn,
      'checkoutTime': checkOut,
      'hotelName': hotelName,
      'hotelLocation': hotelLocation,
      'hotelPrice': hotelPrice,
    };
  }

  // Metodo per recuperare la Mappa 'flight' dal documento Trip
  factory Hotel.fromMap(Map<String, dynamic> firestoreMap) {
    final checkInTimestamp = firestoreMap['checkinTime'];
    final checkOutTimestamp = firestoreMap['checkoutTime'];

    return Hotel(
      checkIn: checkInTimestamp != null
          ? (checkInTimestamp is Timestamp
                ? checkInTimestamp.toDate()
                : checkInTimestamp as DateTime)
          : null,
      checkOut: checkOutTimestamp != null
          ? (checkOutTimestamp is Timestamp
                ? checkOutTimestamp.toDate()
                : checkOutTimestamp as DateTime)
          : null,
      hotelName: firestoreMap['hotelName'] as String?,
      hotelLocation: firestoreMap['hotelLocation'] as String?,
      hotelPrice: firestoreMap['hotelPrice'] as double?,
    );
  }
  static Future<void> SaveUpdateHotel({
    checkinDateTime,
    checkoutDateTime,
    hotelNameController,
    hotelLocationController,
    priceController,
    context,
    tripDocId,
    destinationId,
  }) async {
    if (checkinDateTime == null &&
        checkoutDateTime == null &&
        hotelNameController.text.trim().isEmpty &&
        hotelLocationController.text.trim().isEmpty &&
        priceController.text.trim().isEmpty) {
      print("Nessun dato volo da salvare o modificare. Chiudo il Dialog.");
      return;
    }

    // 1. Crea l'oggetto Hotel
    final hotel = Hotel(
      checkIn: checkinDateTime,
      hotelName: hotelNameController.text.trim().isEmpty
          ? null
          : hotelNameController.text,
      checkOut: checkoutDateTime,
      hotelLocation: hotelLocationController.text.trim().isEmpty
          ? null
          : hotelLocationController.text,
      hotelPrice: priceController.text.trim().isEmpty
          ? null
          : double.tryParse(priceController.text),
    );

    // 2. la mappa da salvare
    final hotelMap = hotel.toMap();

    // 3. Aggiorna il documento Trip in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDocId) // Usa l'ID del viaggio ricevuto
          .collection('destination')
          .doc(destinationId)
          .update({
            'hotel': hotelMap, // Salva la Mappa 'hotel' nel documento Trip
          });
      print("✅ Hotel updated successfully.");

      // ✅ CHIAMATA DI CALLBACK: Chiamiamo il refresh della schermata padre
    } catch (e) {
      print("!!! Error during hotel update: $e");
    }
  }
}

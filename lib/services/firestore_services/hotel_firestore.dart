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
}

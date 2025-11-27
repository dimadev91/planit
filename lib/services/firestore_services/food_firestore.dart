import 'package:cloud_firestore/cloud_firestore.dart' hide Query;

class Food {
  final DateTime? restTime;
  final String? restName;
  final String? restLocation;
  final double? restPriceRange;
  final String? restDescription;

  Food({
    this.restTime,
    this.restName,
    this.restLocation,
    this.restPriceRange,
    this.restDescription,
  });

  // Metodo per convertire in Map per l'aggiornamento di Firestore
  Map<String, dynamic> toMap() {
    return {
      'restTime': restTime,
      'restName': restName,
      'restLocation': restLocation,
      'restPriceRange': restPriceRange,
      'restDescription': restDescription,
    };
  }

  // Metodo per recuperare la Mappa 'flight' dal documento Trip
  factory Food.fromMap(Map<String, dynamic> firestoreMap) {
    final restTimesStamp = firestoreMap['restTime'];

    return Food(
      restTime: restTimesStamp != null
          ? (restTimesStamp is Timestamp
                ? restTimesStamp.toDate()
                : restTimesStamp as DateTime)
          : null,
      restName: firestoreMap['restName'] as String?,
      restLocation: firestoreMap['restLocation'] as String?,
      restPriceRange: firestoreMap['restPriceRange'] as double?,
      restDescription: firestoreMap['restDescription'] as String?,
    );
  }
  // Metodo dedicato per il web (gestisce timestamp diversi e stringhe)
  factory Food.fromMapWeb(Map<String, dynamic> map) {
    DateTime? parsedTime;

    final t = map['restTime'];
    if (t != null) {
      if (t is int) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(t);
      } else if (t is String) {
        parsedTime = DateTime.tryParse(t);
      } else if (t is DateTime) {
        parsedTime = t;
      }
    }

    return Food(
      restTime: parsedTime,
      restName: map['restName'] as String?,
      restLocation: map['restLocation'] as String?,
      restPriceRange: map['restPriceRange'] != null
          ? double.tryParse(map['restPriceRange'].toString())
          : null,
      restDescription: map['restDescription'] as String?,
    );
  }
}

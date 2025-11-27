import 'package:cloud_firestore/cloud_firestore.dart' hide Query;

class Activity {
  final DateTime? activityTime;
  final String? activityName;
  final String? activityLocation;
  final double? activityPrice;
  final double? activityDuration;
  final String? activityId;

  Activity({
    this.activityTime,
    this.activityName,
    this.activityLocation,
    this.activityPrice,
    this.activityId,
    this.activityDuration,
  });

  // Metodo per convertire in Map per l'aggiornamento di Firestore
  Map<String, dynamic> toMap() {
    return {
      'activityTime': activityTime,
      'activityName': activityName,
      'activityLocation': activityLocation,
      'activityPrice': activityPrice,
      'activityId': activityId,
      'activityDuration': activityDuration,
    };
  }

  // Metodo per recuperare la Mappa 'flight' dal documento Trip
  factory Activity.fromMap(Map<String, dynamic> firestoreMap) {
    final activityTimesStamp = firestoreMap['activityTime'];

    return Activity(
      activityTime: activityTimesStamp != null
          ? (activityTimesStamp is Timestamp
                ? activityTimesStamp.toDate()
                : activityTimesStamp as DateTime)
          : null,
      activityName: firestoreMap['activityName'] as String?,
      activityLocation: firestoreMap['activityLocation'] as String?,
      activityPrice: firestoreMap['activityPrice'] as double?,
      activityId: firestoreMap['activityId'] as String?,
      activityDuration: firestoreMap['activityDuration'] as double?,
    );
  }
  // Metodo dedicato per il web (gestisce timestamp diversi e stringhe)
  factory Activity.fromMapWeb(Map<String, dynamic> map) {
    DateTime? parsedTime;

    final t = map['activityTime'];
    if (t != null) {
      if (t is int) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(t);
      } else if (t is String) {
        parsedTime = DateTime.tryParse(t);
      } else if (t is DateTime) {
        parsedTime = t;
      }
    }

    return Activity(
      activityTime: parsedTime,
      activityName: map['activityName'] as String?,
      activityLocation: map['activityLocation'] as String?,
      activityPrice: map['activityPrice'] != null
          ? double.tryParse(map['activityPrice'].toString())
          : null,
      activityId: map['activityId'] as String?,
      activityDuration: map['activityDuration'] != null
          ? double.tryParse(map['activityDuration'].toString())
          : null,
    );
  }
}

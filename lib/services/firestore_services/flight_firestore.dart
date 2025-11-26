class Flight {
  final DateTime? outboundDateTime; // Data E ora di partenza
  final String? outboundDetails;
  final DateTime? returnDateTime; // Data E ora di ritorno
  final String? returnDetails;
  final double? outboundPrice;
  final double? returnPrice;

  // Costruttore

  Flight({
    this.outboundDateTime,
    this.outboundDetails,
    this.returnDateTime,
    this.returnDetails,
    this.outboundPrice,
    this.returnPrice,
  });

  // Metodo per convertire in Map per l'aggiornamento di Firestore
  Map<String, dynamic> toMap() {
    return {
      'outboundDateTime': outboundDateTime,
      'outboundDetails': outboundDetails,
      'returnDateTime': returnDateTime,
      'returnDetails': returnDetails,
      'outboundPrice': outboundPrice,
      'returnPrice': returnPrice,
    };
  }

  // Metodo per recuperare la Mappa 'flight' dal documento Trip
  factory Flight.fromMap(Map<String, dynamic> firestoreMap) {
    // Gestisci valori nulli o mancanti
    return Flight(
      outboundDateTime: firestoreMap['outboundDateTime']?.toDate(),
      outboundDetails: firestoreMap['outboundDetails'] as String?,
      returnDateTime: firestoreMap['returnDateTime']?.toDate(),
      returnDetails: firestoreMap['returnDetails'] as String?,
      outboundPrice: firestoreMap['outboundPrice'] as double?,
      returnPrice: firestoreMap['returnPrice'] as double?,
    );
  }
}

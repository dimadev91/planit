class Flight {
  final DateTime? outboundDateTime; // Data E ora di partenza
  final String? outboundDetails;
  final DateTime? returnDateTime; // Data E ora di ritorno
  final String? returnDetails;
  final double? outboundPrice;
  final double? returnPrice;
  final String? departureAirport;
  final String? returnAirport;
  final String? departureIata;
  final String? returnIata;
  final String? departureCity;
  final String? returnCity;

  // Costruttore

  Flight({
    this.outboundDateTime,
    this.outboundDetails,
    this.returnDateTime,
    this.returnDetails,
    this.outboundPrice,
    this.returnPrice,
    this.departureAirport,
    this.returnAirport,
    this.departureIata,
    this.returnIata,
    this.departureCity,
    this.returnCity,
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
      'departureAirport': departureAirport,
      'returnAirport': returnAirport,
      'departureIata': departureIata,
      'returnIata': returnIata,
      'departureCity': departureCity,
      'returnCity': returnCity,
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
      departureAirport: firestoreMap['departureAirport'] as String?,
      returnAirport: firestoreMap['returnAirport'] as String?,
      departureIata: firestoreMap['departureIata'] as String?,
      returnIata: firestoreMap['returnIata'] as String?,
      departureCity: firestoreMap['departureCity'] as String?,
      returnCity: firestoreMap['returnCity'] as String?,
    );
  }
}

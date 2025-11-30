import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  static Future<void> saveUpdateFlight({
    outboundDateTime,
    returnDateTime,
    outboundDetailsController,
    returnDetailsController,
    budgetOutbound,
    budgetReturn,
    departureAiportController,
    returnAirportController,
    context,
    airport,
    tripDocId,
    destinationId,
  }) async {
    if (outboundDateTime == null &&
        returnDateTime == null &&
        outboundDetailsController.text
            .trim()
            .isEmpty && //trim serve per eliminare spazi vuoti
        returnDetailsController.text.trim().isEmpty &&
        budgetOutbound.text.trim().isEmpty &&
        budgetReturn.text.trim().isEmpty &&
        departureAiportController.text.trim().isEmpty &&
        returnAirportController.text.trim().isEmpty) {
      print("Nessun dato volo da salvare o modificare. Chiudo il Dialog.");
      Navigator.pop(context);
    }
    final departureAirport = airport.getAirportByName(
      departureAiportController.text,
    );
    final returnAirport = airport.getAirportByName(
      returnAirportController.text,
    );
    if (departureAirport == null || returnAirport == null) {
      // mostra un alert o un messaggio all'utente
      print("Errore: aeroporto non trovato.");
    }
    // 1. Crea l'oggetto Flight e assegnamo alle proprietà i valori
    final flight = Flight(
      outboundDateTime: outboundDateTime,
      outboundDetails: outboundDetailsController.text.trim().isEmpty
          ? null
          : outboundDetailsController.text,
      returnDateTime: returnDateTime,
      returnDetails: returnDetailsController.text.trim().isEmpty
          ? null
          : returnDetailsController.text,
      outboundPrice: budgetOutbound.text.trim().isEmpty
          ? null
          : double.tryParse(budgetOutbound.text),
      returnPrice: budgetReturn.text.trim().isEmpty
          ? null
          : double.tryParse(budgetReturn.text),
      departureAirport: departureAiportController.text.trim().isEmpty
          ? null
          : departureAiportController.text,
      returnAirport: returnAirportController.text.trim().isEmpty
          ? null
          : returnAirportController.text,
      departureIata: departureAirport.iataCode,
      returnIata: returnAirport.iataCode,
      departureCity: departureAirport.city,
      returnCity: returnAirport.city,
    );

    // 2. Ottieni la mappa da salvare
    final flightMap = flight.toMap();

    // 3. Aggiorna il documento Trip in Firestore
    try {
      print(flightMap);
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripDocId)
          .collection('destination')
          .doc(destinationId)
          .update({'flights': flightMap});
      print("Dettagli Volo salvati/aggiornati con successo.");
    } catch (e) {
      print("!!! Errore durante il salvataggio dei dettagli volo: $e");
    }
  }
}

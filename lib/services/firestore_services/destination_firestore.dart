import 'package:plan_it/resource/exports.dart';

class Destination {
  String? cityName;
  String? countryName;
  String? id;
  Destination({this.cityName, this.countryName, this.id});

  Map<String, dynamic> toMap() {
    return {'cityName': cityName, 'countryName': countryName};
  }

  static Future<String?> saveUpdateDestination(
    String cityName,
    String countryName,
    String tripDocId,
    context,
  ) async {
    if (cityName.isEmpty && countryName.isEmpty) {
      print("Nessun dato da salvare o modificare. Chiudo il Dialog.");
    }
    final destination = Destination(
      cityName: cityName,
      countryName: countryName,
      id: '',
    );
    final destinationMap = destination.toMap();

    try {
      final destinationRef = await FirebaseFirestore.instance
          .collection('trips') //cerchi la collezione
          .doc(tripDocId)
          .collection('destination')
          .add(destinationMap);
      print("Dettagli volo salvati/aggiornati con successo.");
      return destinationRef.id;
    } catch (e) {
      print("!!! Errore durante il salvataggio dei dettagli volo: $e");
    }
  }

  factory Destination.fromMap(Map<String, dynamic> map, String destinationid) {
    return Destination(
      cityName: map['cityName'],
      countryName: map['countryName'],
      id: destinationid,
    );
  }
}

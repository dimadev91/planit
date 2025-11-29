import 'dart:convert';

import '../resource/exports.dart';

class Airport {
  int? id;
  String? name;
  double? lat;
  double? long;
  String? city;
  String? iataCode;

  Airport({this.id, this.name, this.lat, this.long, this.city, this.iataCode});
  List<Airport>? airportsFiltered = []; //lista airport

  //prende gli aeroporti passando dalla creazione dell'oggetto
  Future<void> loadAirportsData() async {
    final String response = await rootBundle.loadString(
      'assets/json/airports.json',
    ); //legge il testo testo dal file
    final List<dynamic> jsonList = json.decode(
      response,
    ); //converte in lista di oggetti o mappa, in questo caso lista perchè sono array
    airportsFiltered = jsonList
        .map(
          (json) => Airport.fromJson(json),
        ) //map itera sul file e prende tramite il factory tutti gli oggetti Airport all'interno
        .where(
          (airport) =>
              airport.iataCode!.isNotEmpty && airport.iataCode!.length == 3,
        ) //filtra airport dicendo di tenere conto quelli non vuoti e con lunghezza IATA 3 che sono gli aerporti civili
        .toList();
  }

  //serve una volta ottenuto il jsono utlizzabile dal decode, a creare un oggetto Airport con i dati contenuti nell'array
  factory Airport.fromJson(Map<String, dynamic> json) {
    //factory serve per inizializzare un oggetto, è tipico di dart, è nativo, usato nella comunità al posto delle funzioni statiche (alternativa comunque utilizzabile)

    return Airport(
      id: json['id'] as int,
      name: json['name'] as String,
      lat:
          double.tryParse(json['latitude_deg'].toString()) ??
          0.0, //bisogna convertirli
      long: double.tryParse(json['longitude_deg'].toString()) ?? 0.0,
      city: json['municipality'] as String,
      iataCode: json['iata_code'] as String,
    );
  }

  Airport? getAirportByIATA(String iataCode) {
    //uso lo IATA inserito dall'utente per avere i dettagli dell'aeroporto corrispondente
    try {
      return airportsFiltered!.firstWhere(
        (airport) => airport.iataCode == iataCode,
      );
    } catch (_) {
      return null; // Aeroporto non trovato
    }
  }

  Airport? getAirportByName(String name) {
    loadAirportsData();
    print(airportsFiltered);
    print('sono arivato');
    final query = name.toLowerCase();
    try {
      print('$name');
      return airportsFiltered!.firstWhere((airport) {
        final airportName = airport.name?.toLowerCase() ?? '';
        return airportName.contains(query) || query.contains(airportName);
      });
    } catch (_) {
      print('errore');
      return null; // Aeroporto non trovato
    }
  }
}

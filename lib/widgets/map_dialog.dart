import 'package:plan_it/resource/exports.dart';

class MapDialog extends StatefulWidget {
  String? location;
  String? title;
  Map<String, dynamic>? searchedLocation;
  final TextEditingController? locationController;

  MapDialog({
    required this.location,
    required this.title,
    required this.searchedLocation,
    required this.locationController,
  });

  @override
  State<MapDialog> createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  MapController mapPickerController = MapController();
  final TextEditingController searchController = TextEditingController();

  //-------------------------------------------------------------------formatta l'indirizzo
  String _formattaPlacemark(Placemark p) {
    final city = p.locality ?? '';
    final street = p.street ?? '';

    // street spesso è già "via + civico", quindi basta dividere
    final parts = street.split(',');
    final onlyStreet = parts.first.trim();

    return "$onlyStreet, $city";
  }

  //------------------------------------------------------------------funzione di ricerca
  Future<void> searchLocation(
    String query,
    BuildContext context, {
    String? cityName,
  }) async {
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No results found.')));
        }
        return;
      }

      final loc = locations.first;
      final placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );

      String formattedAddress = placemarks.isNotEmpty
          ? _formattaPlacemark(placemarks.first)
          : query;

      // se si include anche il nome
      if (cityName != null && cityName.isNotEmpty) {
        formattedAddress = '$cityName, $formattedAddress';
      }

      // aggiorno la mappa
      mapPickerController.move(LatLng(loc.latitude, loc.longitude), 16);

      // salvo per il bottone
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      widget.searchedLocation = {
        'lat': loc.latitude,
        'lon': loc.longitude,
        'city': place?.locality ?? '',
        'country': place?.country ?? '',
      };
      widget.location = formattedAddress;
      widget.title = query;
      setState(() {}); // aggiorna la UI del dialog
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      //--------------------------------------------------------------------contenitore esterno
      child: Container(
        height: 350,
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Container(
              //------------------------------------------------------------contenitore interno
              height: 350,
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xFF7D9EA2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: FlutterMap(
                        mapController: mapPickerController,
                        options: MapOptions(
                          initialCenter: LatLng(41.9027835, 12.4963655), // Roma
                          initialZoom: 14.0,
                          onMapReady: () {
                            setState(() {});
                          },
                        ),
                        children: [
                          TileLayer(
                            // Questo è l'URL per le tessere di OpenStreetMap, gratuito
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.plan_it',
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Card(
                              elevation: 4.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search for your destination',

                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) async {
                                    await searchLocation(
                                      searchController.text,
                                      context,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // 2. Livello delle Tessere (Mappa Base)

                          // 3. L'Icona Fissa al Centro dello Schermo
                          const Center(
                            child: Icon(
                              Icons.location_pin,
                              size: 45,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              //-----------------------------------------------------------BOTTONI CHIUSURA
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      //----------------------------------------------bottone ricerca
                      child: GestureDetector(
                        onTap: () async {
                          // CHIAMA LA FUNZIONE DI RICERCA
                          await searchLocation(searchController.text, context);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5AD2B),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                            ),
                          ),
                          width: double.infinity,
                          height: 45,
                          child: const Center(
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 45, color: Colors.white),
                    Expanded(
                      //------------------------------------------- bottone chiusura
                      child: GestureDetector(
                        onTap: () async {
                          //MODIFICA CHIAVE: Restituisce searchedLocation al chiamante
                          final locToUse =
                              widget.searchedLocation ??
                              {
                                'adress': widget.locationController!.text,
                              }; // Fallback se non è stata fatta ricerca

                          Navigator.pop(
                            context,
                            locToUse,
                          ); // Restituisce la mappa di localizzazione o il fallback
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5AD2B),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          width: double.infinity,
                          height: 45,
                          child: const Center(
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

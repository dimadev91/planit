import 'package:plan_it/resource/exports.dart';

class MapTimeline extends StatefulWidget {
  String? activityTitle;
  String searchedLocation;

  MapTimeline({
    required this.activityTitle,
    required this.searchedLocation,
    Key? key,
  }) : super(key: key);

  @override
  State<MapTimeline> createState() => MapTimelineState();
}

class MapTimelineState extends State<MapTimeline> {
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
  Future<void> searchLocation(String address) async {
    if (address.isEmpty) return;

    try {
      final results = await locationFromAddress(address);

      if (results.isNotEmpty) {
        final loc = results.first;
        mapPickerController.move(LatLng(loc.latitude, loc.longitude), 16);
      } else {
        debugPrint('Nessun risultato per: $address');
      }
    } catch (e) {
      debugPrint('Errore geocoding ($address): $e');
    }
  }

  @override
  void didUpdateWidget(covariant MapTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se è cambiato l’indirizzo, aggiorna la mappa
    if (widget.searchedLocation.isNotEmpty &&
        widget.searchedLocation != oldWidget.searchedLocation) {
      searchLocation(widget.searchedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: 280,
          width: 350,
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.plan_it',
              ),

              // 3. L'Icona Fissa al Centro dello Schermo
              const Center(
                child: Icon(Icons.location_pin, size: 45, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

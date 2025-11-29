import 'package:flutter/foundation.dart';
import 'package:plan_it/resource/exports.dart';

class TripListScreen extends StatefulWidget {
  final String currentUserId;

  TripListScreen({required this.currentUserId, super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DateTime> dates = [];
  bool isLoading = true;
  late List<Trip> displayedTrips;
  //------------------------------------------------------------------------------dialog crea/modifica
  void openTripDialog(BuildContext context) {
    showDialog(
      barrierColor: Colors.transparent, // rimuove il grigio
      context: context,
      builder: (context) {
        return saveUpdateTripDialog(
          onTripSavedAndRefresh: () {
            refreshTrips();
            return Future.value(true);
          },
          dates: dates,
          currentUserId: widget.currentUserId,
          tripSelected: null,
        );
      },
    );
  }

  //----------------------------------------funzione carica viaggi
  Future<void> _loadTrips() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('userId', isEqualTo: widget.currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final mappedTrips = await compute(_mapDocsToTrips, snapshot.docs);

      if (!mounted) return;

      setState(() {
        displayedTrips = mappedTrips;
        isLoading = false;
      });
    } catch (e) {
      print('Errore caricamento viaggi: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  //-----------------------------------------funzione refresh
  Future<void> refreshTrips() async => await _loadTrips();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (displayedTrips.isEmpty) {
      return const Center(
        child: Text(
          'Start to plan your next trip!',
          style: TextStyle(color: Colors.white70, fontSize: 22),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshTrips,
      color: Colors.white,
      backgroundColor: Colors.blueGrey,
      child: Stack(
        children: [
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: displayedTrips.length,
            itemBuilder: (context, index) {
              final trip = displayedTrips[index];
              return TripCard(
                trip: trip,
                onUpdated: refreshTrips,
                currentUserId: widget.currentUserId,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFF5AD2B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  //aggiungiamo l'operatore perchè l'inizializzazione dell'utente ha un ritardo -perchè lanimazione giri-
                  onPressed: () {
                    openTripDialog(context);
                  },
                  child: Icon(Icons.add, size: 40, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Trip> _mapDocsToTrips(List<QueryDocumentSnapshot> docs) {
  return docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip.fromFirestore(data, doc.id);
  }).toList();
}

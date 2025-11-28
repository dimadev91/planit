import 'package:flutter/foundation.dart';
import 'package:plan_it/resource/exports.dart';

class TripListScreen extends StatefulWidget {
  final String userId;

  TripListScreen({required this.userId, super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Trip> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .get();

      final mappedTrips = await compute(_mapDocsToTrips, snapshot.docs);

      if (!mounted) return;

      setState(() {
        trips = mappedTrips;
        isLoading = false;
      });
    } catch (e) {
      print('Errore caricamento viaggi: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> refreshTrips() async {
    await _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (trips.isEmpty) {
      return Center(
        child: Text(
          'Start to plan your next trip!',
          style: TextStyle(color: Colors.white70, fontSize: 22),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshTrips, // chiama la funzione per ricaricare i dati
      color: Colors.white, // colore dell’indicatore
      backgroundColor: Colors.blueGrey, // sfondo dell’indicatore
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(), // necessario per RefreshIndicator
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return TripCard(
            trip: trip,
            onUpdated: refreshTrips,
            currentUserId: widget.userId,
          );
        },
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

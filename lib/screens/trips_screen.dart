import 'package:flutter/foundation.dart';
import 'package:plan_it/resource/exports.dart';

class CreationScreen extends StatefulWidget {
  static const id = 'creation_page';

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {
  late OverlayEntry _overlayEntry;
  bool isVisible = false;
  List<DateTime> dates = [];
  String? _currentUserId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _tripListKey = GlobalKey<_TripListScreenState>();

  OverlayEntry _createOverlayEntry() {
    if (_currentUserId == null) {
      return OverlayEntry(builder: (context) => Container());
    }

    return OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _overlayEntry.remove();
              isVisible = false;
            },
            child: Container(
              color: Color(0xFF20272A),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: CreationDialog(
              onTripSavedAndRefresh: () {
                showHideOverlay();
                _tripListKey.currentState?.refreshTrips();
                return Future.value(
                  true,
                ); // oppure Future.value(true) se è async
              },

              dates: dates,
              currentUserId: _currentUserId!,
              tripToEdit: null,
              docIdToEdit: null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      try {
        UserCredential userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
        print('Login Anonimo riuscito. User ID: ${user!.uid}');
      } catch (e) {
        print('Errore login anonimo: $e');
        if (mounted) setState(() => _currentUserId = null);
        return;
      }
    } else {
      print('Utente già loggato. User ID: ${user.uid}');
    }

    if (mounted) {
      setState(() {
        _currentUserId = user?.uid;
      });
    }
  }

  void showHideOverlay() {
    if (!isVisible) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      isVisible = true;
    } else {
      isVisible = false;
      _overlayEntry.remove();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), _initializeUser);

    final overlayProvider = context.read<OverlayProvider>();
    overlayProvider.addListener(() {
      if (overlayProvider.isVisible != isVisible) {
        showHideOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, OverlayProvider overlayProvider, child) {
        if (overlayProvider.isVisible != isVisible) {
          showHideOverlay();
        }

        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFF5AD2B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              onPressed: _currentUserId == null
                  ? null
                  : () {
                      showHideOverlay();
                    },
              child: Icon(Icons.add, size: 40, color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF0B161A),
          body: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset(
                    'assets/images/sfondo4.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    Material(
                      elevation: 3,
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 90,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFF527882).withOpacity(0.30),
                              ),
                              height: 3,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 35.0, left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'logoAccent',
                        child: Image.asset(
                          'assets/images/logo/loghiAccent.png',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 90, left: 25, right: 25),
                child: _currentUserId == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFF5AD2B),
                        ),
                      )
                    : TripListScreen(
                        key: _tripListKey,
                        userId: _currentUserId!,
                        showClose: showHideOverlay,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TripListScreen extends StatefulWidget {
  final String userId;
  final VoidCallback showClose;

  TripListScreen({required this.userId, super.key, required this.showClose});

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
          return TripCard(trip: trip, onUpdated: refreshTrips);
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

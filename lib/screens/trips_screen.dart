import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/trip_list_screen.dart';

class CreationScreen extends StatefulWidget {
  static const id = 'creation_page';

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {
  bool isVisible = false;

  String? _currentUserId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //-------------------------------------------------------------------------
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), _initializeUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              //-----------------------------------------------------APPBAR
              children: [
                Material(
                  elevation: 3,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 70,
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
          ), //------------------------------------------------------------------LOGO
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 25.0, left: 20),
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
            //---------------------------------------------------la lista
            padding: const EdgeInsets.only(top: 90, left: 25, right: 25),
            child: _currentUserId == null
                ? Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFF5AD2B),
                    ),
                  )
                : TripListScreen(currentUserId: _currentUserId!),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/rendering.dart';
import 'package:plan_it/resource/exports.dart';

import 'firebase_options.dart';

void main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(PlanIt());
}

class PlanIt extends StatelessWidget {
  final ThemeData kGlobalTheme = kTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,

      // Rimuovi anche il banner "DEBUG" se non lo vuoi
      debugShowCheckedModeBanner: false,
      theme: kGlobalTheme,
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        HomePage.id: (context) => HomePage(),
        DetailsScreen.id: (context) => DetailsScreen(),
      },
      onGenerateRoute: (settings) {
        Widget destinationPage = CreationScreen();
        if (settings.name == CreationScreen.id) {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return destinationPage;
            },
            transitionDuration: Duration(milliseconds: 1500),
          );
        }
        return null;
      },
    );
  }
}

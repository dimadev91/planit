import 'package:plan_it/resource/exports.dart';

class SplashScreen extends StatefulWidget {
  static const String id = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimatedTextController controller;
  late AnimationController animationController;
  bool isAnimating = true;

  @override
  void initState() {
    super.initState();
    // controller = AnimatedTextController();
    Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pushNamed(context, CreationScreen.id);
    });
    // animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 500),
    // );
    // animationController.reset();
    // animationController.forward();
    // animationController.addListener(() {
    //   setState(() {});
    // });
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   animationController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF122C33),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Opacity(
                opacity: isAnimating ? 0 : animationController.value,
                child: Image.asset(
                  'assets/images/sfondo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white.withOpacity(0.1),
            ),
            onTap: () {
              setState(() {
                isAnimating = false;
              });
              Navigator.pushReplacementNamed(context, CreationScreen.id);
            },
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container(), flex: 3),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(child: TextInit(text: 'Plan')),
                        // if (isAnimating) ...[
                        //   SizedBox(
                        //     child: DefaultTextStyle(
                        //       style: const TextStyle(
                        //         fontFamily: 'Orbiton',
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 30.0,
                        //         color: Color(0xFFE5A13E),
                        //       ),
                        //       child: AnimatedTextKit(
                        //         onFinished: () async {
                        //           setState(() {
                        //             isAnimating = false;
                        //           });
                        //           animationController.reset();
                        //           animationController.forward();
                        //           Future.delayed(
                        //             Duration(milliseconds: 800),
                        //             () {
                        //               Navigator.pushReplacementNamed(
                        //                 context,
                        //                 HomePage.id,
                        //               );
                        //             },
                        //           );
                        //         },
                        //         isRepeatingAnimation: false,
                        //         controller: controller,
                        //         animatedTexts: [
                        //           RotateAnimatedText(
                        //             ' your journey',
                        //             duration: Duration(milliseconds: 1000),
                        //           ),
                        //           RotateAnimatedText(
                        //             ' your route',
                        //             duration: Duration(milliseconds: 1000),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ] else ...[
                        //   Text(
                        //     ' it with',
                        //     style: TextStyle(
                        //       fontFamily: 'Orbiton',
                        //       fontSize: 30,
                        //       fontWeight: FontWeight.bold,
                        //       color: Color(0xFFE5A13E),
                        //     ),
                        //   ),
                        //   SizedBox(width: 10),
                        SizedBox(
                          width: 250,
                          child: Hero(
                            tag: 'logoAccent',
                            child: Image.asset(
                              'assets/images/logo/loghiAccent.png',
                              height: 200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container(), flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextInit extends StatelessWidget {
  String text;

  TextInit({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Orbiton',
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE5A13E),
      ),
    );
  }
}

import 'package:plan_it/resource/exports.dart';

class HomePage extends StatefulWidget {
  static const id = 'home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    transitionOpacity();
  }

  Future<void> transitionOpacity() async {
    await Future.delayed(Duration(seconds: 2));
    controller.addListener(() {
      setState(() {});
    });
    await controller.forward();
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCE2DF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/sfondo.png', fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 2,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 70,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      height: 3,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white.withOpacity(0.3),
          ),
          Center(
            child: Padding(
              padding: kIsWeb
                  ? EdgeInsets.only(top: 30, left: 150, right: 200)
                  : EdgeInsets.only(left: 20, right: 20, bottom: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'hero',
                        child: Image.asset(
                          height: 165,
                          'assets/images/logo/loghi1.png',
                        ),
                      ),
                      Opacity(
                        opacity: controller.value,
                        child: Hero(
                          tag: 'logoAccent',
                          child: Image.asset(
                            height: 165,
                            'assets/images/logo/loghiAccent.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 45),
                  TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email',
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password',
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButton(
                          color: Color(0xFF628580),
                          text: 'Log In',
                          onPress: () {
                            Navigator.pushReplacementNamed(
                              context,
                              CreationScreen.id,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RoundedButton(
                          color: Color(0xFF628580),
                          text: 'Register',
                          onPress: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     height: 70,
          //     child: ClipRect(
          //       child: BackdropFilter(
          //         filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             color: Colors.black.withOpacity(0.1),
          //           ),
          //           height: 3,
          //           width: double.infinity,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

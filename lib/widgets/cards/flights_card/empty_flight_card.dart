import 'package:plan_it/resource/exports.dart';

class EmptyFlightCard extends StatelessWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  double imageHeight;

  EmptyFlightCard({
    this.imageHeight = 70,
    required this.imageAsset,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        height: MediaQuery.of(context).size.height / 9,
        width: MediaQuery.of(context).size.width / 1.1,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                children: [
                  //---------------------------------------testo
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xCF21373D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10), //--------------------------riga
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width,
                    color: Color(0x1121373D),
                  ),
                  Flexible(
                    //----------------------------------------immagine
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imageAsset),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Flexible(
            //   child: Center(
            //     child: Image.asset(
            //       imageAsset,
            //       height: imageHeight,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

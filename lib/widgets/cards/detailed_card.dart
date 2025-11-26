import 'package:plan_it/resource/exports.dart';

class DetailsCard extends StatelessWidget {
  // Proprietà standard, senza 'status'
  final String imageAsset;
  final String title;
  double imageHeight;

  DetailsCard({
    this.imageHeight = 70,
    required this.imageAsset,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: MediaQuery.of(context).size.height / 5.1,
        width: MediaQuery.of(context).size.width / 2.30,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Column(
          children: [
            SizedBox(height: 5),
            //-------------------------------------------testo
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xCF21373D),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: 2,
              width: MediaQuery.of(context).size.width / 3,
              color: Color(0x1121373D),
            ),
            SizedBox(height: 20),
            Image.asset(imageAsset, height: imageHeight),
          ],
        ),
      ),
    );
  }
}

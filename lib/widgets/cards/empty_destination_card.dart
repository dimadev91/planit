import 'package:plan_it/resource/exports.dart';

class EmptyDestinationCard extends StatelessWidget {
  // Proprietà standard, senza 'status'
  String? imageAsset = '';
  final String title;
  double imageHeight;

  EmptyDestinationCard({
    this.imageHeight = 70,
    this.imageAsset,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: MediaQuery.of(context).size.height / 20,
        width: MediaQuery.of(context).size.width / 2.30,
        decoration: BoxDecoration(
          color: kColorCard,
          boxShadow: kShadowCard,
          borderRadius: kRadiusCard,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xCF21373D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

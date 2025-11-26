import 'package:plan_it/resource/exports.dart';

class RoundedButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPress;
  final String text;

  const RoundedButton({
    required this.color,
    required this.onPress,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Material(
        elevation: 1.0,
        color: color,
        borderRadius: BorderRadius.circular(25.0),
        child: SizedBox(
          width: double.infinity,
          child: MaterialButton(
            onPressed: onPress,
            height: 50.0,
            child: Text(text, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

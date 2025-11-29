import 'package:plan_it/resource/exports.dart';

const kColorDivider = Color(0x1F21373D);
const kColorMiniCard = Color(0xFFD4E1E0);
const kColorBudget = Color(0x325D7881);
final kRadiusCard = BorderRadius.all(Radius.circular(20));
final kShadowCard = [
  BoxShadow(color: Color(0x3F3A3D3D), blurRadius: 20, spreadRadius: 2),
];
const kColorCard = Color(0xFFFAFAFA);
const kColorAccent = Color(0xFF628580);
const kMainColor = Color(0xFFEC9B27);
const kMainColorFade = Color(0xFFEFB86A);
const kBackgroundColor = Color(0xFFCCE2DF);
const kDialogTextStyle = TextStyle(color: Colors.white, fontSize: 18);
const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your password',
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(25.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF213638), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(25.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF213638), width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(25.0)),
  ),
);
const kTextFieldAdd = InputDecoration(
  hintText: 'Enter your password',
  hintStyle: TextStyle(color: Colors.white, fontSize: 18),
  filled: false,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
);

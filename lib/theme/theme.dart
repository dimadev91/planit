import 'package:flutter/material.dart';

final ThemeData kTheme = ThemeData(
  useMaterial3:
      true, // abilita il design Material 3 (nuovo stile di componenti e colori)
  colorSchemeSeed: const Color(
    0xFFCCE2DF,
  ), // colore principale da cui Flutter genera automaticamente una palette di colori coerente
  scaffoldBackgroundColor: const Color(
    0xFFCCE2DF,
  ), // colore di sfondo predefinito per tutte le Scaffold (pagine)

  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.white, // colore delle icone nella AppBar
    ),
    // definisce lo stile predefinito per tutte le AppBar
    backgroundColor: Color(0xFFFAA225), // colore di sfondo della AppBar
    foregroundColor:
        Colors.black, // colore del testo e delle icone della AppBar
    elevation: 2,
    shadowColor: Color(
      0xFF213638,
    ), // ombra sotto la AppBar (più alto = ombra più visibile)
  ),

  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Color(0xFFEC9B27),
    elevation: 5,
    shadowColor: Color(0xFF213638),
    height: 50.0,
    // colore di sfondo della BottomAppBar
  ),
);
//
//   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//     selectedItemColor: Colors.blue, // colore icona selezionata
//     unselectedItemColor: Colors.grey, // colore icona non selezionata
//     type: BottomNavigationBarType.fixed, // mantiene le icone sempre visibili
//     // shadowColor non esiste direttamente per BottomNavigationBar,
//     // l'elevation gestisce l'ombra
//   ),
// );

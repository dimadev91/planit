import 'package:plan_it/resource/exports.dart';

class CalendareRange extends StatefulWidget {
  final VoidCallback showHideOverlay;
  List<DateTime> dates;
  final ValueChanged<List<DateTime>>
  onDatesChanged; //notifica il cambiamento al genitore
  CalendareRange({
    required this.showHideOverlay,
    required this.dates,
    required this.onDatesChanged,
  });

  @override
  State<CalendareRange> createState() => _CalendareRangeState();
}

class _CalendareRangeState extends State<CalendareRange> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38, // sfondo semi-trasparente
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    //--------------------------------------------------------colore contorno
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFF7D9EA2),
                  ),
                  height: 410,
                  width: 350,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => widget.showHideOverlay(),
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Material(
              child: SizedBox(
                width: 345,
                height: 330,
                child: Column(
                  children: [
                    Expanded(
                      //------------------------------------------------------CALENDARIO
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.range,
                          selectedDayHighlightColor: Color(0xFFF3AC2B),
                          selectedDayTextStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          weekdayLabelTextStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: widget.dates, // Usa la variabile di stato
                        onValueChanged: (value) {
                          // setState(() {
                          //   // puoi aggiornare eventuale stato interno locale se vuoi
                          // });
                          widget.onDatesChanged(value); // notifico il genitore
                        },
                        // Usa la variabile di stato
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

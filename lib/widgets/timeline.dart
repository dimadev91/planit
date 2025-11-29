import 'dart:math' as math;

import 'package:plan_it/resource/exports.dart';
import 'package:plan_it/services/timeline_event_class.dart';
import 'package:plan_it/widgets/map_timline.dart';

//------------------------------------------------------------------timeline verticale
class TimelineWidget extends StatefulWidget {
  final String tripId;
  final List<TimelineEvent> events;
  TimelineWidget({required this.events, required this.tripId, super.key});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget>
    with SingleTickerProviderStateMixin {
  final mapKey = GlobalKey<MapTimelineState>();
  String selectedLocation = ''; //serve per la mappa
  int index = 0; //serve per la mappa
  bool isExpanded = false;
  AnimationController? _animationController;

  void toggleExpanded() {
    if (_animationController!.isAnimating) {
      return;
    }
    ;
    setState(() {
      isExpanded = !isExpanded;
    });
    if (isExpanded) {
      _animationController!.forward();
    } else {
      _animationController!.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20),
      child: Stack(
        children: [
          Column(
            children: [
              isExpanded
                  ? Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 140,
                    )
                  : Container(),
              Flexible(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: (-math.pi / 2) * _animationController!.value,
                      child: Container(
                        // CONTAINER CHE CONTIENE ICONA-LINEA-TESTO
                        width:
                            isExpanded //quando si espande riduce la larghezza che nella rotazione diventa l'altezza
                            ? 230
                            : MediaQuery.of(context).size.width,
                        // height: isExpanded ? 350 : 450,
                        color: Colors.transparent,
                        child: ListView.builder(
                          itemCount: widget.events.length,
                          itemBuilder: (context, index) {
                            final bool isEven = index % 2 == 0;
                            final event = widget.events[index];
                            final isLast = index == widget.events.length - 1;

                            return Center(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        // questa linea serve per mantenere la larghezza della column fissa se non si adatta al child
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.2 +
                                            (-_animationController!.value * 55),

                                        color: Colors.transparent,
                                      ),
                                      // --------------------ICONA
                                      Transform.translate(
                                        offset: Offset(
                                          -5 * _animationController!.value,
                                          0,
                                        ),
                                        child: Transform.rotate(
                                          angle:
                                              (math.pi / 2) *
                                              _animationController!.value,
                                          child: GestureDetector(
                                            //-------------pulsante
                                            //azione cliccando icona
                                            onTap: () async {
                                              setState(() {
                                                this.index = index;
                                                selectedLocation =
                                                    event.location!;
                                              });
                                              print('Tapped on icon $index');
                                              print('${event.title}');
                                            },
                                            child: Container(
                                              width: 55,
                                              height: 55,
                                              decoration: BoxDecoration(
                                                color: !isEven
                                                    ? Colors.white
                                                    : Color(0xFF155A75),
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 1,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                event.icon, //icona delle'evento
                                                size: 35,
                                                color: !isEven
                                                    ? Color(0xFF155A75)
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //---------------------LINEA NODO
                                      if (!isLast) //se non è lultimo nodo disegna la linea
                                        Transform.translate(
                                          offset: Offset(
                                            -5 * _animationController!.value,
                                            0,
                                          ),
                                          child: Container(
                                            width: 3,
                                            height:
                                                60 +
                                                60 *
                                                    _animationController!
                                                        .value, //allunga la linea di connesione
                                            color: Color(0xFF155A75),
                                          ),
                                        ),
                                    ],
                                  ),
                                  //--------------------------------------------------------TEXT
                                  Transform.translate(
                                    //posta il testo più in basso
                                    offset: Offset(
                                      -20 * _animationController!.value,
                                      0,
                                    ),
                                    child: Padding(
                                      padding: !isEven
                                          //----------pari
                                          ? EdgeInsets.only(
                                              left:
                                                  200 *
                                                  (1 -
                                                      _animationController!
                                                          .value), //azzera il padding in base al controller
                                            )
                                          //-----------dispari
                                          : EdgeInsets.only(top: 0),
                                      child: Container(
                                        //container del testo
                                        width:
                                            MediaQuery.of(context).size.width /
                                            3.1 *
                                            (1 -
                                                _animationController!.value +
                                                1 *
                                                    _animationController!
                                                        .value),
                                        child: Transform.rotate(
                                          angle:
                                              (math.pi / 2) *
                                              _animationController!
                                                  .value, //ruota di 90 gradi
                                          child: Text(
                                            textAlign: isEven
                                                ? isExpanded
                                                      ? TextAlign.center
                                                      : TextAlign.end
                                                : isExpanded
                                                ? TextAlign.center
                                                : TextAlign.start,
                                            //testo e date dell'evento
                                            '${event.title.replaceAll('\n', ' ')}\n' //elimina a capo contenuto nel testo
                                            '${DateFormat('dd/MM/yy').format(event.datetime)}\n'
                                            '${DateFormat('HH:mm').format(event.datetime)}',
                                            style: TextStyle(
                                              height: 0.95,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          isExpanded
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                  child: MapTimeline(
                    key: mapKey,
                    activityTitle: widget.events[index].title,
                    searchedLocation: selectedLocation,
                  ),
                )
              : SizedBox.shrink(),

          //-----------------------------------------------------PULSANTE MAPPA
          ?widget.events.isEmpty
              ? null
              : Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: () {
                          toggleExpanded();
                        },
                        icon: Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

//-----------------------------------------------------------TIMELINE ORIZZONALE
// class TimelineWidgetHorizontal extends StatefulWidget {
//   final String tripId;
//   final List<TimelineEvent> events;
//   TimelineWidgetHorizontal({
//     required this.events,
//     required this.tripId,
//     super.key,
//   });
//
//   @override
//   State<TimelineWidgetHorizontal> createState() =>
//       _TimelineWidgetHorizontalState();
// }
//
// class _TimelineWidgetHorizontalState extends State<TimelineWidgetHorizontal>
//     with SingleTickerProviderStateMixin {
//   bool isExpanded = false;
//   AnimationController? _animationController;
//
//   void toggleExpanded() {
//     if (_animationController!.isAnimating) {
//       return;
//     }
//     ;
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//     if (isExpanded) {
//       _animationController!.forward();
//     } else {
//       _animationController!.reverse();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController!.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 6,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10.0, right: 10),
//             child: Transform.rotate(
//               angle: (-math.pi / 2) * _animationController!.value,
//               child: GestureDetector(
//                 onTap: () {
//                   toggleExpanded();
//                 },
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.events.length,
//                   itemBuilder: (context, index) {
//                     final bool isEven = index % 2 == 0;
//                     final event = widget.events[index];
//                     final isLast = index == widget.events.length - 1;
//
//                     return SizedBox(
//                       width: 157,
//                       height: 130,
//                       child: Stack(
//                         children: [
//                           Row(
//                             children: [
//                               // Icona del nodo
//                               Container(
//                                 //-----------container con le icone
//                                 width: 55,
//                                 height: 55,
//                                 decoration: BoxDecoration(
//                                   color: !isEven
//                                       ? Colors.white
//                                       : Color(0xFF155A75),
//                                   borderRadius: BorderRadius.circular(28),
//                                 ),
//                                 child: Icon(
//                                   event.icon,
//                                   size: 35,
//                                   color: !isEven
//                                       ? Color(0xFF155A75)
//                                       : Colors.white,
//                                 ),
//                               ),
//
//                               //------------------Linea verso il nodo successivo
//                               if (!isLast)
//                                 Container(
//                                   width: 100,
//                                   height: 3,
//                                   color: Color(0xFF155A75),
//                                 ),
//                             ],
//                           ),
//                           Container(
//                             //----------------------------------------container testi
//                             height: MediaQuery.of(context).size.width / 1.85,
//                             width: 150,
//                             child: Padding(
//                               padding: isEven
//                                   ? EdgeInsets.only(top: 60)
//                                   : EdgeInsets.only(top: 60),
//                               child: Text(
//                                 textAlign: isEven
//                                     ? TextAlign.start
//                                     : TextAlign.start,
//                                 '${event.title.replaceAll('\n', ' ')}\n'
//                                 '${DateFormat('dd/MM/yyyy').format(event.datetime)}\n'
//                                 '${DateFormat('HH:mm').format(event.datetime)}',
//                                 style: TextStyle(
//                                   height: 0.95,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 3,
//           child: Container(
//             color: Colors.yellow,
//             width: MediaQuery.of(context).size.width / 1.1,
//             height: 30,
//           ),
//         ),
//       ],
//     );
//   }
// }

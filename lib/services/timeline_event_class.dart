import 'package:plan_it/resource/exports.dart';

//il file contiene sia la classe venti che le funzioni per generale le lista eventi di ogni tipo
//-----------------------------------unita base della timeline
class TimelineEvent {
  final DateTime datetime;
  final String title;
  final IconData icon;
  final String? location;
  String? description;
  String? duration;
  double? price;

  TimelineEvent({
    required this.datetime,
    required this.title,
    required this.icon,
    required this.location,
    this.description,
    this.price,
    this.duration,
  });
}

class TimelineEventMapper {
  //crea una lista di TimelineEvent a partire da una lista di oggetti Activity in modo statico accessibile senza ricreare loggetto
  //ACTIVITY
  static List<TimelineEvent> fromActivities(List activities) {
    if (activities.isEmpty) return [];

    return activities
        .where((a) => a.activityTime != null && a.activityName != null)
        .map(
          (a) => TimelineEvent(
            datetime: a.activityTime!,
            title: a.activityName!,
            icon: Icons.directions_run_outlined,
            description: a.activityLocation,
            price: a.activityPrice,
            duration: a.activityDuration?.toString(),
            location: a.activityLocation,
          ),
        )
        .toList()
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
  }

  //FOOD
  static List<TimelineEvent> fromFood(List<Food> food) {
    if (food.isEmpty) return [];

    return food
        .where((f) => f.restTime != null && f.restName != null)
        .map(
          (f) => TimelineEvent(
            datetime: f.restTime!,
            title: f.restName!,
            icon: Icons.restaurant,
            description: f.restLocation,
            price: f.restPriceRange,
            location: f.restLocation,
          ),
        )
        .toList()
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
  }
}

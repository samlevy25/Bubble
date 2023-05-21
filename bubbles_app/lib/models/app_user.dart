import 'package:bubbles_app/models/activity.dart';

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String imageURL;
  late DateTime lastActive;
  late List<Activity> activities;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageURL,
    required this.lastActive,
    required this.activities,
  });

  factory AppUser.fromJSON(Map<String, dynamic> json) {
    final List<dynamic> activitiesJson = json["activities"];
    List<Activity> activities = [];

    if (activitiesJson != null && activitiesJson is List) {
      activities = activitiesJson.map((activityJson) {
        final String description = activityJson["description"];
        final DateTime date = DateTime.parse(activityJson["date"]);
        return Activity(description, date);
      }).toList();
    }

    return AppUser(
      uid: json["uid"],
      username: json["username"],
      email: json["email"],
      imageURL: json["image"],
      lastActive: json["last_active"].toDate(),
      activities: activities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "username": username,
      "last_active": lastActive,
      "image": imageURL,
    };
  }

  String lastDayActive() {
    return "${lastActive.day}/${lastActive.month}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 1;
  }
}

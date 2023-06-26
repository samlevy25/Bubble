import 'package:bubbles_app/models/activity.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String imageURL;
  late DateTime lastActive;
  late List<Activity> activities;
  late int upVotes;
  late int downVotes;
  late int numberOfVotes;
  String preferredLanguage;

  final DatabaseService _db = GetIt.instance.get<DatabaseService>();

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageURL,
    required this.lastActive,
    required this.activities,
    required this.upVotes,
    required this.downVotes,
    required this.numberOfVotes,
    required this.preferredLanguage,
  });

  factory AppUser.fromJSON(Map<String, dynamic> json) {
    return AppUser(
      uid: json["uid"],
      username: json["username"],
      email: json["email"],
      imageURL: json["image"],
      lastActive: json["last_active"].toDate(),
      activities: json["activities"] ?? [],
      upVotes: json["up_votes"] ?? 0,
      downVotes: json["down_votes"] ?? 0,
      numberOfVotes: json["number_of_votes"] ?? 0,
      preferredLanguage: json["preferred_language"] ?? "en",
    );
  }

  String lastDayActive() {
    return "${lastActive.day}/${lastActive.month}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 1;
  }

  Future<void> addActivity(Activity activity) async {
    activities.add(activity);
    await _db.addUserActivity(uid, activity);
  }
}

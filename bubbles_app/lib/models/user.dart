class AppUser {
  final String uid;
  final String username;
  final String email;
  final String imageURL;
  late DateTime lastActive;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageURL,
    required this.lastActive,
  });

  factory AppUser.fromJSON(Map<String, dynamic> json) {
    return AppUser(
      uid: json["uid"],
      username: json["username"],
      email: json["email"],
      imageURL: json["image"],
      lastActive: json["last_active"].toDate(),
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

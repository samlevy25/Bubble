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

  factory AppUser.fromJSON(Map<String, dynamic> _json) {
    return AppUser(
      uid: _json["uid"],
      username: _json["username"],
      email: _json["email"],
      imageURL: _json["image"],
      lastActive: _json["last_active"].toDate(),
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

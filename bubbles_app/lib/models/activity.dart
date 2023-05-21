class Activity {
  final String description;
  final DateTime date;

  Activity(this.description, this.date);

  factory Activity.userJoinedBubble(String bubbleName) {
    final description = 'User joined the bubble $bubbleName';
    final date = DateTime.now();
    return Activity(description, date);
  }
}

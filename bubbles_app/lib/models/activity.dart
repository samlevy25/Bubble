class Activity {
  final String description;
  final DateTime date;

  Activity(this.description, this.date);

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date,
    };
  }
}

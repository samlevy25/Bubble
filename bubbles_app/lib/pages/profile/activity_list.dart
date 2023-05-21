import 'package:flutter/material.dart';

import '../../models/activity.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;

  const ActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: activities.length,
      separatorBuilder: (context, index) =>
          const Divider(), // Add a separator between list items
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          title: Text(activity.description),
          subtitle: Text(activity.date.toString()),
        );
      },
    );
  }
}

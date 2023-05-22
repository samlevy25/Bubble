import 'package:flutter/material.dart';

class FavoritsList extends StatelessWidget {
  final List favorits;

  const FavoritsList({super.key, required this.favorits});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: favorits.length,
      separatorBuilder: (context, index) =>
          const Divider(), // Add a separator between list items
      itemBuilder: (context, index) {
        final fav = favorits[index];
        return ListTile(
          title: Text("Favorit"),
        );
      },
    );
  }
}

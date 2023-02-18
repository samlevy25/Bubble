import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

class BubblesPage extends StatefulWidget {
  const BubblesPage({super.key});

  @override
  State<BubblesPage> createState() => _BubblesPageState();
}

class _BubblesPageState extends State<BubblesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(backgroundColor: Colors.purple);
  }
}

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  final List<Widget> _pages = [
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.blue,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (_index) {
          setState(() {
            currentPage = _index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: "A", icon: Icon(Icons.abc)),
          BottomNavigationBarItem(label: "B", icon: Icon(Icons.abc)),
          BottomNavigationBarItem(label: "C", icon: Icon(Icons.abc)),
        ],
      ),
    );
  }
}

import 'package:automatas_2024/const/const.dart';
import 'package:automatas_2024/screens/Regex/RegexInputScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Stack with the main screen
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatas 2024'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          RegexInputScreen(),
          Text('Business'),
          Text('School'),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  //Bottom bar with 3 options, convert from regular expression to automata, convert from automata to regular expression and convert from automata to grammar
  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.abc),
          label: 'RegEx',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_on_sharp),
          label: 'Convertions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
    );
  }
}

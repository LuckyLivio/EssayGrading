import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'grading_screen.dart';
import 'question_bank_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GradingScreen(),
    const QuestionBankScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_document),
            label: '批改',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: '题库',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: '历史',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:proAluno/screens/tela_flashcards.dart';
import 'package:proAluno/screens/tela_mapa.dart';
import '../screens/tela_perfil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../screens/tela_todolist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabChange(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          TodolistScreen(),
          PerfilScreen(),
          flashcardScreen(),
          MapaScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffE4E4E4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: GNav(
          backgroundColor: const Color(0xffE4E4E4),
          color: const Color(0xFF133E87),
          activeColor: const Color(0xffE4E4E4),
          tabBackgroundColor: const Color(0xFF133E87),
          gap: 10,
          padding: const EdgeInsets.all(14),
          tabs: const [
            GButton(
              icon: Icons.calendar_month,
              text: 'To-do List',
            ),
            GButton(
              icon: Icons.person,
              text: 'Perfil',
            ),
            GButton(
              icon: Icons.folder,
              text: 'Flashcard',
            ),
            GButton(icon: Icons.location_on, text: 'Mapa')
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}

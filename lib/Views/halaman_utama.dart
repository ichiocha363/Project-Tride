import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Widgets/custom_floating_nav_bar.dart';
import 'halaman Ai Planner/halaman_aiplanner_step1.dart';
import 'halaman beranda/halaman_beranda.dart';
import 'halaman budget/halaman_budget.dart';
import 'halaman explore/halaman_jelajah.dart';
import 'halaman profile/halaman_profil.dart';

class HalamanUtama extends StatefulWidget {
  final UserModel? user;
  final int initialTab;

  const HalamanUtama({
    super.key,
    this.user,
    this.initialTab = 0,
  });

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late int _selectedIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HalamanBeranda(
        user: widget.user,
        isEmbeddedInShell: true,
        onSwitchTab: _onTabSelected,
      ),
      HalamanJelajah(
        user: widget.user,
        isEmbeddedInShell: true,
        onSwitchTab: _onTabSelected,
      ),
      HalamanAiPlanner(
        user: widget.user,
        isEmbeddedInShell: true,
        onSwitchTab: _onTabSelected,
      ),
      HalamanBudget(
        user: widget.user,
        isEmbeddedInShell: true,
        onSwitchTab: _onTabSelected,
      ),
      HalamanProfil(
        user: widget.user,
        isEmbeddedInShell: true,
        onSwitchTab: _onTabSelected,
      ),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          _onTabSelected(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: pages,
        ),
        bottomNavigationBar: CustomFloatingNavBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabSelected,
          pageController: _pageController,
        ),
      ),
    );
  }
}

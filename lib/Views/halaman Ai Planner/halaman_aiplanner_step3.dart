import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_aiplanner_step4.dart' as step4;

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final String destination;
  final String dates;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String companion;
  final List<String> styles;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.destination = 'Bali, Indonesia',
    this.dates = '12 - 16 Sep 2024 (5 Hari)',
    this.departureDate,
    this.returnDate,
    this.companion = 'Solo',
    this.styles = const ['Fotografi', 'Alam'],
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  String _selectedBudget = 'Menengah';
  String _selectedPace = 'Seimbang';
  final Set<String> _selectedAccommodations = {'Hotel'};

  final List<Map<String, dynamic>> _budgetLevels = [
    {
      'title': 'Hemat',
      'icon': Icons.payments_outlined,
      'selectedIcon': Icons.payments_rounded,
    },
    {
      'title': 'Menengah',
      'icon': Icons.account_balance_wallet_outlined,
      'selectedIcon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'Mewah',
      'icon': Icons.monetization_on_outlined,
      'selectedIcon': Icons.monetization_on_rounded,
    },
  ];

  final List<Map<String, dynamic>> _paceLevels = [
    {
      'title': 'Santai',
      'icon': Icons.eco_outlined,
      'selectedIcon': Icons.eco_rounded,
    },
    {
      'title': 'Seimbang',
      'icon': Icons.balance_outlined,
      'selectedIcon': Icons.balance_rounded,
    },
    {
      'title': 'Padat',
      'icon': Icons.bolt_outlined,
      'selectedIcon': Icons.bolt_rounded,
    },
  ];

  final List<Map<String, dynamic>> _accommodations = [
    {
      'title': 'Hotel',
      'icon': Icons.hotel_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDwsITn5_JssB71Ygx4UgfwIpMnmELPcBqikEpcs8piZ4l7WsflXF6-_sEizglp0o5lQwv2iVfYWKyZrMbemX8dM6Oq21Z0vL425NTWs7_5D6dkwYIOJ5TTaUEEoPg4RByciVaPiLLCMTLbdcFrobKGQXSA7lbXdhZnapijLgriFhwkenpwJIWjPfFqs9rhCqjHEja5MfQR33tCIjbK4c5A51RDICJHkHuDMfoJzlpyA8DMglcuQ0dk',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Hostel',
      'icon': Icons.bed_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCXqPBV25BItb36mFso4QruSzr-2XM077JE0r-oi9NICNiCUaASb5W78GpRm2qsUiTWnYtkipdCK-CnV4fUTYmLpCsK6yC-uKXm1k9-nbkHjdLBIWWAUnZ0I0yMbhxmY5dPoNzIbo7nM3Kewgu0J6zThwEUMS5qkyen0o96-l2JHO_3kUi8v6EazGsyBkmDRpEfUbKEZExaWrCbCY7R7ZaXqjXnu4MU7TeZfG5VtqxBk0b8RcNtqLIP',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Homestay',
      'icon': Icons.cottage_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCftqt7tt7m74AVoALutPUl8fO1SjzXKn4DYwPRLy72ro4J1DpTxOaLsh8oVfiihOV6oY4vFh8D9SeLjxywW3G1UadmPUcXS_dZfDJemcGvOE8YOw1L1jw0_sJjEq1cuB72LlINVdQAJwm83CcAf-p_gk5BTdx0F1tvU17dBVLg3rOyS0GXZxyWxofrX7rDaUYTVvEWcdZPHFbcLRMzdSLlfluK3DXuis6Vmoo4zmd_oRXg3ChwS8Qf',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1587061949409-02df41d5e562?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Villa',
      'icon': Icons.holiday_village_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBaEicR8I3mI1d8_dZoKDib2nIVvDZJQ73zs8sC8cJt01I0fa4P9_B1ismZU5jv5RxJJwm8Mr4fLyJs0pcFAYQHkKbPQnt_lOnCcmwc7U4S8f_tM2fFkN5eJm4Myu31wl5P9NAwzPf2H15mlom9upxgJ9eQfFHE5qAO4rMgncmXQUdHQB4GmCBvHgmfMi3BzZ1CJxKqwzcN8uCPH0imzJsCPSS-sFFQYTjfvtWfj7cdIr_NwXxDcXNb',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=600&auto=format&fit=crop',
    },
  ];

  void _toggleAccommodation(String title) {
    setState(() {
      if (_selectedAccommodations.contains(title)) {
        if (_selectedAccommodations.length > 1) {
          _selectedAccommodations.remove(title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pilih minimal 1 preferensi akomodasi."),
              backgroundColor: const Color(0xFFBC4800),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        _selectedAccommodations.add(title);
      }
    });
  }

  void _onContinue() {
    if (_selectedAccommodations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan pilih minimal 1 akomodasi."),
          backgroundColor: const Color(0xFFBC4800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final accommodationsText = _selectedAccommodations.join(', ');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step4.HalamanAiPlanner(
          user: widget.user,
          destination: widget.destination,
          dates: widget.dates,
          departureDate: widget.departureDate,
          returnDate: widget.returnDate,
          companion: widget.companion,
          styles: widget.styles,
          budget: _selectedBudget,
          pace: _selectedPace,
          accommodation: accommodationsText,
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == 2) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanBeranda(user: widget.user),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanJelajah(user: widget.user),
          ),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanBudget(user: widget.user),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanProfil(user: widget.user),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCloud = Color(0xFFF8FAFC);
    const Color textNavy = Color(0xFF191B23);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textSlate = Color(0xFF434655);

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: Row(
              children: [
                Image.asset(
                  'assets/image/playstore.png',
                  height: 32,
                  width: 32,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.explore,
                    color: primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Trips",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textNavy,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanProfil(user: widget.user),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBE1FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: primaryBlue,
                          size: 22,
                        ),
                      ),

                      // Step Indicators (4 steps: 3 active, 1 inactive)
                      Row(
                        children: [
                          _buildStepBar(isActive: true),
                          const SizedBox(width: 4),
                          _buildStepBar(isActive: true),
                          const SizedBox(width: 4),
                          _buildStepBar(isActive: true),
                          const SizedBox(width: 4),
                          _buildStepBar(isActive: false),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Prompt Text
                  const Text(
                    "STEP 3 OF 4",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Berapa budget dan ritme perjalanannya?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ini bantu aku nyusun itinerary yang pas sama gaya kamu.",
                    style: TextStyle(
                      fontSize: 15,
                      color: textSlate,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 1: Level Budget
                  const Text(
                    "Level Budget",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _budgetLevels.map((item) {
                      final title = item['title'] as String;
                      final icon = item['icon'] as IconData;
                      final isSelected = _selectedBudget == title;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildOptionCard(
                            title: title,
                            icon: icon,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedBudget = title;
                              });
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Section 2: Ritme Perjalanan
                  const Text(
                    "Ritme Perjalanan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _paceLevels.map((item) {
                      final title = item['title'] as String;
                      final icon = item['icon'] as IconData;
                      final isSelected = _selectedPace == title;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildOptionCard(
                            title: title,
                            icon: icon,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedPace = title;
                              });
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Section 3: Preferensi Akomodasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Preferensi Akomodasi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Text(
                        "Pilih 1+",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textSlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _accommodations.map((item) {
                        final title = item['title'] as String;
                        final icon = item['icon'] as IconData;
                        final imageUrl = item['imageUrl'] as String;
                        final fallbackUrl = item['fallbackUrl'] as String;
                        final isSelected =
                            _selectedAccommodations.contains(title);

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildAccommodationCard(
                            title: title,
                            icon: icon,
                            imageUrl: imageUrl,
                            fallbackUrl: fallbackUrl,
                            isSelected: isSelected,
                            onTap: () => _toggleAccommodation(title),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Bottom Action Button ("Lanjut")
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lanjut",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // Integrated Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: 2,
          onDestinationSelected: _onNavTapped,
          backgroundColor: Colors.transparent,
          indicatorColor: primaryBlue.withValues(alpha: 0.12),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: primaryBlue),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded, color: primaryBlue),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.luggage_outlined),
              selectedIcon: Icon(Icons.luggage_rounded, color: primaryBlue),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(
                Icons.account_balance_wallet_rounded,
                color: primaryBlue,
              ),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: primaryBlue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBar({required bool isActive}) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color inactiveColor = Color(0xFFE7E7F3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : inactiveColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color selectedBg = Color(0xFFDBE1FF);
    const Color unselectedBg = Color(0xFFEDEDF9);
    const Color textNavy = Color(0xFF191B23);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? primaryBlue : const Color(0xFF434655),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: textNavy,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationCard({
    required String title,
    required IconData icon,
    required String imageUrl,
    required String fallbackUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color primaryBlue = Color(0xFF004AC6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryBlue.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.5),
          child: Stack(
            children: [
              // Background Image with Fallback
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      fallbackUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2563EB),
                          child: Icon(icon, color: Colors.white, size: 40),
                        );
                      },
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Selected Check Badge (Top Right)
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

              // Icon & Title (Bottom Left)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

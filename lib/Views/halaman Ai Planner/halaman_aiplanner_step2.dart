import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_aiplanner_step3.dart' as step3;

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final String destination;
  final String dates;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String companion;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.destination = 'Bali, Indonesia',
    this.dates = '12 - 16 Sep 2024 (5 Hari)',
    this.departureDate,
    this.returnDate,
    this.companion = 'Solo',
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final Set<String> _selectedStyles = {'Fotografi', 'Alam'};
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedItinerary;

  final List<Map<String, dynamic>> _styles = [
    {
      'title': 'Fotografi',
      'icon': Icons.photo_camera_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDMEq8hEqFuzayLd8GJJk8nKoH01BMpPhgW_eXCvuWNAI4heFOV8mdj_6AxDLF4uBDu1JIuYrt6YIdlv-igPForgZf1Tih4qPnH3kLPltgc0Kgnl3os13t6QpQ15PbUYXnvJKQOYfaygJAW5L1u-1Mz4P2SRfbUhV2tllAsqyAvYw7kO0Q2OMmeaULmfpwvwa1xrk3JKcLfBx8_H0pzzQMsStj4EvEA6N0kOjfX0xyVtVv614kCsjDr',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Kuliner',
      'icon': Icons.restaurant_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBWlR1DCyFa0-BHMGMmTdrxFQmVXgGxsiUbFNIanA12y43bF_H0AH374yk-ww2BTcOlNY8E84MYWE86tNjIYM60ZHrURO5FWSR_tTg7l8D1AZVxWr9tYxe5-b1KfsWe2zyqiTbjBbOpK1mWLQn4MLMmgNr8oTJdpuB13mKj-5YpzEF-zKtrsatR-zW8ZjmO4TKr2Dc2dizwoOXjKzo_6EL3akA-5_sqyapCQ2retedO6FcLkGX14YFo',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Alam',
      'icon': Icons.forest_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBhDBYGHAcEW2KxTEHFcS_lKLQI18ahhbt5AobTzjHQHPc-wTgOeQGk7qtlW17_l8Ces_uRrSvReNvwEHKVtzT5GL_-NImtLtlq23V0E-os1Wh1VhWrM2WUJQc7il5dV44lYNItUNths8qrf3RsWC2Qa4YUxXeuxAjwiEalaHiQwq0LVHe7ckZOMXClSi7eNLVpv99U9odT09dpmCnSPO5_iAY0MSRSGrglXmnTLhwvRFaXt1Mlf3th',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Petualangan',
      'icon': Icons.hiking_rounded,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA_ICLJuDQZqAHRl71I4uUFXV0MBEa9triCaYOhhnxom9kR5BLv_yJ8_lRYUjhyvmUws_PJxepGJ-TqIegVNdBnXTiXcHRgh9920OyQthJ17Z-42WqHd19gDIjBTsUZXlm774Jf4u2-PkSJeMxzY1BELIYzJ3IBK14TQ36SAfFf_ew65zfRY86nIxS4AuBA1nspfurYuVEF9jsC5yE5CX-j_iAxRpE8st97CCabNIWwxvdSCQQCKPnn',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop',
    },
  ];

  void _toggleStyle(String title) {
    setState(() {
      if (_selectedStyles.contains(title)) {
        _selectedStyles.remove(title);
      } else {
        _selectedStyles.add(title);
      }
    });
  }

  void _onContinue() {
    if (_selectedStyles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan pilih minimal 1 gaya perjalanan."),
          backgroundColor: const Color(0xFFBC4800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step3.HalamanAiPlanner(
          user: widget.user,
          destination: widget.destination,
          dates: widget.dates,
          departureDate: widget.departureDate,
          returnDate: widget.returnDate,
          companion: widget.companion,
          styles: _selectedStyles.toList(),
        ),
      ),
    );
  }

  void _showItineraryDialog() {
    if (_generatedItinerary == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Generated Itinerary",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          _generatedItinerary!['destination'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text(_generatedItinerary!['duration']),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.style_outlined, size: 16),
                    label: Text(_generatedItinerary!['styles']),
                    backgroundColor: const Color(0xFFDBE1FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      (_generatedItinerary!['schedule'] as List).length,
                  itemBuilder: (context, index) {
                    final dayItem = _generatedItinerary!['schedule'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              dayItem['day'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayItem['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...((dayItem['activities'] as List).map(
                                  (act) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: Color(0xFF3E9C5D),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            act,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.bookmark_added_rounded,
                                color: Colors.white),
                            SizedBox(width: 10),
                            Text("Rencana Perjalanan berhasil disimpan!"),
                          ],
                        ),
                        backgroundColor: const Color(0xFF3E9C5D),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Simpan Rencana Perjalanan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNavTapped(int index) {
    if (index == 1) return; // Currently on Explore / AI Planner

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
    const Color textNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF2563EB);
    const Color textSlate = Color(0xFF64748B);
    const Color surfaceVariant = Color(0xFFE1E2ED);

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // App Bar matching Stitch Header
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
                    Icons.explore_rounded,
                    color: primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Explore",
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC3C6D7),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXqq1x77c9VRZVHgsnEzcobbUiGgu243vdSpBBh8R9ksjOMxm6zdgQFhNNGg108tf06nC5RMB4lUVxHO9dxHFqUto7XCGAqqc3rfE_j7K-bvnGSajKeJv7vCca-_XePIcG-yKS745x2AEOGjOOBPeLEMQu88C60uZFt8DbcT_mhzonP5W4APbXUpny1KZf982dlX03TBl2fz-beG6ATWlPrUMOIyMvYoygQPAIc-3hzBocCCIvkGwI',
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
                    children: [
                      const Icon(
                        Icons.drive_file_rename_outline_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Prompt Text
                  const Text(
                    "STEP 2 OF 4",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Gaya liburan kamu yang mana?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Pilih vibe yang paling bikin kamu excited, nanti itinerary-nya aku sesuaikan.",
                    style: TextStyle(
                      fontSize: 15,
                      color: textSlate,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Choices Grid 2x2
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _styles.length,
                    itemBuilder: (context, index) {
                      final item = _styles[index];
                      final isSelected =
                          _selectedStyles.contains(item['title']);

                      return GestureDetector(
                        onTap: () => _toggleStyle(item['title']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: isSelected ? 14 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              children: [
                                // Background Image
                                Positioned.fill(
                                  child: Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        item['fallbackUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: const Color(0xFF0F172A),
                                            child: Icon(
                                              item['icon'],
                                              color: Colors.white,
                                              size: 40,
                                            ),
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
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Checkmark Badge Top Right
                                if (isSelected)
                                  Positioned(
                                    top: 10,
                                    right: 10,
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

                                // Icon & Label Bottom Left
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          item['icon'],
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['title'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    },
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Menyusun Perjalanan AI...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjut",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Integrated Bottom Navigation Bar matching Stitch Design
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: 1,
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
}

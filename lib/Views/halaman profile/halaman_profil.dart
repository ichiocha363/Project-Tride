import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman_login.dart';

class HalamanProfil extends StatefulWidget {
  final UserModel? user;

  const HalamanProfil({super.key, this.user});

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A)),
            SizedBox(width: 10),
            Text(
              "Konfirmasi Logout",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi Tride?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HalamanLogin()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == 4) return;

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanAiPlanner(user: widget.user),
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
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgSurface = Color(0xFFFAF8FF);
    const Color textNavy = Color(0xFF0F172A);
    const Color textSlate = Color(0xFF64748B);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color naturalGreen = Color(0xFF3E9C5D);
    const Color warmYellow = Color(0xFFFDB813);
    const Color surfaceVariant = Color(0xFFE1E2ED);

    final userName = widget.user?.nama ?? 'Alex Mercer';
    final userEmail = widget.user?.email ?? 'alex.mercer@tride.com';

    return Scaffold(
      backgroundColor: bgSurface,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Banner & Profile Avatar Stack
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Immersive Header Image
                    Container(
                      height: 360,
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Color(0xFF00174B)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1000&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF00174B),
                                      Color(0xFF004AC6),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.landscape_rounded,
                                    size: 80,
                                    color: Colors.white24,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Dark to Surface Gradient Overlay
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black45,
                                  Colors.transparent,
                                  bgSurface,
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar with Orbit Ring & Badge
                    Positioned(
                      bottom: -40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orbit Ring Animation
                          AnimatedBuilder(
                            animation: _orbitController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _orbitController.value * 2 * math.pi,
                                child: Container(
                                  width: 124,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 3,
                                    ),
                                    gradient: const SweepGradient(
                                      colors: [
                                        Color(0xFF004AC6),
                                        Color(0xFF40C2FD),
                                        Colors.transparent,
                                        Color(0xFF004AC6),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Inner White Avatar Container
                          Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: bgSurface,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person,
                                      size: 56,
                                      color: primaryBlue,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Pro Badge
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: bgSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF40C2FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 52),

                // Profile Name & Membership Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(fontSize: 13, color: textSlate),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Explorer Level 4",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textSlate,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC3C6D7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            "Member '21",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Airy Traveler Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAiryStatItem(
                          value: "14",
                          label: "TRIPS",
                          valueColor: primaryBlue,
                        ),
                        Container(height: 36, width: 1, color: surfaceVariant),
                        _buildAiryStatItem(
                          value: "8",
                          label: "COUNTRIES",
                          valueColor: textNavy,
                        ),
                        Container(height: 36, width: 1, color: surfaceVariant),
                        _buildAiryStatItem(
                          value: "24k",
                          label: "MILES",
                          valueColor: textNavy,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Journey Highlights Section (Timeline Polaroid Style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Journey Highlights",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Timeline List Container
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: Stack(
                          children: [
                            // Timeline Line
                            Positioned(
                              left: 5,
                              top: 10,
                              bottom: 20,
                              child: Container(
                                width: 2,
                                color: const Color(0xFFDBE1FF),
                              ),
                            ),

                            Column(
                              children: [
                                // Milestone 1: First Solo Trip
                                _buildTimelineMilestone(
                                  dotColor: primaryBlue,
                                  child: _buildMilestoneCard(
                                    title: "First Solo Trip",
                                    subtitle: "Patagonia, Argentina • Oct 2022",
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop',
                                    fallbackIcon: Icons.landscape_rounded,
                                    rotateAngle: 0.02,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Milestone 2: Eco Traveler Certified
                                _buildTimelineMilestone(
                                  dotColor: naturalGreen,
                                  child: _buildMilestoneCard(
                                    title: "Eco Traveler Certified",
                                    subtitle: "Offset 10,000 miles • Mar 2023",
                                    customContent: Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE7E7F3),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.eco_rounded,
                                          size: 48,
                                          color: naturalGreen,
                                        ),
                                      ),
                                    ),
                                    rotateAngle: -0.02,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Milestone 3: Peak Bagger
                                _buildTimelineMilestone(
                                  dotColor: warmYellow,
                                  child: _buildMilestoneCard(
                                    title: "Peak Bagger",
                                    subtitle: "Mt. Fuji Summit • Aug 2023",
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1491557345352-5929e343eb89?q=80&w=600&auto=format&fit=crop',
                                    fallbackIcon: Icons.terrain_rounded,
                                    rotateAngle: 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Preferences Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Preferences",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: surfaceVariant.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            children: [
                              _buildPreferenceTile(
                                icon: Icons.person_outline_rounded,
                                title: "Personal Info",
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: surfaceVariant,
                              ),
                              _buildPreferenceTile(
                                icon: Icons.credit_card_outlined,
                                title: "Payment Methods",
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: surfaceVariant,
                              ),
                              _buildPreferenceTile(
                                icon: Icons.notifications_none_rounded,
                                title: "Notifications",
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (val) {
                                    setState(() {
                                      _notificationsEnabled = val;
                                    });
                                  },
                                  activeTrackColor: primaryBlue,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: surfaceVariant,
                              ),
                              _buildPreferenceTile(
                                icon: Icons.tune_rounded,
                                title: "App Settings",
                                trailing: Switch(
                                  value: _darkMode,
                                  onChanged: (val) {
                                    setState(() {
                                      _darkMode = val;
                                    });
                                  },
                                  activeTrackColor: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Sign Out Button
                Center(
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: textSlate,
                    ),
                    label: const Text(
                      "SIGN OUT",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: textSlate,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Spacing for floating nav
              ],
            ),
          ),

          // Transparent Floating App Bar (Tride Badge & Settings Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Glass Tride Logo Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/image/playstore.png',
                            height: 22,
                            width: 22,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.explore,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Tride",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
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
          selectedIndex: 4,
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

  Widget _buildAiryStatItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineMilestone({
    required Color dotColor,
    required Widget child,
  }) {
    return Stack(
      children: [
        // Bullet Dot
        Positioned(
          left: 0,
          top: 16,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFAF8FF), width: 2),
            ),
          ),
        ),

        // Content Card Padding
        Padding(padding: const EdgeInsets.only(left: 24), child: child),
      ],
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required String subtitle,
    String? imageUrl,
    IconData? fallbackIcon,
    Widget? customContent,
    double rotateAngle = 0.0,
  }) {
    const Color textNavy = Color(0xFF0F172A);
    const Color textSlate = Color(0xFF64748B);

    return Transform.rotate(
      angle: rotateAngle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE1E2ED).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customContent != null)
              customContent
            else if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFE7E7F3),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          fallbackIcon ?? Icons.photo_rounded,
                          size: 40,
                          color: const Color(0xFF004AC6),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: textSlate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    const Color textNavy = Color(0xFF0F172A);
    const Color iconColor = Color(0xFF737686);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textNavy,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFC3C6D7)),
    );
  }
}

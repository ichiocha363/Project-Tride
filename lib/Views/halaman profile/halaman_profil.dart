import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Models/user_model.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../../Widgets/preference_tile.dart';
import '../../Widgets/profile_stat_item.dart';
import '../../Widgets/milestone_card.dart';
import 'package:project_tride/utils/session_manager.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman_login.dart';
import 'halaman_personal_info.dart';
import 'halaman_saved_places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/user_model.dart' as db_user;

class HalamanProfil extends StatefulWidget {
  final UserModel? user;
  final bool isEmbeddedInShell;

  const HalamanProfil({
    super.key,
    this.user,
    this.isEmbeddedInShell = false,
  });

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  late AnimationController _orbitController;

  String? _profileName;
  String? _profileEmail;
  String? _profileAvatar;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = widget.user?.id ?? 1;
    final prefs = await SharedPreferences.getInstance();

    String name = prefs.getString('user_name_$userId') ??
        (widget.user?.nama ?? 'Zhilly Hilmansyah');
    String email = prefs.getString('user_email_$userId') ??
        (widget.user?.email ?? 'zhilly@example.com');
    String? avatar = prefs.getString('user_avatar_$userId');

    try {
      if (widget.user?.id != null) {
        final dbUser = await DbHelper.instance.getUserById(widget.user!.id!);
        if (dbUser != null) {
          name = prefs.getString('user_name_$userId') ?? dbUser.name;
          email = prefs.getString('user_email_$userId') ?? dbUser.email;
          avatar =
              prefs.getString('user_avatar_$userId') ?? dbUser.profileImage;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _profileName = name;
        _profileEmail = email;
        _profileAvatar = avatar;
      });
    }
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
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              "Konfirmasi Logout",
              style: TextStyle(
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
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop();
              await SessionManager.clearSession();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HalamanLogin()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
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
    final userName = _profileName ?? widget.user?.nama ?? 'Zhilly Hilmansyah';
    final userEmail = _profileEmail ?? widget.user?.email ?? 'zhilly@example.com';
    final userAvatar = _profileAvatar ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop';

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
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
                                      AppColors.primaryDeep,
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
                                  AppColors.background,
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
                                        AppColors.primaryDeep,
                                        Color(0xFF40C2FD),
                                        Colors.transparent,
                                        AppColors.primaryDeep,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Inner Avatar using GFAvatar with fallback
                          GFAvatar(
                            radius: 54,
                            shape: GFAvatarShape.circle,
                            child: ClipOval(
                              child: Image.network(
                                userAvatar,
                                width: 108,
                                height: 108,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/image/playstore.png',
                                      width: 108,
                                      height: 108,
                                      fit: BoxFit.cover,
                                    ),
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
                                color: AppColors.background,
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
                                  color: AppColors.textWhite,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
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
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            "Member '21",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
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
                        const ProfileStatItem(
                          value: "14",
                          label: "PERJALANAN",
                          valueColor: AppColors.primaryDeep,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.surfaceVariant,
                        ),
                        const ProfileStatItem(
                          value: "8",
                          label: "NEGARA",
                          valueColor: AppColors.textPrimary,
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
                        "Sorotan Perjalanan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
                                color: AppColors.primaryFixed,
                              ),
                            ),

                            Column(
                              children: [
                                // Milestone 1: First Solo Trip
                                const MilestoneCard(
                                  dotColor: AppColors.primaryDeep,
                                  title: "First Solo Trip",
                                  subtitle: "Patagonia, Argentina • Oct 2022",
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop',
                                  fallbackIcon: Icons.landscape_rounded,
                                  rotateAngle: 0.02,
                                ),
                                const SizedBox(height: 20),

                                // Milestone 2: Eco Traveler Certified
                                MilestoneCard(
                                  dotColor: AppColors.mountain,
                                  title: "Eco Traveler Certified",
                                  subtitle: "Offset 10,000 miles • Mar 2023",
                                  customContent: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.eco_rounded,
                                        size: 48,
                                        color: AppColors.mountain,
                                      ),
                                    ),
                                  ),
                                  rotateAngle: -0.02,
                                ),
                                const SizedBox(height: 20),

                                // Milestone 3: Peak Bagger
                                const MilestoneCard(
                                  dotColor: AppColors.warning,
                                  title: "Peak Bagger",
                                  subtitle: "Mt. Fuji Summit • Aug 2023",
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1491557345352-5929e343eb89?q=80&w=600&auto=format&fit=crop',
                                  fallbackIcon: Icons.terrain_rounded,
                                  rotateAngle: 0.03,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
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
                              PreferenceTile(
                                icon: Icons.person_outline_rounded,
                                title: "Informasi Pribadi",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HalamanPersonalInfo(
                                        user: widget.user != null
                                            ? db_user.UserModel(
                                                id: widget.user!.id,
                                                nama: widget.user!.nama,
                                                email: widget.user!.email,
                                                password: widget.user!.password,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ).then((_) => _loadUserData());
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),
                              PreferenceTile(
                                icon: Icons.favorite_border_rounded,
                                title: "Tempat Tersimpan",
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDeep.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Terfavorit",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDeep,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HalamanSavedPlaces(user: widget.user),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),
                              PreferenceTile(
                                icon: Icons.credit_card_outlined,
                                title: "Metode Pembayaran",
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),
                              PreferenceTile(
                                icon: Icons.notifications_none_rounded,
                                title: "Notifikasi",
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (val) {
                                    setState(() {
                                      _notificationsEnabled = val;
                                    });
                                  },
                                  activeTrackColor: AppColors.primaryDeep,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),
                              PreferenceTile(
                                icon: Icons.tune_rounded,
                                title: "Pengaturan Aplikasi",
                                trailing: Switch(
                                  value: _darkMode,
                                  onChanged: (val) {
                                    setState(() {
                                      _darkMode = val;
                                    });
                                  },
                                  activeTrackColor: AppColors.primaryDeep,
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
                      color: AppColors.textSecondary,
                    ),
                    label: const Text(
                      "SIGN OUT",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 120), // Spacing for floating nav
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
                                  color: AppColors.textWhite,
                                  size: 20,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Tride",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
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
                          color: AppColors.textWhite,
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

      // Integrated Floating Bottom Navigation Bar
      bottomNavigationBar: widget.isEmbeddedInShell
          ? null
          : CustomFloatingNavBar(
              selectedIndex: 4,
              onDestinationSelected: _onNavTapped,
            ),
    );
  }
}

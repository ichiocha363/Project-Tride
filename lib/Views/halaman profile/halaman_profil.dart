import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Database/user_model.dart' as db_user;
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Models/user_profile_model.dart';
import 'package:project_tride/Services/auth_service.dart';
import 'package:project_tride/Services/profile_service.dart';
import 'package:project_tride/Services/saved_places_service.dart';
import 'package:project_tride/Services/trip_service.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../../Widgets/preference_tile.dart';
import '../../Widgets/profile_stat_item.dart';
import '../halaman beranda/halaman_trip_detail.dart';
import '../halaman_login.dart';
import '../halaman_utama.dart';
import 'halaman_pengaturan.dart';
import 'halaman_personal_info.dart';
import 'halaman_personal_travel_data.dart';
import 'halaman_saved_places.dart';

class HalamanProfil extends StatefulWidget {
  final UserModel? user;
  final bool isEmbeddedInShell;
  final ValueChanged<int>? onSwitchTab;

  const HalamanProfil({
    super.key,
    this.user,
    this.isEmbeddedInShell = false,
    this.onSwitchTab,
  });

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;
  final ImagePicker _imagePicker = ImagePicker();

  UserProfileModel? _profile;
  List<TripModel> _userTrips = [];
  int _tripsCount = 0;
  int _savedPlacesCount = 0;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadProfileAndStats();
  }

  Future<void> _loadProfileAndStats() async {
    try {
      if (mounted) {
        setState(() {
          _userTrips = [];
        });
      }
      final profile = await ProfileService.instance.getUserProfile();
      final trips = await TripService.instance.getTrips();
      final savedCount = await SavedPlacesService.instance.getSavedPlaces();

      if (mounted) {
        setState(() {
          _profile = profile;
          _userTrips = trips;
          _tripsCount = trips.length;
          _savedPlacesCount = savedCount.length;
        });
      }
    } catch (_) {
      // Graceful fallback to initial state
    }
  }

  Future<bool> _showImagePreviewDialog(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Pratinjau Foto Profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryDeep, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.file(
                    file,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apakah Anda yakin ingin menggunakan foto ini sebagai foto profil?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Gunakan Foto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return; // User cancelled gallery picker

      final file = File(picked.path);
      if (!await file.exists()) {
        if (mounted) {
          GFToast.showToast(
            'File gambar tidak valid',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            toastDuration: 2,
          );
        }
        return;
      }

      // Show Preview Dialog before uploading
      final confirm = await _showImagePreviewDialog(file);
      if (!confirm) return; // User cancelled in preview

      if (!ProfileService.instance.isAuthenticated) {
        if (mounted) {
          GFToast.showToast(
            'Silakan login terlebih dahulu',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            toastDuration: 2,
          );
        }
        return;
      }

      setState(() => _isUploadingImage = true);

      final downloadUrl = await ProfileService.instance.uploadProfileImage(file);

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          if (downloadUrl != null && _profile != null) {
            _profile = _profile!.copyWith(profileImage: downloadUrl);
          }
        });

        if (downloadUrl != null) {
          GFToast.showToast(
            'Foto profil berhasil diperbarui',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            toastDuration: 2,
          );
        } else {
          GFToast.showToast(
            'Gagal memperbarui foto profil',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            toastDuration: 2,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        GFToast.showToast(
          'Gagal memperbarui foto profil',
          context,
          toastPosition: GFToastPosition.BOTTOM,
        );
      }
    }
  }

  Widget _buildAvatarImage(String? avatarPath, double size) {
    if (avatarPath == null || avatarPath.trim().isEmpty) {
      return Image.asset(
        'assets/image/playstore.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return Image.network(
        avatarPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/image/playstore.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    try {
      final file = File(avatarPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/image/playstore.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      }
    } catch (_) {}

    return Image.asset(
      'assets/image/playstore.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
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
              style: TextStyle(fontWeight: FontWeight.bold),
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
              await AuthService.instance.signOut();
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

    if (widget.onSwitchTab != null) {
      widget.onSwitchTab!(index);
      return;
    }

    if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HalamanUtama(user: widget.user, initialTab: 0),
          ),
        );
      }
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HalamanUtama(user: widget.user, initialTab: index),
      ),
      (route) => false,
    );
  }

  User? _getSafeAuthUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  String _getMembershipSubtitle() {
    final creationTime = _getSafeAuthUser()?.metadata.creationTime;
    if (creationTime != null) {
      return "Member sejak ${creationTime.year}";
    }
    if (_profile != null && _profile!.createdAt.isNotEmpty) {
      try {
        final parsed = DateTime.parse(_profile!.createdAt);
        return "Member sejak ${parsed.year}";
      } catch (_) {}
    }
    return "Member Tride";
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthUser = _getSafeAuthUser();
    final userEmail = currentAuthUser?.email ?? _profile?.email ?? widget.user?.email ?? '';
    final userName = _profile?.name ?? widget.user?.nama ?? currentAuthUser?.displayName ?? (userEmail.isNotEmpty ? userEmail.split('@').first : 'Pengguna Tride');
    final userAvatar = _profile?.profileImage ?? widget.user?.profileImage ?? currentAuthUser?.photoURL;
    final membershipSubtitle = _getMembershipSubtitle();

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

                    // Avatar with Orbit Ring & Edit Button
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
                              child: _isUploadingImage
                                  ? Container(
                                      color: AppColors.surfaceVariant,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primaryDeep,
                                        ),
                                      ),
                                    )
                                  : _buildAvatarImage(userAvatar, 108),
                            ),
                          ),

                          // Edit Photo Badge
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : _pickAndUploadAvatar,
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
                                    Icons.camera_alt_rounded,
                                    color: AppColors.textWhite,
                                    size: 16,
                                  ),
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

                // Profile Name & Real Membership Subtitle
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
                      Text(
                        membershipSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Airy Traveler Stats Row (Real Trips Count & Real Saved Places Count)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfileStatItem(
                          value: "$_tripsCount",
                          label: "PERJALANAN",
                          valueColor: AppColors.primaryDeep,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.surfaceVariant,
                        ),
                        ProfileStatItem(
                          value: "$_savedPlacesCount",
                          label: "TEMPAT TERSIMPAN",
                          valueColor: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Dynamic Journey Highlights Section (Real Trip Highlight or Empty State)
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
                      _buildJourneyHighlightsSection(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Preferences Section (Clean & Real Actions)
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
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.6,
                            ),
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // 1. Informasi Pribadi
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
                                  ).then((_) => _loadProfileAndStats());
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),

                              // 2. Tempat Tersimpan
                              PreferenceTile(
                                icon: Icons.favorite_border_rounded,
                                title: "Tempat Tersimpan",
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDeep.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$_savedPlacesCount Tersimpan",
                                    style: const TextStyle(
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
                                  ).then((_) => _loadProfileAndStats());
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 56,
                                endIndent: 16,
                                color: AppColors.surfaceVariant,
                              ),

                              // 3. Personal Travel Data
                              PreferenceTile(
                                icon: Icons.flight_takeoff_rounded,
                                title: "Personal Travel Data",
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.nature.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Preferensi",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.nature,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HalamanPersonalTravelData(),
                                    ),
                                  ).then((_) => _loadProfileAndStats());
                                },
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

                    // Settings Button (Opens HalamanPengaturan)
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HalamanPengaturan(),
                            ),
                          ).then((_) => _loadProfileAndStats());
                        },
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

  Widget _buildJourneyHighlightsSection() {
    if (_userTrips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDeep.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flight_takeoff_rounded,
                size: 36,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Belum Ada Perjalanan",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Mulai buat rencana liburan impianmu bersama asisten cerdas Tride.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onSwitchTab != null) {
                  widget.onSwitchTab!(2); // Switch to AI Planner tab
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Buat Trip Baru"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Display recent trips dynamically
    final latestTrips = _userTrips.take(3).toList();

    return Column(
      children: latestTrips.map((trip) {
        final destination = trip.destinationName ?? trip.destinationLocation ?? 'Destinasi Wisata';
        final dates = "${trip.startDate} - ${trip.endDate}";
        final imageUrl = trip.imageUrl;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanTripDetail(
                    user: widget.user,
                    trip: trip,
                    title: trip.tripName,
                    dateRange: "${trip.startDate} - ${trip.endDate}",
                    imageUrl: trip.imageUrl ?? '',
                  ),
                ),
              ).then((_) => _loadProfileAndStats());
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: AppColors.surfaceVariant,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.landscape_rounded, color: AppColors.primaryDeep),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.landscape_rounded, color: AppColors.primaryDeep),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.tripName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primaryDeep),
                            const SizedBox(width: 4),
                            Text(
                              dates,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

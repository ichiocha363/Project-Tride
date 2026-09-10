import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Services/auth_service.dart';
import 'package:project_tride/Services/profile_service.dart';
import 'package:project_tride/Views/halaman_privacy_policy.dart';
import 'package:project_tride/Views/halaman_terms_of_service.dart';
import '../halaman_login.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedCurrency = 'IDR';
  bool _isLoading = true;

  final List<String> _languages = [
    'Bahasa Indonesia',
    'English',
    'Japanese',
    'Mandarin',
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'IDR', 'label': 'IDR — Indonesian Rupiah'},
    {'code': 'USD', 'label': 'USD — US Dollar'},
    {'code': 'EUR', 'label': 'EUR — Euro'},
    {'code': 'SGD', 'label': 'SGD — Singapore Dollar'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final profile = await ProfileService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _selectedLanguage = profile.language.isNotEmpty ? profile.language : 'Bahasa Indonesia';
          _selectedCurrency = profile.currency.isNotEmpty ? profile.currency : 'IDR';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Bahasa Aplikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._languages.map((lang) {
                final isSelected = lang == _selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryDeep : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDeep)
                      : null,
                  onTap: () async {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                    await ProfileService.instance.updateTravelPreferences(language: lang);
                    if (mounted) {
                      GFToast.showToast(
                        'Bahasa berhasil diubah ke $lang',
                        this.context,
                        toastPosition: GFToastPosition.BOTTOM,
                        toastDuration: 2,
                      );
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Mata Uang Default',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._currencies.map((curr) {
                final code = curr['code']!;
                final label = curr['label']!;
                final isSelected = code == _selectedCurrency;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryDeep : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDeep)
                      : null,
                  onTap: () async {
                    setState(() => _selectedCurrency = code);
                    Navigator.pop(context);
                    await ProfileService.instance.updateTravelPreferences(currency: code);
                    if (mounted) {
                      GFToast.showToast(
                        'Mata uang berhasil diubah ke $code',
                        this.context,
                        toastPosition: GFToastPosition.BOTTOM,
                        toastDuration: 2,
                      );
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: AppColors.primaryDeep),
            SizedBox(width: 10),
            Text(
              "Notifikasi Push",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Fitur notifikasi real-time via Cloud Messaging sedang dalam tahap pengembangan dan akan hadir pada pembaruan TRIDE berikutnya.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDeep,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Mengerti"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset(
              'assets/image/playstore.png',
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.explore, color: AppColors.primaryDeep),
            ),
            const SizedBox(width: 10),
            const Text(
              "Tentang Tride",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TRIDE — Travel Assistant Indonesia",
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              "Versi 1.0.0 (Build 2)",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              "Aplikasi asisten perjalanan pintar untuk merencanakan liburan, budgeting, eksplorasi destinasi Indonesia, dan rekomendasi cuaca real-time.",
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Ketentuan & Privasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dengan menggunakan aplikasi TRIDE, data profil dan rencana perjalanan Anda disimpan dengan aman di Cloud Firestore secara terisolasi per akun user. Kami menghormati privasi Anda dan tidak membagikan data personal ke pihak ketiga.",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_rounded, color: AppColors.primaryDeep),
                title: const Text(
                  "Syarat & Ketentuan Layanan",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HalamanTermsOfService()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.security_rounded, color: AppColors.primaryDeep),
                title: const Text(
                  "Kebijakan Privasi",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HalamanPrivacyPolicy()),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDeep,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDeep),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PENGATURAN UMUM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                        // Language
                        _buildSettingTile(
                          icon: Icons.language_rounded,
                          title: 'Bahasa',
                          subtitle: _selectedLanguage,
                          onTap: _showLanguagePicker,
                          showDivider: true,
                        ),
                        // Currency
                        _buildSettingTile(
                          icon: Icons.monetization_on_outlined,
                          title: 'Mata Uang Default',
                          subtitle: _selectedCurrency,
                          onTap: _showCurrencyPicker,
                          showDivider: true,
                        ),
                        // Notifications (Coming Soon)
                        _buildSettingTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Pemberitahuan trip & cuaca',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDeep.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Segera Hadir',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ),
                          onTap: _showNotificationInfoDialog,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),

                  const SizedBox(height: 28),

                  const Text(
                    'TENTANG & BANTUAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                        _buildSettingTile(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Tride',
                          subtitle: 'Versi 1.0.0',
                          onTap: _showAboutDialog,
                          showDivider: true,
                        ),
                        _buildSettingTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Ketentuan Layanan & Privasi',
                          subtitle: 'Informasi keamanan data',
                          onTap: _showTermsDialog,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),

                  const SizedBox(height: 32),

                  // Sign out button
                  Center(
                    child: TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        "LOGOUT DARI AKUN",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(icon, color: AppColors.primaryDeep, size: 24),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )
                : null,
            trailing: trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                ),
            onTap: onTap,
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 56,
              endIndent: 16,
              color: AppColors.surfaceVariant,
            ),
        ],
      ),
    );
  }
}

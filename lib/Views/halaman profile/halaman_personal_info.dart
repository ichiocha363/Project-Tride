import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/user_model.dart' as db_user;
import 'package:project_tride/Models/user_profile_model.dart';
import 'package:project_tride/Services/profile_service.dart';
import 'halaman_personal_travel_data.dart';

class HalamanPersonalInfo extends StatefulWidget {
  final db_user.UserModel? user;

  const HalamanPersonalInfo({super.key, this.user});

  @override
  State<HalamanPersonalInfo> createState() => _HalamanPersonalInfoState();
}

class _HalamanPersonalInfoState extends State<HalamanPersonalInfo> {
  UserProfileModel? _profile;
  bool _isLoading = true;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  Future<void> _pickAndUploadImage() {
    return _handlePickImage();
  }

  Future<void> _handlePickImage() async {
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

  void _showEditNameDialog() {
    final currentName = _profile?.name ?? '';
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Ubah Nama Lengkap',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Masukkan nama lengkap',
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryDeep, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                Navigator.pop(context);
                setState(() {
                  if (_profile != null) {
                    _profile = _profile!.copyWith(name: newName);
                  }
                });

                final success = await ProfileService.instance.updatePersonalDetails(
                  name: newName,
                  phone: _profile?.phone,
                );

                if (mounted) {
                  if (success) {
                    GFToast.showToast(
                      'Nama berhasil diperbarui',
                      this.context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 2,
                    );
                  } else {
                    GFToast.showToast(
                      'Gagal memperbarui nama di cloud',
                      this.context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 2,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhoneDialog() {
    final currentPhone = _profile?.phone ?? '';
    final controller = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Ubah Nomor Telepon',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: +62 812 3456 7890',
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryDeep, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPhone = controller.text.trim();
                Navigator.pop(context);

                setState(() {
                  if (_profile != null) {
                    _profile = _profile!.copyWith(phone: newPhone.isNotEmpty ? newPhone : null);
                  }
                });

                final success = await ProfileService.instance.updatePersonalDetails(
                  name: _profile?.name ?? 'Pengguna Tride',
                  phone: newPhone,
                );

                if (mounted) {
                  if (success) {
                    GFToast.showToast(
                      'Nomor telepon berhasil disimpan',
                      this.context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 2,
                    );
                  } else {
                    GFToast.showToast(
                      'Gagal menyimpan nomor telepon',
                      this.context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 2,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  String _getSafeAuthEmail() {
    try {
      return FirebaseAuth.instance.currentUser?.email ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authEmail = _getSafeAuthEmail();
    final email = authEmail.isNotEmpty ? authEmail : (_profile?.email ?? widget.user?.email ?? '');
    final name = _profile?.name ?? widget.user?.nama ?? (email.isNotEmpty ? email.split('@').first : 'Pengguna Tride');
    final avatar = _profile?.profileImage ?? widget.user?.profileImage;
    final phone = _profile?.phone;
    final favDest = _profile?.favoriteDestinationName ?? 'Belum ditentukan';
    final lang = _profile?.language ?? 'Bahasa Indonesia';
    final curr = _profile?.currency ?? 'IDR';

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
          'Informasi Pribadi',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Avatar & Edit Photo
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
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
                                  : _buildAvatarImage(avatar, 108),
                            ),
                          ),
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDeep,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.textWhite,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact Information Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'INFORMASI KONTAK & AKUN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Name Row (Editable)
                        _buildInfoTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Nama Lengkap',
                          value: name,
                          isEditable: true,
                          onTap: _showEditNameDialog,
                          showDivider: true,
                        ),
                        // Email Row (Read-Only)
                        _buildInfoTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email Akun (Firebase Auth)',
                          value: email.isNotEmpty ? email : 'Tidak terhubung',
                          isEditable: false,
                          helperText: 'Email dikelola secara aman oleh Firebase Authentication.',
                          showDivider: true,
                        ),
                        // Phone Row (Editable)
                        _buildInfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Nomor Telepon',
                          value: (phone != null && phone.isNotEmpty) ? phone : 'Belum diatur',
                          isEditable: true,
                          onTap: _showEditPhoneDialog,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Preferences Section Shortcut
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PREFERENSI PERJALANAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.public_rounded,
                          label: 'Destinasi Favorit',
                          value: favDest,
                          isEditable: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HalamanPersonalTravelData(),
                              ),
                            ).then((_) => _loadProfileData());
                          },
                          showDivider: true,
                        ),
                        _buildInfoTile(
                          icon: Icons.translate_rounded,
                          label: 'Bahasa & Mata Uang',
                          value: '$lang • $curr',
                          isEditable: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HalamanPersonalTravelData(),
                              ),
                            ).then((_) => _loadProfileData());
                          },
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    String? helperText,
    VoidCallback? onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: isEditable ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDeep.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primaryDeep, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (helperText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          helperText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEditable)
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textLight,
                  )
                else
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 70,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
      ],
    );
  }
}

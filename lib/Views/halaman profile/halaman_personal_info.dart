import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/db_helper.dart';
import 'package:project_tride/Database/user_model.dart';

class HalamanPersonalInfo extends StatefulWidget {
  final UserModel? user;

  const HalamanPersonalInfo({super.key, this.user});

  @override
  State<HalamanPersonalInfo> createState() => _HalamanPersonalInfoState();
}

class _HalamanPersonalInfoState extends State<HalamanPersonalInfo> {
  // Color Tokens mapped to AppColors
  static const Color bgCloud = AppColors.background;
  static const Color primaryBlue = AppColors.primary;
  static const Color textNavy = AppColors.textPrimary;
  static const Color textSlate = AppColors.textSecondary;
  static const Color surfaceCard = AppColors.surface;
  static const Color outlineVariant = AppColors.surfaceVariant;
  static const Color sunsetOrange = AppColors.sunsetOrange;
  static const Color naturalGreen = AppColors.nature;
  static const Color warmYellow = AppColors.warning;

  // Profile Information State
  late String _displayName;
  late String _username;
  late String _bio;
  late String _email;
  late String _phone;
  late String _location;
  late String _avatarUrl;

  // Personal Travel Data State
  late String _favoriteDestination;
  late String _language;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    _displayName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : 'Zhilly Hilmansyah';
    _username = '@${_displayName.toLowerCase().replaceAll(' ', '')}';
    if (_username == '@zhillyhilmansyah') _username = '@zhilly';

    _bio = 'Exploring new places, one journey at a time.';
    _email = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : 'zhilly@example.com';
    _phone = '+62 812 3456 7890';
    _location = 'Jakarta, Indonesia';
    _avatarUrl = (user?.profileImage != null && user!.profileImage!.isNotEmpty)
        ? user.profileImage!
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop';

    _favoriteDestination = 'Bali, Indonesia';
    _language = 'Indonesian';
    _currency = 'IDR — Indonesian Rupiah';

    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final userId = widget.user?.id ?? 1;
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _displayName = prefs.getString('user_name_$userId') ?? _displayName;
        _username = prefs.getString('user_username_$userId') ?? _username;
        _bio = prefs.getString('user_bio_$userId') ?? _bio;
        _email = prefs.getString('user_email_$userId') ?? _email;
        _phone = prefs.getString('user_phone_$userId') ?? _phone;
        _location = prefs.getString('user_location_$userId') ?? _location;
        _avatarUrl = prefs.getString('user_avatar_$userId') ?? _avatarUrl;
        _favoriteDestination =
            prefs.getString('user_favorite_dest_$userId') ?? _favoriteDestination;
        _language = prefs.getString('user_language_$userId') ?? _language;
        _currency = prefs.getString('user_currency_$userId') ?? _currency;
      });
    }
  }

  Future<void> _saveProfileData() async {
    final userId = widget.user?.id ?? 1;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name_$userId', _displayName);
    await prefs.setString('user_username_$userId', _username);
    await prefs.setString('user_bio_$userId', _bio);
    await prefs.setString('user_email_$userId', _email);
    await prefs.setString('user_phone_$userId', _phone);
    await prefs.setString('user_location_$userId', _location);
    await prefs.setString('user_avatar_$userId', _avatarUrl);
    await prefs.setString('user_favorite_dest_$userId', _favoriteDestination);
    await prefs.setString('user_language_$userId', _language);
    await prefs.setString('user_currency_$userId', _currency);

    if (widget.user != null && widget.user!.id != null) {
      try {
        final existingUser =
            await DbHelper.instance.getUserById(widget.user!.id!);
        if (existingUser != null) {
          final updatedUser = existingUser.copyWith(
            name: _displayName,
            email: _email,
            profileImage: _avatarUrl,
          );
          await DbHelper.instance.updateUser(updatedUser);
        }
      } catch (_) {}
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _displayName);
    final usernameController = TextEditingController(text: _username);
    final bioController = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textNavy,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField('Full Name', nameController),
                const SizedBox(height: 14),
                _buildInputField('Username', usernameController),
                const SizedBox(height: 14),
                _buildInputField('Bio', bioController, maxLines: 2),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      setState(() {
                        _displayName = nameController.text.trim();
                        _username = usernameController.text.trim();
                        _bio = bioController.text.trim();
                      });
                      await _saveProfileData();
                      if (!mounted) return;
                      nav.pop();
                      GFToast.showToast(
                        'Profile updated successfully',
                        context,
                        toastPosition: GFToastPosition.BOTTOM,
                        toastDuration: 2,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSingleFieldEditDialog({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit $title',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: textNavy,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontFamily: 'Inter', color: textNavy),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: textSlate)),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  onSave(val);
                  await _saveProfileData();
                }
                if (!mounted) return;
                nav.pop();
                GFToast.showToast(
                  '$title updated successfully',
                  context,
                  toastPosition: GFToastPosition.BOTTOM,
                  toastDuration: 2,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showOptionSelectionBottomSheet({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select $title',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textNavy,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((option) {
                final isSelected = option == currentValue;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? primaryBlue : textNavy,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: primaryBlue,
                        )
                      : null,
                  onTap: () async {
                    final nav = Navigator.of(context);
                    onSelect(option);
                    await _saveProfileData();
                    if (!mounted) return;
                    nav.pop();
                    GFToast.showToast(
                      '$title updated successfully',
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 2,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSlate,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: textNavy,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: bgCloud,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCloud,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: bgCloud,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: textNavy,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Personal Info',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textNavy,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Profile Focal Section
                    _buildProfileFocalSection(),

                    const SizedBox(height: 28),

                    // Contact Section
                    _buildContactSection(),

                    const SizedBox(height: 24),

                    // Personal Travel Data Section
                    _buildPersonalTravelDataSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileFocalSection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Orbit Motif decoration & Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryBlue.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            GFAvatar(
              radius: 50,
              shape: GFAvatarShape.circle,
              child: ClipOval(
                child: Image.network(
                  _avatarUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/image/playstore.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Display Name
        Text(
          _displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
            color: textNavy,
          ),
        ),
        const SizedBox(height: 2),
        // Username
        Text(
          _username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSlate,
          ),
        ),
        const SizedBox(height: 6),
        // Bio
        Text(
          '"$_bio"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: textSlate,
          ),
        ),
        const SizedBox(height: 16),
        // Edit Profile Button
        InkWell(
          onTap: _showEditProfileDialog,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'CONTACT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: textNavy,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surfaceCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Email
              _buildRefinedInfoRow(
                icon: Icons.mail,
                badgeBg: primaryBlue.withValues(alpha: 0.1),
                badgeIconColor: primaryBlue,
                label: 'Email',
                value: _email,
                showDivider: true,
                onTap: () {
                  _showSingleFieldEditDialog(
                    title: 'Email',
                    currentValue: _email,
                    keyboardType: TextInputType.emailAddress,
                    onSave: (val) => setState(() => _email = val),
                  );
                },
              ),
              // Row 2: Phone
              _buildRefinedInfoRow(
                icon: Icons.phone,
                badgeBg: primaryBlue.withValues(alpha: 0.1),
                badgeIconColor: primaryBlue,
                label: 'Phone',
                value: _phone,
                showDivider: true,
                onTap: () {
                  _showSingleFieldEditDialog(
                    title: 'Phone',
                    currentValue: _phone,
                    keyboardType: TextInputType.phone,
                    onSave: (val) => setState(() => _phone = val),
                  );
                },
              ),
              // Row 3: Location
              _buildRefinedInfoRow(
                icon: Icons.location_on,
                badgeBg: primaryBlue.withValues(alpha: 0.1),
                badgeIconColor: primaryBlue,
                label: 'Location',
                value: _location,
                showDivider: false,
                onTap: () {
                  _showSingleFieldEditDialog(
                    title: 'Location',
                    currentValue: _location,
                    onSave: (val) => setState(() => _location = val),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalTravelDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'PERSONAL TRAVEL DATA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: textNavy,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: surfaceCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Favorite Destination
              _buildRefinedInfoRow(
                icon: Icons.public,
                badgeBg: sunsetOrange.withValues(alpha: 0.1),
                badgeIconColor: sunsetOrange,
                label: 'Favorite Destination',
                value: _favoriteDestination,
                showDivider: true,
                onTap: () {
                  _showSingleFieldEditDialog(
                    title: 'Favorite Destination',
                    currentValue: _favoriteDestination,
                    onSave: (val) => setState(() => _favoriteDestination = val),
                  );
                },
              ),
              // Row 2: Language
              _buildRefinedInfoRow(
                icon: Icons.translate,
                badgeBg: naturalGreen.withValues(alpha: 0.1),
                badgeIconColor: naturalGreen,
                label: 'Language',
                value: _language,
                showDivider: true,
                onTap: () {
                  _showOptionSelectionBottomSheet(
                    title: 'Language',
                    currentValue: _language,
                    options: [
                      'Indonesian',
                      'English',
                      'Japanese',
                      'Mandarin',
                      'Spanish',
                    ],
                    onSelect: (val) => setState(() => _language = val),
                  );
                },
              ),
              // Row 3: Currency
              _buildRefinedInfoRow(
                icon: Icons.account_balance_wallet,
                badgeBg: warmYellow.withValues(alpha: 0.15),
                badgeIconColor: const Color(0xFFD97706),
                label: 'Currency',
                value: _currency,
                showDivider: false,
                onTap: () {
                  _showOptionSelectionBottomSheet(
                    title: 'Currency',
                    currentValue: _currency,
                    options: [
                      'IDR — Indonesian Rupiah',
                      'USD — US Dollar',
                      'EUR — Euro',
                      'JPY — Japanese Yen',
                      'SGD — Singapore Dollar',
                    ],
                    onSelect: (val) => setState(() => _currency = val),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefinedInfoRow({
    required IconData icon,
    required Color badgeBg,
    required Color badgeIconColor,
    required String label,
    required String value,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Circular icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeBg,
                  ),
                  child: Icon(icon, size: 20, color: badgeIconColor),
                ),
                const SizedBox(width: 16),
                // Label and Value column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textSlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20, color: textSlate),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 72),
            color: const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

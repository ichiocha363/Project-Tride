import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import 'package:project_tride/Services/profile_service.dart';

class HalamanPersonalTravelData extends StatefulWidget {
  const HalamanPersonalTravelData({super.key});

  @override
  State<HalamanPersonalTravelData> createState() => _HalamanPersonalTravelDataState();
}

class _HalamanPersonalTravelDataState extends State<HalamanPersonalTravelData> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<DestinationModel> _destinations = [];

  dynamic _selectedDestinationId;
  String? _selectedDestinationName;
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedCurrency = 'IDR';

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService.instance.getUserProfile();
      final dests = await DestinationService.instance.getDestinations();

      if (mounted) {
        setState(() {
          _destinations = dests;
          _selectedDestinationId = profile.favoriteDestinationId;
          _selectedDestinationName = profile.favoriteDestinationName;
          _selectedLanguage = profile.language.isNotEmpty ? profile.language : 'Bahasa Indonesia';
          _selectedCurrency = profile.currency.isNotEmpty ? profile.currency : 'IDR';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final success = await ProfileService.instance.updateTravelPreferences(
      destinationId: _selectedDestinationId,
      destinationName: _selectedDestinationName,
      language: _selectedLanguage,
      currency: _selectedCurrency,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        GFToast.showToast(
          'Preferensi perjalanan berhasil disimpan',
          context,
          toastPosition: GFToastPosition.BOTTOM,
          toastDuration: 2,
        );
      } else {
        GFToast.showToast(
          'Gagal menyimpan preferensi. Periksa koneksi internet.',
          context,
          toastPosition: GFToastPosition.BOTTOM,
          toastDuration: 2,
        );
      }
    }
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Destinasi Favorit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.surfaceVariant),
                Expanded(
                  child: _destinations.isEmpty
                      ? const Center(
                          child: Text(
                            'Katalog destinasi sedang dimuat...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: _destinations.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceVariant),
                          itemBuilder: (context, index) {
                            final dest = _destinations[index];
                            final isSelected = dest.id == _selectedDestinationId ||
                                dest.name == _selectedDestinationName;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 6),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  dest.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.surfaceVariant,
                                    child: const Icon(Icons.landscape, color: AppColors.primaryDeep),
                                  ),
                                ),
                              ),
                              title: Text(
                                dest.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.primaryDeep : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                dest.location,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDeep)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedDestinationId = dest.id;
                                  _selectedDestinationName = dest.name;
                                });
                                Navigator.pop(context);
                                _savePreferences();
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
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
                'Pilih Bahasa',
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
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang;
                    });
                    Navigator.pop(context);
                    _savePreferences();
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
                'Pilih Mata Uang (Currency)',
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
                  onTap: () {
                    setState(() {
                      _selectedCurrency = code;
                    });
                    Navigator.pop(context);
                    _savePreferences();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyDisplay = _currencies.firstWhere(
      (c) => c['code'] == _selectedCurrency,
      orElse: () => {'code': _selectedCurrency, 'label': _selectedCurrency},
    )['label']!;

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
          'Personal Travel Data',
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
                    'PREFERENSI PERJALANAN',
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
                        // 1. Destinasi Favorit
                        _buildPreferenceItem(
                          icon: Icons.public_rounded,
                          iconBg: AppColors.sunsetOrange.withValues(alpha: 0.1),
                          iconColor: AppColors.sunsetOrange,
                          label: 'Destinasi Favorit',
                          value: _selectedDestinationName ?? 'Belum dipilih',
                          onTap: _showDestinationPicker,
                          showDivider: true,
                        ),
                        // 2. Bahasa
                        _buildPreferenceItem(
                          icon: Icons.translate_rounded,
                          iconBg: AppColors.nature.withValues(alpha: 0.1),
                          iconColor: AppColors.nature,
                          label: 'Bahasa (Language)',
                          value: _selectedLanguage,
                          onTap: _showLanguagePicker,
                          showDivider: true,
                        ),
                        // 3. Mata Uang
                        _buildPreferenceItem(
                          icon: Icons.account_balance_wallet_rounded,
                          iconBg: AppColors.warning.withValues(alpha: 0.15),
                          iconColor: const Color(0xFFD97706),
                          label: 'Mata Uang (Currency)',
                          value: currencyDisplay,
                          onTap: _showCurrencyPicker,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isSaving)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: AppColors.surfaceVariant,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_beranda.dart';
import 'package:project_tride/Views/halaman_jelajah.dart';
import 'package:project_tride/Views/halaman_login.dart';
import 'package:project_tride/Views/halaman_profil.dart';

class HalamanBudget extends StatefulWidget {
  final UserModel? user;

  const HalamanBudget({super.key, this.user});

  @override
  State<HalamanBudget> createState() => _HalamanBudgetState();
}

class _HalamanBudgetState extends State<HalamanBudget> {
  final double _totalBudget = 5000000;

  // Category expenses breakdown data
  final Map<String, Map<String, dynamic>> _categoryData = {
    'Transportasi': {
      'amount': 450000.0,
      'budget': 1000000.0,
      'icon': Icons.directions_car,
      'bgCircleColor': const Color(0xFF40C2FD),
      'iconColor': const Color(0xFF004D6A),
      'barColor': const Color(0xFF00668A),
    },
    'Akomodasi': {
      'amount': 600000.0,
      'budget': 1000000.0,
      'icon': Icons.hotel,
      'bgCircleColor': const Color(0xFFBC4800),
      'iconColor': const Color(0xFFFFEDE6),
      'barColor': const Color(0xFF943700),
    },
    'Makanan': {
      'amount': 250000.0,
      'budget': 1000000.0,
      'icon': Icons.restaurant,
      'bgCircleColor': const Color(0xFFF59E0B).withValues(alpha: 0.2),
      'iconColor': const Color(0xFFF59E0B),
      'barColor': const Color(0xFFF59E0B),
    },
    'Wisata': {
      'amount': 200000.0,
      'budget': 1000000.0,
      'icon': Icons.local_activity,
      'bgCircleColor': const Color(0xFF2563EB),
      'iconColor': const Color(0xFFEEEFFF),
      'barColor': const Color(0xFF004AC6),
    },
  };

  // Recent Expenses List
  late List<Map<String, dynamic>> _recentExpenses;

  @override
  void initState() {
    super.initState();
    _recentExpenses = [
      {
        'id': 1,
        'title': 'Makan Siang',
        'category': 'Makanan',
        'date': 'Hari ini, 13:00',
        'amount': 150000.0,
        'icon': Icons.restaurant,
        'iconBg': const Color(0xFFF59E0B).withValues(alpha: 0.1),
        'iconColor': const Color(0xFFF59E0B),
      },
      {
        'id': 2,
        'title': 'Tiket Pesawat',
        'category': 'Transportasi',
        'date': 'Kemarin, 09:45',
        'amount': 1200000.0,
        'icon': Icons.flight,
        'iconBg': const Color(0xFF00668A).withValues(alpha: 0.1),
        'iconColor': const Color(0xFF00668A),
      },
      {
        'id': 3,
        'title': 'DP Hotel',
        'category': 'Akomodasi',
        'date': '2 Hari lalu',
        'amount': 600000.0,
        'icon': Icons.hotel,
        'iconBg': const Color(0xFF943700).withValues(alpha: 0.1),
        'iconColor': const Color(0xFF943700),
      },
    ];
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HalamanLogin()),
      (route) => false,
    );
  }

  double get _totalSpent {
    double total = 0;
    _categoryData.forEach((key, value) {
      total += (value['amount'] as double);
    });
    return total;
  }

  double get _totalRemaining => _totalBudget - _totalSpent;

  double get _spentPercentage {
    if (_totalBudget == 0) return 0;
    return (_totalSpent / _totalBudget).clamp(0.0, 1.0);
  }

  String _formatRupiah(double number) {
    String numStr = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]}.';
    String result = numStr.replaceAllMapped(reg, mathFunc);
    return 'Rp $result';
  }

  String _formatRupiahShort(double number) {
    if (number >= 1000000) {
      double millions = number / 1000000;
      if (millions == millions.toInt()) {
        return 'Rp ${millions.toInt()}M';
      }
      return 'Rp ${millions.toStringAsFixed(1)}M';
    }
    return _formatRupiah(number);
  }

  void _showAddExpenseModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Transportasi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF737686)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pengeluaran',
                      hintText: 'Misal: Makan Siang, Taxi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      hintText: '50000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryData.keys.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (bool selected) {
                          if (selected) {
                            setModalState(() {
                              selectedCategory = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim()) ??
                            0.0;

                        if (title.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mohon isi nama dan jumlah valid!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          // Update category total
                          if (_categoryData.containsKey(selectedCategory)) {
                            _categoryData[selectedCategory]!['amount'] =
                                (_categoryData[selectedCategory]!['amount']
                                    as double) +
                                amount;
                          }

                          IconData icon = Icons.receipt;
                          Color iconBg = const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.1);
                          Color iconColor = const Color(0xFF2563EB);

                          if (_categoryData.containsKey(selectedCategory)) {
                            icon = _categoryData[selectedCategory]!['icon'];
                            iconColor =
                                _categoryData[selectedCategory]!['barColor'];
                            iconBg = iconColor.withValues(alpha: 0.1);
                          }

                          _recentExpenses.insert(0, {
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'title': title,
                            'category': selectedCategory,
                            'date': 'Baru saja',
                            'amount': amount,
                            'icon': icon,
                            'iconBg': iconBg,
                            'iconColor': iconColor,
                          });
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pengeluaran "$title" berhasil ditambahkan!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Pengeluaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color bgLight = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + App Title
                  Row(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/image/playstore.png',
                          height: 55,
                          width: 55,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tride',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  // Actions: Notification & Profile
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak ada notifikasi baru'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F3FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF434655),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            _logout();
                          }
                        },
                        offset: const Offset(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.user?.nama ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.user?.email ?? 'user@tride.com',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Keluar',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              widget.user?.nama.isNotEmpty == true
                                  ? widget.user!.nama[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Text Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Budget Trip',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola pengeluaran perjalanan Anda',
                    style: TextStyle(fontSize: 14, color: Color(0xFF434655)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDF9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    // Decorative circle glow background
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Budget Header & Remaining Tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Budget',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF434655),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRupiah(_totalBudget),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191B23),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatRupiahShort(_totalRemaining)} Sisa',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Progress Bar Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pengeluaran: ${_formatRupiah(_totalSpent)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF434655),
                              ),
                            ),
                            Text(
                              '${(_spentPercentage * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF434655),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                color: const Color(0xFFE1E2ED),
                              ),
                              FractionallySizedBox(
                                widthFactor: _spentPercentage,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF22C55E,
                                        ).withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Terpakai & Tersedia Grid
                        Row(
                          children: [
                            // Terpakai Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFDAD6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_downward,
                                        size: 18,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Terpakai',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF434655),
                                          ),
                                        ),
                                        Text(
                                          _formatRupiahShort(_totalSpent),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF191B23),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tersedia Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF22C55E,
                                        ).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_balance,
                                        size: 18,
                                        color: Color(0xFF22C55E),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tersedia',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF434655),
                                          ),
                                        ),
                                        Text(
                                          _formatRupiahShort(_totalRemaining),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF191B23),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Kategori Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191B23),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Grid 2x2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: _categoryData.entries.map((entry) {
                  final title = entry.key;
                  final data = entry.value;
                  final amount = data['amount'] as double;
                  final budget = data['budget'] as double;
                  final IconData icon = data['icon'] as IconData;
                  final Color bgCircle = data['bgCircleColor'] as Color;
                  final Color iconColor = data['iconColor'] as Color;
                  final Color barColor = data['barColor'] as Color;

                  final double catProgress = budget > 0
                      ? (amount / budget).clamp(0.0, 1.0)
                      : 0.0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: bgCircle,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF191B23),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatRupiah(amount),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF434655),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    width: double.infinity,
                                    color: const Color(0xFFE1E2ED),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: catProgress,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Pengeluaran Terakhir Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengeluaran Terakhir',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191B23),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menampilkan semua pengeluaran'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recent Expenses List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentExpenses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _recentExpenses[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: item['iconBg'] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191B23),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['date'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF434655),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '-${_formatRupiah(item['amount'] as double)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191B23),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 100), // Spacing for FAB and bottom navbar
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: _showAddExpenseModal,
          backgroundColor: primaryBlue,
          shape: const CircleBorder(),
          elevation: 6,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          AnimatedBottomNavigationBar.builder(
            itemCount: 4,
            tabBuilder: (int index, bool isActive) {
              final icons = [
                Icons.home_outlined,
                Icons.explore_outlined,
                Icons.account_balance_wallet,
                Icons.person_outline_rounded,
              ];
              final labels = ['Beranda', 'Jelajah', 'Budget', 'Profil'];
              final color = isActive ? primaryBlue : const Color(0xFF434655);

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[index], size: 24, color: color),
                  const SizedBox(height: 2),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              );
            },
            activeIndex: 2, // Budget page active index is 2
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 0,
            rightCornerRadius: 0,
            backgroundColor: Colors.white,
            shadow: BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanBeranda(user: widget.user),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanJelajah(user: widget.user),
                  ),
                );
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanProfil(user: widget.user),
                  ),
                );
              }
            },
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("AI Travel Planner dibuka!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Planner',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

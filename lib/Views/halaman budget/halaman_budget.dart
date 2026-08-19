import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';

class HalamanBudget extends StatefulWidget {
  final UserModel? user;

  const HalamanBudget({super.key, this.user});

  @override
  State<HalamanBudget> createState() => _HalamanBudgetState();
}

class _HalamanBudgetState extends State<HalamanBudget> {
  final double _totalBudget = 2000.0;

  final Map<String, Map<String, dynamic>> _categoryData = {
    'Lodging': {
      'subtitle': '4 nights at Ryokan',
      'icon': Icons.bed_rounded,
      'color': const Color(0xFF00668A),
      'bgColor': const Color(0xFFC4E7FF),
    },
    'Dining': {
      'subtitle': 'Sushi & street food',
      'icon': Icons.ramen_dining_rounded,
      'color': const Color(0xFFBC4800),
      'bgColor': const Color(0xFFFFDBCD),
    },
    'Transit': {
      'subtitle': 'JR Pass & Taxis',
      'icon': Icons.train_rounded,
      'color': const Color(0xFF004AC6),
      'bgColor': const Color(0xFFDBE1FF),
    },
  };

  late List<Map<String, dynamic>> _recentExpenses;

  @override
  void initState() {
    super.initState();
    _recentExpenses = [
      {
        'id': 1,
        'title': 'Ichiran Ramen',
        'category': 'Dining',
        'subtitle': 'Today, 7:30 PM',
        'amount': 18.50,
        'date': 'Today, 7:30 PM',
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?q=80&w=300&auto=format&fit=crop',
      },
      {
        'id': 2,
        'title': 'Ryokan Kyoto Stay',
        'category': 'Lodging',
        'subtitle': '4 nights at Ryokan',
        'amount': 850.00,
        'date': 'Yesterday',
        'image':
            'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=300&auto=format&fit=crop',
      },
      {
        'id': 3,
        'title': 'JR Pass 7-Day',
        'category': 'Transit',
        'subtitle': 'JR Pass & Taxis',
        'amount': 150.00,
        'date': '12 Oct 2026',
        'image':
            'https://images.unsplash.com/photo-1532105956626-9569c03602f6?q=80&w=300&auto=format&fit=crop',
      },
      {
        'id': 4,
        'title': 'Gion Sushi Dinner',
        'category': 'Dining',
        'subtitle': 'Sushi & street food',
        'amount': 221.50,
        'date': '13 Oct 2026',
        'image':
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=300&auto=format&fit=crop',
      },
    ];
  }

  double get _totalSpent {
    return _recentExpenses.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );
  }

  double getCategorySpent(String category) {
    return _recentExpenses
        .where((item) => item['category'] == category)
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  void _showAddExpenseDialog() {
    final titleC = TextEditingController();
    final amountC = TextEditingController();
    String selectedCategory = 'Lodging';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_card_rounded, color: Color(0xFF0F172A)),
                  SizedBox(width: 10),
                  Text(
                    "Tambah Pengeluaran",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleC,
                    decoration: InputDecoration(
                      labelText: "Nama Transaksi",
                      hintText: "Misal: Ichiran Ramen",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Jumlah (\$)",
                      hintText: "Misal: 18.50",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categoryData.keys.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleC.text.trim();
                    final amount = double.tryParse(amountC.text.trim());

                    if (title.isNotEmpty && amount != null && amount > 0) {
                      setState(() {
                        _recentExpenses.insert(0, {
                          'id': DateTime.now().millisecondsSinceEpoch,
                          'title': title,
                          'category': selectedCategory,
                          'subtitle': 'Hari ini',
                          'amount': amount,
                          'date': 'Hari ini',
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Pengeluaran berhasil ditambahkan!",
                          ),
                          backgroundColor: const Color(0xFF3E9C5D),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Simpan Pengeluaran"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteExpense(int id) {
    setState(() {
      _recentExpenses.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Pengeluaran berhasil dihapus."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == 3) return;

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

  String _formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      return "\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    }
    return "\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWarm = Color(0xFFFDFBF7);
    const Color textNavy = Color(0xFF0F172A);
    const Color textSlate = Color(0xFF64748B);
    const Color naturalGreen = Color(0xFF3E9C5D);
    const Color sandBeige = Color(0xFFEDE0CB);
    const Color oceanBlue = Color(0xFF00668A);

    final spent = _totalSpent;
    final remaining = _totalBudget - spent;
    final progress = (spent / _totalBudget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: bgWarm,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: _showAddExpenseDialog,
          backgroundColor: textNavy,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            "LOG ENTRY",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Section & Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Hero Image Banner with Fallback for Tests/Offline
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                      child: Stack(
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1200&auto=format&fit=crop',
                            height: 320,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 320, color: textNavy),
                          ),
                          Container(
                            height: 320,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.45),
                                  Colors.black.withValues(alpha: 0.15),
                                  bgWarm,
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      size: 16,
                                      color: sandBeige,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "TRAVEL JOURNAL",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sandBeige,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Kyoto Getaway",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Floating Header Bar
                    Positioned(
                      top: 48,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/image/playstore.png',
                                height: 32,
                                width: 32,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.explore,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Trips",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HalamanProfil(user: widget.user),
                                ),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: oceanBlue,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 20,
                                        ),
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
              ),

              // Content Area
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Immersive Budget Tracker Card
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: sandBeige.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "TOTAL TRIP BUDGET",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textSlate,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(_totalBudget),
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "REMAINING",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textSlate,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(remaining),
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: remaining < 0
                                              ? const Color(0xFFBA1A1A)
                                              : naturalGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Thick Organic Progress Bar
                              Container(
                                width: double.infinity,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: sandBeige.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF40C2FD),
                                              Color(0xFF00668A),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF40C2FD,
                                              ).withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Progress Stats Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_formatCurrency(spent)} Spent",
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  Text(
                                    "${(progress * 100).toInt()}% Used",
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textSlate,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Spending Highlights Section
                      const Text(
                        "Spending Highlights",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categoryData.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final key = _categoryData.keys.elementAt(index);
                          final cat = _categoryData[key]!;
                          final catSpent = getCategorySpent(key);
                          final percentage = _totalSpent > 0
                              ? ((catSpent / _totalSpent) * 100).round()
                              : 0;

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: sandBeige.withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: cat['bgColor'],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    cat['icon'],
                                    color: cat['color'],
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        key,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cat['subtitle'],
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: textSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(catSpent),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (cat['bgColor'] as Color)
                                            .withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$percentage%",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: cat['color'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "VIEW FULL BREAKDOWN",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: oceanBlue,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recent Memories Section
                      const Text(
                        "Recent Memories",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_recentExpenses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: sandBeige.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Belum ada pengeluaran dicatat.",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: textSlate,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentExpenses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _recentExpenses[index];
                            final catInfo =
                                _categoryData[item['category']] ??
                                {
                                  'icon': Icons.receipt_rounded,
                                  'color': oceanBlue,
                                  'bgColor': const Color(0xFFDBE1FF),
                                };

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: sandBeige.withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: item['image'] != null
                                        ? Image.network(
                                            item['image'] as String,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      width: 56,
                                                      height: 56,
                                                      color:
                                                          catInfo['bgColor']
                                                              as Color,
                                                      child: Icon(
                                                        catInfo['icon']
                                                            as IconData,
                                                        color:
                                                            catInfo['color']
                                                                as Color,
                                                        size: 26,
                                                      ),
                                                    ),
                                          )
                                        : Container(
                                            width: 56,
                                            height: 56,
                                            color: catInfo['bgColor'] as Color,
                                            child: Icon(
                                              catInfo['icon'] as IconData,
                                              color: catInfo['color'] as Color,
                                              size: 26,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          (item['date'] ??
                                                  item['subtitle'] ??
                                                  '')
                                              as String,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: textSlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(
                                          item['amount'] as double,
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: textSlate,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _deleteExpense(item['id'] as int),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        selectedIndex: 3,
        onDestinationSelected: _onNavTapped,
      ),
    );
  }
}

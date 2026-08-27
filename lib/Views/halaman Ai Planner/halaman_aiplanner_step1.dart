import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_aiplanner_step2.dart' as step2;

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final bool isEmbeddedInShell;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.isEmbeddedInShell = false,
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isFlexibleDate = false;
  String _selectedCompanion = 'Solo';

  final List<String> _companions = ['Solo', 'Pasangan', 'Keluarga', 'Grup'];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(_departureDate!)) {
          _returnDate = null;
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime initial = _departureDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? initial.add(const Duration(days: 3)),
      firstDate: initial,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Pilih tanggal";
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _onNavTapped(int index) {
    if (index == 2) return;

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

  void _onContinue() {
    final dest = _destinationController.text.trim();
    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan masukkan atau pilih destinasi liburan."),
          backgroundColor: const Color(0xFFBC4800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    String formattedDates = "Tanggal masih fleksibel";
    if (!_isFlexibleDate && _departureDate != null) {
      if (_returnDate != null) {
        final days = _returnDate!.difference(_departureDate!).inDays + 1;
        formattedDates =
            "${_formatDate(_departureDate)} - ${_formatDate(_returnDate)} ($days Hari)";
      } else {
        formattedDates = _formatDate(_departureDate);
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step2.HalamanAiPlanner(
          user: widget.user,
          destination: dest,
          dates: formattedDates,
          departureDate: _departureDate,
          returnDate: _returnDate,
          companion: _selectedCompanion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCloud = Color(0xFFF8FAFC);
    const Color textNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF2563EB);
    const Color textSlate = Color(0xFF64748B);
    const Color surfaceVariant = Color(0xFFE1E2ED);

    return Scaffold(
      extendBody: true,
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
                  "Home",
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person_rounded, color: primaryBlue),
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
                  // Progress Indicator
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const Expanded(flex: 3, child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Headers
                  const Text(
                    "STEP 1 OF 4",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Mau liburan ke mana?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Kasih tahu aku rencana dasarnya, sisanya biar aku yang bantu susun.",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSlate,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Destination Input Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _destinationController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: textNavy,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF737686),
                        ),
                        hintText: "Cari destinasi...",
                        hintStyle: TextStyle(
                          color: Color(0x9964748B),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // AI Suggestion Chip
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _destinationController.text = "Bali & Nusa Penida";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: primaryBlue,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Belum tahu tujuannya? Kasih rekomendasi",
                            style: TextStyle(
                              fontSize: 13,
                              color: textSlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date Selection Grid (BERANGKAT & PULANG)
                  Row(
                    children: [
                      // Departure Card
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDepartureDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                const Text(
                                  "BERANGKAT",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSlate,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: primaryBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatDate(_departureDate),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Return Card
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectReturnDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                const Text(
                                  "PULANG",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSlate,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_busy_rounded,
                                      color: primaryBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatDate(_returnDate),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Flexibility Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tanggal masih fleksibel",
                        style: TextStyle(fontSize: 14, color: textSlate),
                      ),
                      Switch(
                        value: _isFlexibleDate,
                        activeThumbColor: primaryBlue,
                        onChanged: (val) {
                          setState(() {
                            _isFlexibleDate = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Companions Section
                  const Text(
                    "Siapa yang ikut?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _companions.map((companion) {
                      final isSelected = _selectedCompanion == companion;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCompanion = companion;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: isSelected
                                ? null
                                : Border.all(color: surfaceVariant),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? primaryBlue.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            companion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : textNavy,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 36),

                  // Bottom Action Button ("Lanjut")
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lanjut",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // Integrated Floating Bottom Navigation Bar
      bottomNavigationBar: widget.isEmbeddedInShell
          ? null
          : CustomFloatingNavBar(
              selectedIndex: 2,
              onDestinationSelected: _onNavTapped,
            ),
    );
  }
}

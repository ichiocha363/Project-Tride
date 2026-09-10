import 'package:flutter/material.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_aiplanner_step4.dart' as step4;

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final String destination;
  final DestinationModel? destinationModel;
  final String dates;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final bool isFlexibleDate;
  final int durationDays;
  final String companion;
  final int peopleCount;
  final bool hasChildren;
  final bool hasElderly;
  final List<String> styles;
  final String? initialBudget;
  final int? initialBudgetCeiling;
  final String? initialPace;
  final List<String>? initialAccommodations;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.destination = 'Bali, Indonesia',
    this.destinationModel,
    this.dates = '12 - 16 Sep 2024 (5 Hari)',
    this.departureDate,
    this.returnDate,
    this.isFlexibleDate = false,
    this.durationDays = 5,
    this.companion = 'Solo',
    this.peopleCount = 1,
    this.hasChildren = false,
    this.hasElderly = false,
    this.styles = const ['Fotografi', 'Alam'],
    this.initialBudget,
    this.initialBudgetCeiling,
    this.initialPace,
    this.initialAccommodations,
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  late String _selectedBudget;
  late String _selectedPace;
  final Set<String> _selectedAccommodations = {'Hotel'};
  final TextEditingController _budgetCeilingController =
      TextEditingController();

  final List<Map<String, dynamic>> _budgetLevels = [
    {
      'title': 'Hemat',
      'subtitle': 'Backpacker & efisien',
      'icon': Icons.account_balance_wallet_rounded,
      'defaultCeiling': 3000000,
    },
    {
      'title': 'Menengah',
      'subtitle': 'Kenyamanan seimbang',
      'icon': Icons.auto_awesome_rounded,
      'defaultCeiling': 7500000,
    },
    {
      'title': 'Mewah',
      'subtitle': 'Resort & eksklusif',
      'icon': Icons.diamond_rounded,
      'defaultCeiling': 15000000,
    },
  ];

  final List<Map<String, dynamic>> _paceLevels = [
    {
      'title': 'Santai',
      'spotCount': '1-2 tempat/hari',
      'description': 'Waktu santai melimpah, menikmati suasana cafe lokal',
      'icon': Icons.coffee_rounded,
    },
    {
      'title': 'Seimbang',
      'spotCount': '3-4 tempat/hari',
      'description': 'Kombinasi ideal antara eksplorasi ikonik & istirahat',
      'icon': Icons.explore_rounded,
    },
    {
      'title': 'Padat',
      'spotCount': '5+ tempat/hari',
      'description': 'Eksplorasi maksimal dari pagi hari hingga larut malam',
      'icon': Icons.bolt_rounded,
    },
  ];

  final List<Map<String, dynamic>> _accommodations = [
    {
      'title': 'Hotel',
      'subtitle': 'Kamar Privat',
      'icon': Icons.hotel_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Hostel',
      'subtitle': 'Sosial & Ramah',
      'icon': Icons.bed_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Homestay',
      'subtitle': 'Otentik Lokal',
      'icon': Icons.cottage_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1587061949409-02df41d5e562?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Villa',
      'subtitle': 'Privat & Mewah',
      'icon': Icons.holiday_village_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedBudget = widget.initialBudget ?? 'Menengah';
    _selectedPace = widget.initialPace ?? 'Seimbang';

    if (widget.initialAccommodations != null &&
        widget.initialAccommodations!.isNotEmpty) {
      _selectedAccommodations.clear();
      _selectedAccommodations.addAll(widget.initialAccommodations!);
    }

    final initialCeiling = widget.initialBudgetCeiling ?? 7500000;
    _budgetCeilingController.text = _formatCurrency(initialCeiling);
  }

  @override
  void dispose() {
    _budgetCeilingController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  int _parseCurrency(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 7500000;
  }

  void _onBudgetSelected(String title, int defaultCeiling) {
    setState(() {
      _selectedBudget = title;
      _budgetCeilingController.text = _formatCurrency(defaultCeiling);
    });
  }

  void _toggleAccommodation(String title) {
    setState(() {
      if (_selectedAccommodations.contains(title)) {
        if (_selectedAccommodations.length > 1) {
          _selectedAccommodations.remove(title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pilih minimal 1 preferensi akomodasi."),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedAccommodations.add(title);
      }
    });
  }

  void _onContinue() {
    if (_selectedAccommodations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan pilih minimal 1 akomodasi."),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final accommodationsText = _selectedAccommodations.join(' & ');
    final ceilingAmount = _parseCurrency(_budgetCeilingController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step4.HalamanAiPlanner(
          user: widget.user,
          destination: widget.destination,
          destinationModel: widget.destinationModel,
          dates: widget.dates,
          departureDate: widget.departureDate,
          returnDate: widget.returnDate,
          isFlexibleDate: widget.isFlexibleDate,
          durationDays: widget.durationDays,
          companion: widget.companion,
          peopleCount: widget.peopleCount,
          hasChildren: widget.hasChildren,
          hasElderly: widget.hasElderly,
          styles: widget.styles,
          budget: _selectedBudget,
          budgetCeiling: ceilingAmount,
          pace: _selectedPace,
          accommodation: accommodationsText,
          accommodationsList: _selectedAccommodations.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrent) {
      return const Scaffold(backgroundColor: Color(0xFFF8FAFC), body: SizedBox.shrink());
    }

    const Color bgCloud = Color(0xFFF8FAFC);
    const Color textNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textSlate = Color(0xFF64748B);
    const Color surfaceVariant = Color(0xFFE1E2ED);
    const Color surfaceContainer = Color(0xFFEDEDF9);
    const Color surfaceLow = Color(0xFFF3F3FE);
    const Color sandBeige = Color(0xFFEDE0CB);
    const Color primaryFixed = Color(0xFFDBE1FF);
    const Color onPrimaryFixed = Color(0xFF00174B);

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // App Bar matching Stitch Header
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: textNavy, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/image/playstore.png',
                  height: 30,
                  width: 30,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.explore_rounded,
                    color: primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Trips",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                        builder: (context) =>
                            HalamanProfil(user: widget.user),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryFixed,
                        width: 1.5,
                      ),
                      color: primaryFixed,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 4-Segment Progress Bar (Steps 1, 2, 3 active)
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Intro Badge & Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: onPrimaryFixed,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "STEP 3 OF 4",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: onPrimaryFixed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Berapa budget dan ritme perjalanannya?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ini bantu aku nyusun itinerary yang pas sama gaya kamu.",
                    style: TextStyle(
                      fontSize: 13,
                      color: textSlate,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 1: Level Budget Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments_rounded,
                              color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Level Budget",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "WAJIB",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSlate,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3-Column Budget Cards
                  Row(
                    children: _budgetLevels.map((item) {
                      final title = item['title'] as String;
                      final subtitle = item['subtitle'] as String;
                      final icon = item['icon'] as IconData;
                      final defaultCeiling = item['defaultCeiling'] as int;
                      final isSelected = _selectedBudget == title;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () =>
                                _onBudgetSelected(title, defaultCeiling),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 6),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? primaryBlue : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryBlue
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                                  .withValues(alpha: 0.2)
                                              : surfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: isSelected
                                              ? Colors.white
                                              : textNavy,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : textNavy,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isSelected
                                              ? Colors.white
                                                  .withValues(alpha: 0.8)
                                              : textSlate,
                                          height: 1.15,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 7,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 10,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Budget Ceiling Input Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Pagu budget (opsional)",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                              ),
                            ),
                            Text(
                              "Perjalanan ${widget.durationDays} Hari",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00668A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Rp",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _budgetCeilingController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "cth. 7.500.000",
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Ritme Perjalanan Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed_rounded,
                              color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Ritme Perjalanan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "FLEKSIBILITAS HARIAN",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSlate,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3 Stacked Pace Items
                  Column(
                    children: _paceLevels.map((item) {
                      final title = item['title'] as String;
                      final spotCount = item['spotCount'] as String;
                      final description = item['description'] as String;
                      final icon = item['icon'] as IconData;
                      final isSelected = _selectedPace == title;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPace = title;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryBlue
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : sandBeige.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF943700),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : textNavy,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          Text(
                                            spotCount,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                      .withValues(alpha: 0.85)
                                                  : textSlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white
                                                  .withValues(alpha: 0.85)
                                              : textSlate,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (isSelected)
                                  const CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 11,
                                      color: primaryBlue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Section 3: Preferensi Akomodasi Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cottage_rounded,
                              color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Preferensi Akomodasi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4E7FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Pilih 1+",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004C69),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Accommodation Cards (Row-based for smooth and reliable scroll response)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildAccommodationCard(_accommodations[0])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAccommodationCard(_accommodations[1])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildAccommodationCard(_accommodations[2])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAccommodationCard(_accommodations[3])),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Smart Insight Banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: primaryBlue.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: primaryBlue,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF434655),
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: "Kombinasi "),
                                TextSpan(
                                  text: _selectedBudget,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                const TextSpan(text: " + "),
                                TextSpan(
                                  text: _selectedPace,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      " menghemat 22% waktu mobilitas.",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Navigation: Back + Lanjut
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: surfaceLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: textNavy),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _onContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: primaryBlue.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> item) {
    const Color primaryBlue = Color(0xFF004AC6);
    final title = item['title'] as String;
    final subtitle = item['subtitle'] as String;
    final imageUrl = item['imageUrl'] as String;
    final isSelected = _selectedAccommodations.contains(title);

    return GestureDetector(
      onTap: () => _toggleAccommodation(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 105,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: primaryBlue,
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

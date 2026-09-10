import 'package:flutter/material.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_aiplanner_step3.dart' as step3;

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
  final List<String>? initialStyles;

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
    this.initialStyles,
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final Set<String> _selectedStyles = {};
  static const int _maxSelection = 3;

  final List<Map<String, dynamic>> _styles = [
    {
      'title': 'Fotografi',
      'category': 'VISUAL',
      'subtitle': 'Spot estetik & golden hour',
      'icon': Icons.photo_camera_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Kuliner',
      'category': 'RASA',
      'subtitle': 'Street food & hidden gems',
      'icon': Icons.restaurant_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Alam',
      'category': 'ECO',
      'subtitle': 'Air terjun, hutan & pantai',
      'icon': Icons.forest_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Petualangan',
      'category': 'ADVENTURE',
      'subtitle': 'Trekking & aktivitas seru',
      'icon': Icons.hiking_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Budaya',
      'category': 'KULTUR',
      'subtitle': 'Candi, tradisi & sejarah',
      'icon': Icons.account_balance_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Relaksasi',
      'category': 'RELAX',
      'subtitle': 'Spa, wellness & santai',
      'icon': Icons.spa_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialStyles != null && widget.initialStyles!.isNotEmpty) {
      _selectedStyles.addAll(widget.initialStyles!);
    } else {
      _selectedStyles.addAll({'Fotografi', 'Alam'});
    }
  }

  void _toggleStyle(String title) {
    setState(() {
      if (_selectedStyles.contains(title)) {
        _selectedStyles.remove(title);
      } else {
        if (_selectedStyles.length < _maxSelection) {
          _selectedStyles.add(title);
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Maksimal 3 gaya perjalanan. Batalkan salah satu untuk memilih gaya baru.",
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _onContinue() {
    if (_selectedStyles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan pilih minimal 1 gaya perjalanan."),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step3.HalamanAiPlanner(
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
          styles: _selectedStyles.toList(),
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
    const Color naturalGreen = Color(0xFF3E9C5D);
    const Color sandBeige = Color(0xFFEDE0CB);
    const Color primaryFixed = Color(0xFFDBE1FF);
    const Color onPrimaryFixed = Color(0xFF00174B);

    final isMaxReached = _selectedStyles.length >= _maxSelection;
    final count = _selectedStyles.length;

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
                  "Explore",
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
                  // 4-Segment Progress Bar (Steps 1 & 2 active)
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
                                  color: surfaceVariant,
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
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: onPrimaryFixed,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "STEP 2 OF 4",
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
                    "Gaya liburan kamu yang mana?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pilih vibe yang paling bikin kamu excited, nanti itinerary-nya aku sesuaikan.",
                    style: TextStyle(
                      fontSize: 13,
                      color: textSlate,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Selection Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: sandBeige.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.checklist_rtl_rounded,
                                color: Color(0xFF943700),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "STATUS PILIHAN",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: textSlate,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  "$count dari $_maxSelection terpilih",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isMaxReached
                                ? naturalGreen.withValues(alpha: 0.15)
                                : primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMaxReached
                                    ? Icons.check_circle_rounded
                                    : Icons.info_outline_rounded,
                                size: 13,
                                color: isMaxReached ? naturalGreen : primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isMaxReached ? "Kuota Pas" : "Bisa Pilih Lagi",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMaxReached ? naturalGreen : primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2x2 Photocentric Cards (Row-based for seamless scroll response)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStyleCard(_styles[0], isMaxReached)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStyleCard(_styles[1], isMaxReached)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildStyleCard(_styles[2], isMaxReached)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStyleCard(_styles[3], isMaxReached)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildStyleCard(_styles[4], isMaxReached)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStyleCard(_styles[5], isMaxReached)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Helpful Tip Card
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC4E7FF).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            color: Color(0xFF00668A),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ingin ganti pilihan?",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textNavy,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Ketuk salah satu kartu yang aktif untuk membatalkan, lalu pilih gaya baru.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSlate,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Bottom Action Button ("Lanjut")
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedStyles.isNotEmpty ? _onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            primaryBlue.withValues(alpha: 0.4),
                        elevation: 3,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard(Map<String, dynamic> item, bool isMaxReached) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color warmYellow = Color(0xFFFDB813);

    final title = item['title'] as String;
    final category = item['category'] as String;
    final subtitle = item['subtitle'] as String;
    final imageUrl = item['imageUrl'] as String;
    final isSelected = _selectedStyles.contains(title);
    final isDimmed = !isSelected && isMaxReached;

    return GestureDetector(
      onTap: () => _toggleStyle(title),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDimmed ? 0.55 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryBlue : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 32,
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
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                if (isDimmed)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: warmYellow,
                            size: 10,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "Maks 3",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

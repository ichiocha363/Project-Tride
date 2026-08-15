import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_beranda.dart';

class HalamanTripDetail extends StatefulWidget {
  final UserModel? user;
  final String title;
  final String dateRange;
  final String status;
  final Color? statusColor;
  final String countdown;
  final String imageUrl;
  final String spentBudget;
  final String totalBudget;
  final String remainingBudget;
  final double budgetProgress;
  final bool isPlanning;
  final List<Map<String, dynamic>>? itineraryDays;

  const HalamanTripDetail({
    super.key,
    this.user,
    this.title = 'Bali Escape',
    this.dateRange = '12 - 16 Sep 2024',
    this.status = 'Confirmed',
    this.statusColor,
    this.countdown = '10 Hari',
    this.imageUrl =
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000&auto=format&fit=crop',
    this.spentBudget = 'Rp 4.5M',
    this.totalBudget = 'Rp 10M',
    this.remainingBudget = 'Sisa Rp 5.500.000',
    this.budgetProgress = 0.45,
    this.isPlanning = false,
    this.itineraryDays,
  });

  @override
  State<HalamanTripDetail> createState() => _HalamanTripDetailState();
}

class _HalamanTripDetailState extends State<HalamanTripDetail> {
  late int _currentNavIndex;

  // Stitch Design Theme Colors
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color budgetCardBg = Color(0xFFF7ECE1);
  static const Color budgetIconColor = Color(0xFFC05621);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color timelineLineColor = Color(0xFFCBD5E1);

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.isPlanning ? 2 : 2;
  }

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;

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

  List<Map<String, dynamic>> _getDefaultItinerary() {
    return [
      {
        'dayNumber': 'D 01',
        'dayDate': 'Kamis, 12 Sep',
        'activities': [
          {
            'icon': Icons.flight_land_rounded,
            'time': '09:00',
            'title': 'Tiba di Bandara Ngurah Rai',
            'subtitle': 'Penjemputan menuju hotel di Ubud.',
            'cost': 'Rp 0',
            'isCompleted': true,
          },
          {
            'icon': Icons.restaurant_rounded,
            'time': '12:30',
            'title': 'Makan Siang Nasi Kedewatan',
            'subtitle': 'Makan siang lokal khas Bali.',
            'cost': 'Rp 350.000',
            'isCompleted': false,
          },
          {
            'icon': Icons.hotel_rounded,
            'time': '15:00',
            'title': 'Check-in Padma Resort',
            'subtitle': 'Istirahat dan menikmati fasilitas resort.',
            'cost': 'Rp 1.200.000',
            'isCompleted': false,
          },
        ],
      },
      {
        'dayNumber': 'D 02',
        'dayDate': 'Jumat, 13 Sep',
        'activities': [
          {
            'icon': Icons.nature_people_rounded,
            'time': '08:30',
            'title': 'Eksplorasi Ubud Rice Terrace',
            'subtitle':
                'Jalan santai dan foto di Sawah Terasering Tegallalang.',
            'cost': 'Rp 250.000',
            'isCompleted': false,
          },
          {
            'icon': Icons.local_dining_rounded,
            'time': '13:00',
            'title': 'Makan Siang Bebek Bengil',
            'subtitle': 'Nikmati sajian kuliner bebek khas Ubud.',
            'cost': 'Rp 400.000',
            'isCompleted': false,
          },
          {
            'icon': Icons.wb_twilight_rounded,
            'time': '17:00',
            'title': 'Sunset di Tanah Lot',
            'subtitle':
                'Menikmati pemandangan matahari terbenam Pura Tanah Lot.',
            'cost': 'Rp 150.000',
            'isCompleted': false,
          },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.itineraryDays ?? _getDefaultItinerary();

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Custom Header / App Bar
            _buildTopAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Hero Trip Card (Image + Title + Dates)
                    _buildHeroTripCard(),

                    const SizedBox(height: 12),

                    // Status & Countdown Ticket Stub Card
                    _buildStatusCountdownCard(),

                    const SizedBox(height: 16),

                    // Budget Snapshot Card
                    _buildBudgetSnapshotCard(),

                    const SizedBox(height: 24),

                    // Section Heading: Rencana Perjalanan
                    const Text(
                      'Rencana Perjalanan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Itinerary Timeline Section
                    _buildItineraryTimeline(days),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Floating / Bottom Action Button: Edit Rencana
            _buildEditActionButton(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavDock(),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: backgroundLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanBeranda(user: widget.user),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textDark,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.language_rounded, color: primaryBlue, size: 22),
              const SizedBox(width: 6),
              const Text(
                'EXPLORE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textDark,
                ),
              ),
            ],
          ),

          // User Profile Avatar with Error Fallback
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanProfil(user: widget.user),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Image.network(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: primaryBlue,
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
    );
  }

  Widget _buildHeroTripCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(20),
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dateRange,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCountdownCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Perforated Dashed Line Accent Top
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  height: 2,
                  color: index % 2 == 0
                      ? Colors.grey.shade300
                      : Colors.transparent,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.statusColor ?? textDark,
                      ),
                    ),
                  ],
                ),

                // Vertical Divider
                Container(height: 28, width: 1, color: Colors.grey.shade200),

                // Countdown Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'COUNTDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.countdown,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSnapshotCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: budgetCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: budgetIconColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: budgetIconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Budget Snapshot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3B32),
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.spentBudget} / ${widget.totalBudget}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B5A4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.budgetProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(160),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
          ),

          const SizedBox(height: 10),

          // Remaining Budget Label
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.remainingBudget,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C6A5D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTimeline(List<Map<String, dynamic>> days) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final dayData = days[dayIndex];
        final String dayNumber = dayData['dayNumber'] ?? 'D 01';
        final String dayDate = dayData['dayDate'] ?? 'Hari 1';
        final List activities = dayData['activities'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header Row (Pill Badge + Date)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dayDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timeline Items
            ...List.generate(activities.length, (actIndex) {
              final act = activities[actIndex];
              final isLastInDay = actIndex == activities.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Timeline Connector & Dot Indicator
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 18),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (act['isCompleted'] ?? false)
                                  ? primaryBlue
                                  : Colors.grey.shade300,
                              border: Border.all(
                                color: (act['isCompleted'] ?? false)
                                    ? primaryBlue.withAlpha(60)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isLastInDay
                                  ? timelineLineColor.withAlpha(100)
                                  : timelineLineColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Activity Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Icon + Time + Cost
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      act['icon'] as IconData? ??
                                          Icons.event_note_rounded,
                                      size: 16,
                                      color: textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      act['time'] ?? '00:00',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  act['cost'] ?? 'Rp 0',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Activity Title
                            Text(
                              act['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),

                            if (act['subtitle'] != null &&
                                (act['subtitle'] as String).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                act['subtitle'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildEditActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membuka editor rencana trip...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Edit Rencana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavDock() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
          _buildNavItem(
            1,
            Icons.explore_outlined,
            Icons.explore_rounded,
            'Explore',
          ),
          _buildNavItem(
            2,
            Icons.flight_takeoff_outlined,
            Icons.flight_takeoff_rounded,
            'Trips',
          ),
          _buildNavItem(
            3,
            Icons.account_balance_wallet_outlined,
            Icons.account_balance_wallet_rounded,
            'Budget',
          ),
          _buildNavItem(
            4,
            Icons.person_outline_rounded,
            Icons.person_rounded,
            'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () => _onNavTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? primaryBlue : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryBlue : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/trip_service.dart';
import '../halaman profile/halaman_profil.dart';
import '../halaman_utama.dart';
import 'halaman_beranda.dart';

class HalamanTripDetail extends StatefulWidget {
  final UserModel? user;
  final TripModel? trip;
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
    this.trip,
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
  TripModel? _trip;
  late String _title;
  late String _dateRange;
  late String _status;
  late String _countdown;
  late String _imageUrl;
  late int _budget;
  late int _spentBudget;
  List<Map<String, dynamic>>? _itineraryDays;
  bool _isDeleting = false;


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
    _trip = widget.trip;
    if (_trip != null) {
      _title = _trip!.tripName;
      _dateRange = _trip!.startDate.isNotEmpty
          ? '${_trip!.startDate} - ${_trip!.endDate}'
          : widget.dateRange;
      _status = _trip!.status.isNotEmpty ? _trip!.status : widget.status;
      _imageUrl = _trip!.imageUrl ?? widget.imageUrl;
      _budget = _trip!.budget;
      _spentBudget = _trip!.spentBudget;
      _countdown = _calculateCountdown(_trip!.startDate);
      _itineraryDays = _trip!.itineraryDays ?? widget.itineraryDays;
    } else {
      _title = widget.title;
      _dateRange = widget.dateRange;
      _status = widget.status;
      _imageUrl = widget.imageUrl;
      _budget = 10000000;
      _spentBudget = 4500000;
      _countdown = widget.countdown;
      _itineraryDays = widget.itineraryDays;
    }
  }

  String _calculateCountdown(String startStr) {
    try {
      final start = DateTime.parse(startStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tripStart = DateTime(start.year, start.month, start.day);
      final diff = tripStart.difference(today).inDays;
      if (diff < 0) return 'Sedang Berlangsung';
      if (diff == 0) return 'Hari Ini';
      if (diff == 1) return 'Besok';
      if (diff < 7) return '$diff Hari';
      final weeks = (diff / 7).round();
      return '$weeks Minggu';
    } catch (_) {
      return widget.countdown;
    }
  }

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;

    if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HalamanUtama(user: widget.user, initialTab: 0),
          ),
        );
      }
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HalamanUtama(user: widget.user, initialTab: index),
      ),
      (route) => false,
    );
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

  String _formatNumber(num value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawDays = _itineraryDays ?? widget.itineraryDays;
    final List<Map<String, dynamic>> days = (rawDays != null && rawDays.isNotEmpty)
        ? rawDays
        : (widget.trip == null ? _getDefaultItinerary() : <Map<String, dynamic>>[]);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rencana Perjalanan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openAddItineraryDialog,
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: primaryBlue,
                          ),
                          label: const Text(
                            '+ Tambah Aktivitas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            backgroundColor: primaryBlue.withAlpha(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
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
                'TRIP DETAIL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textDark,
                ),
              ),
            ],
          ),

          Row(
            children: [
              if (_trip?.id != null && _trip!.id!.trim().isNotEmpty)
                IconButton(
                  tooltip: 'Hapus Trip',
                  onPressed: _isDeleting ? null : _confirmDeleteTrip,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
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
                _imageUrl,
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
                      _title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateRange,
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
                      _status,
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
                      _countdown,
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
    final spentDisplay = _trip != null
        ? 'Rp ${_formatNumber(_trip!.spentBudget)}'
        : widget.spentBudget;
    final totalDisplay = _trip != null
        ? 'Rp ${_formatNumber(_trip!.budget)}'
        : widget.totalBudget;
    final remainingVal = _trip != null ? _trip!.budget - _trip!.spentBudget : 0;
    final remainingDisplay = _trip != null
        ? 'Sisa Rp ${_formatNumber(remainingVal.clamp(0, 999999999999))}'
        : widget.remainingBudget;
    final progress = _budget > 0
        ? (_spentBudget / _budget).clamp(0.0, 1.0)
        : widget.budgetProgress;

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
                '$spentDisplay / $totalDisplay',
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
              value: progress,
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
              remainingDisplay,
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
    if (days.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryBlue.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada itinerary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jadwal aktivitas perjalanan akan muncul di sini setelah dibuat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAddItineraryDialog,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: const Text(
                '+ Tambah Aktivitas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final dayData = days[dayIndex];

        // Safe day number parsing (e.g. D 01, D 02)
        String dayNumber = 'D ${(dayIndex + 1).toString().padLeft(2, '0')}';
        if (dayData['dayNumber'] != null &&
            dayData['dayNumber'].toString().isNotEmpty) {
          dayNumber = dayData['dayNumber'].toString();
        } else if (dayData['day'] != null) {
          final match = RegExp(r'\d+').firstMatch(dayData['day'].toString());
          if (match != null) {
            dayNumber = 'D ${match.group(0)!.padLeft(2, '0')}';
          } else {
            dayNumber = dayData['day'].toString();
          }
        }

        // Safe day date/title parsing
        String dayDate = 'Hari ${dayIndex + 1}';
        if (dayData['dayDate'] != null &&
            dayData['dayDate'].toString().isNotEmpty) {
          dayDate = dayData['dayDate'].toString();
        } else if (dayData['title'] != null &&
            dayData['title'].toString().isNotEmpty) {
          final dayPrefix =
              dayData['day'] != null ? '${dayData['day']} · ' : '';
          dayDate = '$dayPrefix${dayData['title']}';
        } else if (dayData['date'] != null &&
            dayData['date'].toString().isNotEmpty) {
          dayDate = dayData['date'].toString();
        } else if (dayData['day'] != null &&
            dayData['day'].toString().isNotEmpty) {
          dayDate = dayData['day'].toString();
        }

        // Safe activities list extraction
        final dynamic rawActivities =
            dayData['activities'] ?? dayData['schedule'] ?? dayData['items'];
        final List activitiesList =
            rawActivities is List ? rawActivities : [];

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
                Expanded(
                  child: Text(
                    dayDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (activitiesList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: Text(
                  'Tidak ada aktivitas tercatat untuk hari ini.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: textMuted,
                  ),
                ),
              )
            else
              ...List.generate(activitiesList.length, (actIndex) {
                final act = _ParsedActivity.fromDynamic(
                  activitiesList[actIndex],
                  actIndex,
                );
                final isLastInDay = actIndex == activitiesList.length - 1;

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
                                color: act.isCompleted
                                    ? primaryBlue
                                    : Colors.grey.shade300,
                                border: Border.all(
                                  color: act.isCompleted
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
                              // Top Row: Icon + Time + Cost + Edit/Delete Actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        act.icon,
                                        size: 16,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        act.time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        act.cost,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        key: Key('edit_act_${dayIndex}_$actIndex'),
                                        onTap: () => _openEditItineraryDialog(
                                          dayIndex,
                                          actIndex,
                                          act,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        key: Key('delete_act_${dayIndex}_$actIndex'),
                                        onTap: () => _confirmDeleteItineraryItem(
                                          dayIndex,
                                          actIndex,
                                          act,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Activity Title
                              Text(
                                act.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),

                              if (act.location != null &&
                                  act.location!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 13,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        act.location!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (act.subtitle != null &&
                                  act.subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  act.subtitle!,
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

  void _confirmDeleteTrip() {
    if (_isDeleting) return;
    final tripId = _trip?.id?.trim();

    debugPrint('''
=== DELETE TRIP START (UI CALL) ===
Auth UID: ${TripService.instance.currentUserId ?? 'NULL / Unauthenticated'}
Trip Model ID: ${tripId ?? 'NULL'}
Trip Model ID type: ${tripId.runtimeType}
Trip Name: $_title
''');

    if (tripId == null || tripId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menghapus trip. Document ID tidak valid."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                "Hapus Trip",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus rencana perjalanan '$_title'?",
            style: const TextStyle(fontSize: 14, color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: _isDeleting
                  ? null
                  : () async {
                      setDialogState(() => _isDeleting = true);
                      if (mounted) setState(() => _isDeleting = true);

                      try {
                        final success = await TripService.instance.deleteTrip(
                          tripId,
                          tripName: _title,
                        );

                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Trip berhasil dihapus"),
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal menghapus trip. Coba lagi."),
                            ),
                          );
                        }
                      } on FirebaseException catch (e) {
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (!mounted) return;

                        String errorMsg = "Gagal menghapus trip. Coba lagi.";
                        if (e.code == 'permission-denied') {
                          errorMsg = "Anda tidak memiliki akses untuk menghapus trip ini.";
                        } else if (e.code == 'unavailable' || e.code == 'network-request-failed') {
                          errorMsg = "Gagal menghapus trip. Periksa koneksi internet.";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMsg)),
                        );
                      } catch (e) {
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Gagal menghapus trip. Terjadi kesalahan."),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isDeleting = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Hapus"),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditTripDialog() {
    final titleController = TextEditingController(text: _title);
    final budgetController =
        TextEditingController(text: _budget > 0 ? _budget.toString() : '');
    String tempStatus = _status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Rencana Trip",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Nama Trip",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_road_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Total Budget (Rp)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: ['upcoming', 'ongoing', 'completed', 'cancelled']
                            .contains(tempStatus.toLowerCase())
                        ? tempStatus.toLowerCase()
                        : 'upcoming',
                    decoration: InputDecoration(
                      labelText: "Status Trip",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'upcoming',
                        child: Text('Upcoming'),
                      ),
                      DropdownMenuItem(
                        value: 'ongoing',
                        child: Text('Ongoing'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempStatus = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newTitle = titleController.text.trim();
                        final newBudget =
                            int.tryParse(budgetController.text.trim()) ??
                            _budget;
                        if (newTitle.isEmpty) return;

                        if (_trip != null && _trip!.id != null) {
                          final updated = _trip!.copyWith(
                            tripName: newTitle,
                            budget: newBudget,
                            status: tempStatus,
                          );
                          final ok =
                              await TripService.instance.updateTrip(updated);
                          if (ok) {
                            setState(() {
                              _trip = updated;
                              _title = newTitle;
                              _budget = newBudget;
                              _status = tempStatus;
                            });
                          }
                        } else {
                          setState(() {
                            _title = newTitle;
                            _budget = newBudget;
                            _status = tempStatus;
                          });
                        }

                        if (modalCtx.mounted) {
                          Navigator.pop(modalCtx);
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Rencana trip berhasil diperbarui!",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Future<bool> _saveItineraryDaysToFirestore(
    List<Map<String, dynamic>> newDays,
  ) async {
    final tripId = _trip?.id?.trim();
    final uid = widget.user?.id?.toString();

    setState(() {
      _itineraryDays = newDays;
      if (_trip != null) {
        _trip = _trip!.copyWith(itineraryDays: newDays);
      }
    });

    if (tripId != null && tripId.isNotEmpty) {
      final success = await TripService.instance.updateItineraryDays(
        tripId,
        newDays,
        uid: uid,
      );
      return success;
    }
    return true;
  }

  void _openAddItineraryDialog() {
    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (_itineraryDays ?? widget.itineraryDays ?? [])
          .map((e) => Map<String, dynamic>.from(e)),
    );

    int selectedDayIndex = 0;
    if (days.isEmpty) {
      selectedDayIndex = -1;
    }

    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '09:00');
    final locationController = TextEditingController();
    final descController = TextEditingController();
    final costController = TextEditingController(text: 'Rp 0');
    final newDayTitleController = TextEditingController(
      text: 'Hari ${days.length + 1}',
    );

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "+ Tambah Aktivitas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<int>(
                    initialValue: selectedDayIndex,
                    decoration: InputDecoration(
                      labelText: "Pilih Hari",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_month_rounded),
                    ),
                    items: [
                      ...List.generate(days.length, (i) {
                        final d = days[i];
                        final dNum = d['dayNumber'] ?? d['day'] ?? 'Hari ${i + 1}';
                        final dTitle = d['dayDate'] ?? d['title'] ?? '';
                        final label = dTitle.isNotEmpty ? '$dNum ($dTitle)' : '$dNum';
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        );
                      }),
                      DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          "+ Tambah Hari Baru (Hari ${days.length + 1})",
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    onChanged: isSaving
                        ? null
                        : (val) {
                            if (val != null) {
                              setModalState(() => selectedDayIndex = val);
                            }
                          },
                  ),

                  if (selectedDayIndex == -1) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: newDayTitleController,
                      enabled: !isSaving,
                      decoration: InputDecoration(
                        labelText: "Judul Hari Baru",
                        hintText: "Contoh: Hari 1 - Kedatangan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: "Judul Aktivitas *",
                      hintText: "Contoh: Dinner di Jimbaran",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.event_available_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            labelText: "Waktu",
                            hintText: "09:00",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.access_time_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: costController,
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            labelText: "Estimasi Biaya",
                            hintText: "Rp 150.000",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: "Lokasi (Opsional)",
                      hintText: "Contoh: Pantai Jimbaran",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    enabled: !isSaving,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Catatan / Deskripsi (Opsional)",
                      hintText: "Contoh: Pesan tempat di area outdoor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final actTitle = titleController.text.trim();
                              if (actTitle.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Judul aktivitas wajib diisi"),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);

                              final newActMap = <String, dynamic>{
                                'id':
                                    'act_${DateTime.now().millisecondsSinceEpoch}',
                                'title': actTitle,
                                'time': timeController.text.trim().isNotEmpty
                                    ? timeController.text.trim()
                                    : '09:00',
                                'cost': costController.text.trim().isNotEmpty
                                    ? costController.text.trim()
                                    : 'Rp 0',
                                'location': locationController.text.trim(),
                                'subtitle': descController.text.trim(),
                                'description': descController.text.trim(),
                                'isCompleted': false,
                              };

                              final updatedDays = List<Map<String, dynamic>>.from(
                                days.map((e) => Map<String, dynamic>.from(e)),
                              );

                              if (selectedDayIndex >= 0 &&
                                  selectedDayIndex < updatedDays.length) {
                                final targetDay = Map<String, dynamic>.from(
                                  updatedDays[selectedDayIndex],
                                );
                                final rawActs = targetDay['activities'] ??
                                    targetDay['schedule'] ??
                                    targetDay['items'];
                                final List acts = rawActs is List
                                    ? List.from(rawActs)
                                    : [];
                                acts.add(newActMap);
                                targetDay['activities'] = acts;
                                updatedDays[selectedDayIndex] = targetDay;
                              } else {
                                final newDayNum = updatedDays.length + 1;
                                final newDayTitle = newDayTitleController.text
                                        .trim()
                                        .isNotEmpty
                                    ? newDayTitleController.text.trim()
                                    : 'Hari $newDayNum';
                                updatedDays.add({
                                  'day': newDayTitle,
                                  'title': newDayTitle,
                                  'dayNumber':
                                      'D ${newDayNum.toString().padLeft(2, '0')}',
                                  'dayDate': newDayTitle,
                                  'activities': [newActMap],
                                });
                              }

                              final ok = await _saveItineraryDaysToFirestore(
                                updatedDays,
                              );

                              if (modalCtx.mounted) Navigator.pop(modalCtx);
                              if (!mounted) return;

                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Aktivitas berhasil ditambahkan!",
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Gagal menyimpan ke Firestore. Data lokal diperbarui.",
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Simpan Aktivitas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  void _openEditItineraryDialog(
    int dayIndex,
    int actIndex,
    _ParsedActivity act,
  ) {
    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (_itineraryDays ?? widget.itineraryDays ?? [])
          .map((e) => Map<String, dynamic>.from(e)),
    );

    final titleController = TextEditingController(text: act.title);
    final timeController = TextEditingController(text: act.time);
    final locationController = TextEditingController(text: act.location ?? '');
    final descController = TextEditingController(text: act.subtitle ?? '');
    final costController = TextEditingController(text: act.cost);

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Aktivitas Itinerary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: "Judul Aktivitas *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.event_available_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            labelText: "Waktu",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.access_time_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: costController,
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            labelText: "Estimasi Biaya",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.monetization_on_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: "Lokasi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    enabled: !isSaving,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Catatan / Deskripsi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final actTitle = titleController.text.trim();
                              if (actTitle.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Judul aktivitas wajib diisi"),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);

                              final updatedActMap = Map<String, dynamic>.from(
                                act.rawMap,
                              );
                              updatedActMap['id'] = act.id;
                              updatedActMap['title'] = actTitle;
                              updatedActMap['time'] =
                                  timeController.text.trim().isNotEmpty
                                      ? timeController.text.trim()
                                      : act.time;
                              updatedActMap['cost'] =
                                  costController.text.trim().isNotEmpty
                                      ? costController.text.trim()
                                      : act.cost;
                              updatedActMap['location'] =
                                  locationController.text.trim();
                              updatedActMap['subtitle'] =
                                  descController.text.trim();
                              updatedActMap['description'] =
                                  descController.text.trim();

                              final updatedDays = List<Map<String, dynamic>>.from(
                                days.map((e) => Map<String, dynamic>.from(e)),
                              );

                              if (dayIndex >= 0 &&
                                  dayIndex < updatedDays.length) {
                                final targetDay = Map<String, dynamic>.from(
                                  updatedDays[dayIndex],
                                );
                                final rawActs = targetDay['activities'] ??
                                    targetDay['schedule'] ??
                                    targetDay['items'];
                                final List acts = rawActs is List
                                    ? List.from(rawActs)
                                    : [];
                                if (actIndex >= 0 && actIndex < acts.length) {
                                  acts[actIndex] = updatedActMap;
                                  targetDay['activities'] = acts;
                                  updatedDays[dayIndex] = targetDay;
                                }
                              }

                              final ok = await _saveItineraryDaysToFirestore(
                                updatedDays,
                              );

                              if (modalCtx.mounted) Navigator.pop(modalCtx);
                              if (!mounted) return;

                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Aktivitas berhasil diperbarui!",
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Gagal menyimpan ke Firestore. Data lokal diperbarui.",
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Simpan Perubahan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  void _confirmDeleteItineraryItem(
    int dayIndex,
    int actIndex,
    _ParsedActivity act,
  ) {
    final List<Map<String, dynamic>> days = List<Map<String, dynamic>>.from(
      (_itineraryDays ?? widget.itineraryDays ?? [])
          .map((e) => Map<String, dynamic>.from(e)),
    );

    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                "Hapus Aktivitas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus aktivitas '${act.title}'?",
            style: const TextStyle(fontSize: 14, color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);

                      final updatedDays = List<Map<String, dynamic>>.from(
                        days.map((e) => Map<String, dynamic>.from(e)),
                      );

                      if (dayIndex >= 0 && dayIndex < updatedDays.length) {
                        final targetDay = Map<String, dynamic>.from(
                          updatedDays[dayIndex],
                        );
                        final rawActs = targetDay['activities'] ??
                            targetDay['schedule'] ??
                            targetDay['items'];
                        final List acts = rawActs is List ? List.from(rawActs) : [];
                        if (actIndex >= 0 && actIndex < acts.length) {
                          acts.removeAt(actIndex);
                          targetDay['activities'] = acts;
                          updatedDays[dayIndex] = targetDay;
                        }
                      }

                      final ok = await _saveItineraryDaysToFirestore(updatedDays);

                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      if (!mounted) return;

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Aktivitas berhasil dihapus"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Gagal memperbarui Firestore. Data lokal diperbarui.",
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Hapus"),
            ),
          ],
        ),
      ),
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
        onPressed: _openEditTripDialog,
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

/// Helper model untuk parsing aktivitas harian secara aman dari berbagai tipe data (String / Map).
class _ParsedActivity {
  final String id;
  final String title;
  final String? subtitle;
  final String time;
  final String cost;
  final String? location;
  final bool isCompleted;
  final IconData icon;
  final Map<String, dynamic> rawMap;

  _ParsedActivity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.time,
    required this.cost,
    this.location,
    required this.isCompleted,
    required this.icon,
    required this.rawMap,
  });

  factory _ParsedActivity.fromDynamic(dynamic act, int index) {
    final String genId = 'act_${DateTime.now().millisecondsSinceEpoch}_$index';

    if (act is Map) {
      final map = Map<String, dynamic>.from(act);
      final id = map['id']?.toString() ?? genId;
      final title = map['title']?.toString() ??
          map['name']?.toString() ??
          map['activity']?.toString() ??
          map['description']?.toString() ??
          'Aktivitas ${index + 1}';
      final subtitle = map['subtitle']?.toString() ??
          map['desc']?.toString() ??
          map['notes']?.toString() ??
          (map['description'] != title ? map['description']?.toString() : null);
      final location = map['location']?.toString();
      final time = map['time']?.toString() ?? _defaultTimeForIndex(index);
      final cost = map['cost']?.toString() ?? 'Rp 0';
      final isCompleted = map['isCompleted'] == true ||
          map['completed'] == true ||
          map['is_completed'] == true;

      IconData icon = Icons.place_rounded;
      if (map['icon'] is IconData) {
        icon = map['icon'] as IconData;
      } else {
        icon = _iconForText('$title ${subtitle ?? ''} ${location ?? ''}');
      }

      return _ParsedActivity(
        id: id,
        title: title,
        subtitle: subtitle != null && subtitle.isNotEmpty ? subtitle : null,
        time: time,
        cost: cost,
        location: location != null && location.isNotEmpty ? location : null,
        isCompleted: isCompleted,
        icon: icon,
        rawMap: map,
      );
    } else if (act is String) {
      final text = act.trim();
      final title = text.isNotEmpty ? text : 'Aktivitas ${index + 1}';
      final map = <String, dynamic>{
        'id': genId,
        'title': title,
        'time': _defaultTimeForIndex(index),
        'cost': 'Rp 0',
        'isCompleted': false,
      };
      return _ParsedActivity(
        id: genId,
        title: title,
        subtitle: null,
        time: _defaultTimeForIndex(index),
        cost: 'Rp 0',
        location: null,
        isCompleted: false,
        icon: _iconForText(text),
        rawMap: map,
      );
    } else {
      final text = act?.toString() ?? 'Aktivitas ${index + 1}';
      final map = <String, dynamic>{
        'id': genId,
        'title': text,
        'time': _defaultTimeForIndex(index),
        'cost': 'Rp 0',
        'isCompleted': false,
      };
      return _ParsedActivity(
        id: genId,
        title: text,
        subtitle: null,
        time: _defaultTimeForIndex(index),
        cost: 'Rp 0',
        location: null,
        isCompleted: false,
        icon: Icons.event_note_rounded,
        rawMap: map,
      );
    }
  }

  static String _defaultTimeForIndex(int index) {
    const times = ['09:00', '12:30', '15:30', '18:30', '20:00'];
    return times[index % times.length];
  }

  static IconData _iconForText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('bandara') ||
        lower.contains('flight') ||
        lower.contains('pesawat') ||
        lower.contains('airport') ||
        lower.contains('penjemputan') ||
        lower.contains('transfer')) {
      return Icons.flight_land_rounded;
    }
    if (lower.contains('makan') ||
        lower.contains('kuliner') ||
        lower.contains('resto') ||
        lower.contains('sarapan') ||
        lower.contains('siang') ||
        lower.contains('malam') ||
        lower.contains('dinner') ||
        lower.contains('lunch') ||
        lower.contains('breakfast') ||
        lower.contains('coffee') ||
        lower.contains('kafe') ||
        lower.contains('cafe')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('hotel') ||
        lower.contains('resort') ||
        lower.contains('villa') ||
        lower.contains('check-in') ||
        lower.contains('homestay') ||
        lower.contains('hostel') ||
        lower.contains('penginapan') ||
        lower.contains('istirahat')) {
      return Icons.hotel_rounded;
    }
    if (lower.contains('sunset') ||
        lower.contains('pantai') ||
        lower.contains('beach') ||
        lower.contains('laut') ||
        lower.contains('sunrise')) {
      return Icons.wb_twilight_rounded;
    }
    if (lower.contains('foto') ||
        lower.contains('photo') ||
        lower.contains('kamera') ||
        lower.contains('spot ikonik') ||
        lower.contains('panoramik')) {
      return Icons.camera_alt_rounded;
    }
    if (lower.contains('belanja') ||
        lower.contains('oleh-oleh') ||
        lower.contains('souvenir') ||
        lower.contains('pasar') ||
        lower.contains('mall')) {
      return Icons.shopping_bag_rounded;
    }
    if (lower.contains('alam') ||
        lower.contains('gunung') ||
        lower.contains('hutan') ||
        lower.contains('taman') ||
        lower.contains('curug') ||
        lower.contains('air terjun') ||
        lower.contains('trekking') ||
        lower.contains('nature')) {
      return Icons.nature_people_rounded;
    }
    if (lower.contains('budaya') ||
        lower.contains('candi') ||
        lower.contains('museum') ||
        lower.contains('istana') ||
        lower.contains('keraton') ||
        lower.contains('pura') ||
        lower.contains('temple')) {
      return Icons.museum_rounded;
    }
    return Icons.place_rounded;
  }
}

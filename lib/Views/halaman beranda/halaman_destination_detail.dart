import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';
import 'halaman_beranda.dart';

class HalamanDestinationDetail extends StatefulWidget {
  final UserModel? user;
  final String destinationTitle;
  final String categoryTag;
  final String imageUrl;
  final String rating;
  final String weather;
  final String pricePerDay;
  final String description;
  final List<Map<String, dynamic>>? highlights;
  final List<Map<String, dynamic>>? accommodations;
  final Map<String, dynamic>? culinary;

  const HalamanDestinationDetail({
    super.key,
    this.user,
    this.destinationTitle = 'Bali, Indonesia',
    this.categoryTag = 'DESTINASI POPULER',
    this.imageUrl =
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1200&auto=format&fit=crop',
    this.rating = '4.8',
    this.weather = '28°C',
    this.pricePerDay = 'Rp 1.5M',
    this.description =
        'Tinggalkan rutinitas dan larikan diri ke surga tropis. Bali menawarkan perpaduan sempurna antara budaya spiritual yang kental, pantai-pantai berpasir putih yang menawan, dan kehidupan malam yang bersemangat. Temukan kedamaian di Ubud, atau tantang ombak di Canggu.',
    this.highlights,
    this.accommodations,
    this.culinary,
  });

  @override
  State<HalamanDestinationDetail> createState() =>
      _HalamanDestinationDetailState();
}

class _HalamanDestinationDetailState extends State<HalamanDestinationDetail> {
  bool _isBookmarked = false;
  final int _currentNavIndex = 1;

  // Design Tokens & Colors matching Stitch Spec
  static const Color primaryBlue = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color bgCloud = Color(0xFFF8FAFC);
  static const Color textNavy = Color(0xFF0F172A);
  static const Color textSlate = Color(0xFF64748B);
  static const Color warmYellow = Color(0xFFFDB813);
  static const Color secondaryColor = Color(0xFF00668A);
  static const Color secondaryContainer = Color(0xFF40C2FD);
  static const Color sandBeige = Color(0xFFEDE0CB);
  static const Color tertiaryOrange = Color(0xFFFB7A3C);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  final List<Map<String, dynamic>> _defaultHighlights = [
    {
      'title': 'Terasering Tegalalang',
      'description':
          'Jelajahi keindahan sawah berundak ikonik yang menawarkan pemandangan spektakuler.',
      'category': 'Aktivitas Alam',
      'icon': Icons.directions_run_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Pura Uluwatu',
      'description':
          'Saksikan matahari terbenam magis dengan latar belakang pura kuno di atas tebing.',
      'category': 'Budaya & Sejarah',
      'icon': Icons.account_balance_rounded,
      'imageUrl':
          'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=800&auto=format&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _defaultAccommodations = [
    {
      'title': 'Bambu Indah Resort',
      'subtitle': 'Ubud • Eco-Lodge',
      'rating': '4.9',
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'COMO Uma Canggu',
      'subtitle': 'Canggu • Beachfront',
      'rating': '4.7',
      'imageUrl':
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800&auto=format&fit=crop',
    },
  ];

  final Map<String, dynamic> _defaultCulinary = {
    'title': 'Nasi Campur Bali',
    'description':
        'Perpaduan lauk pauk kaya rempah khas dewata dalam satu piring.',
    'imageUrl':
        'https://images.unsplash.com/photo-1596450514735-3769c3a37651?q=80&w=800&auto=format&fit=crop',
  };

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
        Navigator.push(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCloud,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image Banner
                _buildHeroBanner(),

                const SizedBox(height: 12),

                // 2. Metrics Quick Info Bar
                _buildMetricCards(),

                const SizedBox(height: 24),

                // Content Padding Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Description
                      _buildDescriptionSection(),

                      const SizedBox(height: 32),

                      // 4. Hal Menarik
                      _buildHighlightsSection(),

                      const SizedBox(height: 32),

                      // 5. Tempat Menginap
                      _buildAccommodationsSection(),

                      const SizedBox(height: 32),

                      // 6. Kuliner Lokal
                      _buildCulinarySection(),

                      const SizedBox(height: 32),

                      // 7. Lokasi Map Section
                      _buildLocationSection(),

                      // Spacing at bottom for floating button
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Floating Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildFloatingActionButton(),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textSlate,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Jelajah',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff_outlined),
              activeIcon: Icon(Icons.flight_takeoff_rounded),
              label: 'Perjalanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Anggaran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // 1. Hero Image Banner Widget
  Widget _buildHeroBanner() {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: primaryBlue.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: primaryBlue,
                  size: 64,
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Top Action Controls (Back Button & Bookmark Button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HalamanBeranda(user: widget.user),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  // Bookmark Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isBookmarked
                                ? '${widget.destinationTitle} disimpan ke favorit'
                                : '${widget.destinationTitle} dihapus dari favorit',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isBookmarked ? warmYellow : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Hero Text & Tag
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.categoryTag.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Hero Title
                Text(
                  widget.destinationTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Metrics Quick Info Bar Widget
  Widget _buildMetricCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Rating Card
            _buildMetricCardItem(
              icon: Icons.star_rounded,
              iconBgColor: warmYellow.withValues(alpha: 0.2),
              iconColor: warmYellow,
              value: widget.rating,
              label: 'Rating',
            ),
            const SizedBox(width: 12),

            // Cuaca Card
            _buildMetricCardItem(
              icon: Icons.wb_cloudy_outlined,
              iconBgColor: secondaryContainer.withValues(alpha: 0.2),
              iconColor: secondaryColor,
              value: widget.weather,
              label: 'Cuaca',
            ),
            const SizedBox(width: 12),

            // Estimasi Biaya Card
            _buildMetricCardItem(
              icon: Icons.payments_outlined,
              iconBgColor: sandBeige,
              iconColor: const Color(0xFF7D2D00),
              value: widget.pricePerDay,
              label: 'Per Hari',
              textColor: const Color(0xFF360F00),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCardItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
    Color textColor = textNavy,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 125),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: textColor == textNavy
                      ? textSlate
                      : textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Description Section
  Widget _buildDescriptionSection() {
    return Text(
      widget.description,
      style: const TextStyle(
        color: Color(0xFF434655),
        fontSize: 15,
        height: 1.6,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // 4. Hal Menarik Section Widget
  Widget _buildHighlightsSection() {
    final highlightsList = widget.highlights ?? _defaultHighlights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hal Menarik',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textNavy,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menampilkan semua hal menarik...'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'LIHAT SEMUA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Highlight Cards
        Column(
          children: highlightsList.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Card Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item['imageUrl'] as String,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 90,
                          height: 90,
                          color: primaryBlue.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.landscape_rounded,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: textSlate,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                (item['icon'] as IconData?) ??
                                    Icons.explore_rounded,
                                size: 14,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (item['category'] as String?) ?? 'Aktivitas',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Tempat Menginap Section Widget
  Widget _buildAccommodationsSection() {
    final list = widget.accommodations ?? _defaultAccommodations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempat Menginap',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textNavy,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Horizontal List
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                width: 230,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accommodation Image with Rating Badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            item['imageUrl'] as String,
                            width: 230,
                            height: 145,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 230,
                                  height: 145,
                                  color: secondaryColor.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.hotel_rounded,
                                    color: secondaryColor,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: warmYellow,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item['rating'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title & Subtitle
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textNavy,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
                      style: const TextStyle(fontSize: 13, color: textSlate),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 6. Kuliner Lokal Section Widget
  Widget _buildCulinarySection() {
    final culinaryData = widget.culinary ?? _defaultCulinary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kuliner Lokal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textNavy,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: tertiaryOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Featured Culinary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Dish Image Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3F3FE), width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    culinaryData['imageUrl'] as String,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 76,
                      height: 76,
                      color: tertiaryOrange.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: tertiaryOrange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Dish Info & Action Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      culinaryData['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textNavy,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      culinaryData['description'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textSlate,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mencari rekomendasi ${culinaryData['title']}...',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 14,
                            color: primaryBlue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Temukan Rekomendasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Lokasi Map Section Widget
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textNavy,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 14),

        // Map Box Container
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Map Background Image
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE1E2ED),
                      child: const Icon(
                        Icons.map_rounded,
                        color: textSlate,
                        size: 48,
                      ),
                    ),
                  ),
                ),

                // Subtle Dark Tint Overlay
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.15)),
                ),

                // Center Pin Icon Marker
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Map Overlay Label
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 14,
                          color: primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.destinationTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 8. Sticky Bottom Floating Action Button Widget
  Widget _buildFloatingActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryBlue, primaryContainer]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanAiPlanner(user: widget.user),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Buat Rencana Perjalanan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

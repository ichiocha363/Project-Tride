import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Database/accommodation_model.dart';
import 'package:project_tride/Database/attraction_model.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/local_food_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import 'package:project_tride/Services/saved_places_service.dart';
import '../halaman Ai Planner/halaman_aiplanner_step1.dart';
import '../halaman profile/halaman_saved_places.dart';
import 'halaman_beranda.dart';

class HalamanDestinationDetail extends StatefulWidget {
  final UserModel? user;
  final int? destinationId;
  final DestinationModel? destination;
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
  final int initialTab;
  final bool isEmbeddedInShell;

  const HalamanDestinationDetail({
    super.key,
    this.user,
    this.destinationId,
    this.destination,
    this.destinationTitle = 'Bali, Indonesia',
    this.categoryTag = 'DESTINASI POPULER',
    this.imageUrl =
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1200&auto=format&fit=crop',
    this.rating = '4.8',
    this.weather = '28°C',
    this.pricePerDay = 'Rp 1.5M',
    this.description =
        'Tinggalkan rutinitas dan nikmati keindahan destinasi wisata Indonesia. Temukan kedamaian, pesona budaya, dan petualangan tak terlupakan.',
    this.highlights,
    this.accommodations,
    this.culinary,
    this.initialTab = 1,
    this.isEmbeddedInShell = false,
  });

  @override
  State<HalamanDestinationDetail> createState() =>
      _HalamanDestinationDetailState();
}

class _HalamanDestinationDetailState extends State<HalamanDestinationDetail> {
  bool _isFavorited = false;
  bool _isLoadingTravelData = true;

  DestinationModel? _loadedDestination;
  List<AttractionModel> _attractions = [];
  List<AccommodationModel> _accommodations = [];
  List<LocalFoodModel> _localFoods = [];

  // Design Tokens & Colors matching AppColors
  static const Color primaryBlue = AppColors.primaryDeep;
  static const Color primaryContainer = AppColors.primary;
  static const Color bgCloud = AppColors.background;
  static const Color textNavy = AppColors.textPrimary;
  static const Color textSlate = AppColors.textSecondary;
  static const Color warmYellow = AppColors.warning;
  static const Color secondaryColor = AppColors.info;
  static const Color secondaryContainer = AppColors.secondary;
  static const Color sandBeige = AppColors.surfaceVariant;
  static const Color tertiaryOrange = AppColors.sunsetOrange;
  static const Color surfaceCard = AppColors.surface;

  @override
  void initState() {
    super.initState();
    _loadedDestination = widget.destination;
    _checkFavoriteStatus();
    _fetchTravelData();
  }

  @override
  void didUpdateWidget(HalamanDestinationDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationId != widget.destinationId ||
        oldWidget.destination != widget.destination ||
        oldWidget.destinationTitle != widget.destinationTitle) {
      setState(() {
        _isLoadingTravelData = true;
        _loadedDestination = widget.destination;
      });
      _checkFavoriteStatus();
      _fetchTravelData();
    }
  }

  int? _getDestinationId() {
    if (widget.destinationId != null && widget.destinationId! > 0) {
      return widget.destinationId;
    }
    if (widget.destination?.id != null && widget.destination!.id! > 0) {
      return widget.destination!.id;
    }
    return null;
  }

  Future<void> _checkFavoriteStatus() async {
    final destId = _getDestinationId();
    if (destId == null) return;
    try {
      final isFav = await SavedPlacesService.instance.isFavorite(destId);
      if (mounted) {
        setState(() {
          _isFavorited = isFav;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTravelData() async {
    int? destId = _getDestinationId();

    // Resolusi nama destinasi jika destinationId tidak dikirimkan langsung
    if (destId == null && widget.destinationTitle.isNotEmpty) {
      try {
        final allDests = await DestinationService.instance.getDestinations();
        final rawTitle = widget.destinationTitle.toLowerCase().trim();
        for (final d in allDests) {
          final dName = d.name.toLowerCase().trim();
          if (rawTitle == dName || rawTitle.startsWith(dName) || dName.startsWith(rawTitle)) {
            destId = d.id;
            break;
          }
        }
      } catch (_) {}
    }

    if (destId == null) {
      if (mounted) {
        setState(() {
          _isLoadingTravelData = false;
        });
      }
      return;
    }

    try {
      debugPrint('[HalamanDestinationDetail] Fetching travel data for destination ID: $destId');
      final results = await Future.wait([
        DestinationService.instance.getDestinationById(destId),
        DestinationService.instance.getAttractions(destId),
        DestinationService.instance.getAccommodations(destId),
        DestinationService.instance.getLocalFoods(destId),
      ]);

      if (mounted) {
        setState(() {
          _loadedDestination =
              (results[0] as DestinationModel?) ?? widget.destination;
          _attractions = results[1] as List<AttractionModel>;
          _accommodations = results[2] as List<AccommodationModel>;
          _localFoods = results[3] as List<LocalFoodModel>;
          _isLoadingTravelData = false;
        });
        debugPrint(
          '[HalamanDestinationDetail] Destination ID $destId (${_getEffectiveTitle()}): '
          '${_attractions.length} attractions, ${_accommodations.length} accommodations, ${_localFoods.length} local foods loaded.',
        );
      }
    } catch (e) {
      debugPrint('[HalamanDestinationDetail] Error fetching travel data: $e');
      if (mounted) {
        setState(() {
          _isLoadingTravelData = false;
        });
      }
    }
  }

  String _getEffectiveTitle() {
    if (_loadedDestination != null && _loadedDestination!.name.isNotEmpty) {
      return _loadedDestination!.location.isNotEmpty
          ? '${_loadedDestination!.name}, ${_loadedDestination!.location}'
          : _loadedDestination!.name;
    }
    return widget.destinationTitle;
  }

  String _getEffectiveCategory() {
    if (_loadedDestination != null && _loadedDestination!.category.isNotEmpty) {
      return _loadedDestination!.category;
    }
    return widget.categoryTag;
  }

  String _getEffectiveImage() {
    if (_loadedDestination != null && _loadedDestination!.image.isNotEmpty) {
      return _loadedDestination!.image;
    }
    return widget.imageUrl;
  }

  String _getEffectiveRating() {
    if (_loadedDestination != null && _loadedDestination!.rating > 0) {
      return _loadedDestination!.rating.toString();
    }
    return widget.rating;
  }

  String _getEffectivePrice() {
    if (_loadedDestination != null && _loadedDestination!.estimatedBudget > 0) {
      return 'Rp ${(_loadedDestination!.estimatedBudget / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    }
    return widget.pricePerDay;
  }

  String _getEffectiveDescription() {
    if (_loadedDestination != null &&
        _loadedDestination!.description.isNotEmpty) {
      return _loadedDestination!.description;
    }
    return widget.description;
  }

  String? _getShortDescription() {
    if (_loadedDestination?.shortDescription != null &&
        _loadedDestination!.shortDescription!.trim().isNotEmpty) {
      return _loadedDestination!.shortDescription!.trim();
    }
    if (widget.destination?.shortDescription != null &&
        widget.destination!.shortDescription!.trim().isNotEmpty) {
      return widget.destination!.shortDescription!.trim();
    }
    return null;
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

                const SizedBox(height: 20),

                // Content Padding Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Penjelasan Singkat & Deskripsi
                      _buildDescriptionSection(),

                      const SizedBox(height: 28),

                      // 4. Hal Menarik
                      _buildHighlightsSection(),

                      const SizedBox(height: 28),

                      // 5. Tempat Menginap
                      _buildAccommodationsSection(),

                      const SizedBox(height: 28),

                      // 6. Kuliner Lokal
                      _buildCulinarySection(),

                      const SizedBox(height: 28),

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
            child: SafeArea(
              top: false,
              child: _buildFloatingActionButton(),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Hero Image Banner Widget
  Widget _buildHeroBanner() {
    final title = _getEffectiveTitle();
    final category = _getEffectiveCategory();
    final image = _getEffectiveImage();

    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image with Fallback
          Positioned.fill(
            child: Image.network(
              image,
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

          // Top Action Controls (Back Button & Favorite Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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

                    Row(
                      children: [
                        // Love Favorite Button
                        GestureDetector(
                          onTap: () async {
                            final destId = _getDestinationId();
                            final titleParts = title.split(',');
                            final name = titleParts.isNotEmpty
                                ? titleParts[0].trim()
                                : title;
                            final location = titleParts.length > 1
                                ? titleParts.sublist(1).join(',').trim()
                                : title;
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              if (_isFavorited) {
                                if (destId != null) {
                                  await SavedPlacesService.instance.removeFavorite(
                                    destId,
                                  );
                                }
                                if (mounted) {
                                  setState(() {
                                    _isFavorited = false;
                                  });
                                  messenger.removeCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$name dihapus dari Saved Places',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } else {
                                final destModel = _loadedDestination ??
                                    widget.destination ??
                                    DestinationModel(
                                      id: destId,
                                      name: name,
                                      location: location,
                                      description: _getEffectiveDescription(),
                                      image: image,
                                      category: category,
                                      rating:
                                          double.tryParse(_getEffectiveRating()) ??
                                              4.8,
                                      shortDescription: _getShortDescription(),
                                    );

                                await SavedPlacesService.instance.addFavorite(
                                  destModel,
                                );

                                if (mounted) {
                                  setState(() {
                                    _isFavorited = true;
                                  });
                                }

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HalamanSavedPlaces(user: widget.user),
                                    ),
                                  ).then((_) => _checkFavoriteStatus());
                                }
                              }
                            } catch (_) {}
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
                              _isFavorited
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorited
                                  ? Colors.redAccent
                                  : Colors.white,
                              size: 22,
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
                    category.toUpperCase(),
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
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
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
    final rating = _getEffectiveRating();
    final price = _getEffectivePrice();

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
              value: rating,
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
              value: price,
              label: 'Estimasi Biaya',
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
            mainAxisSize: MainAxisSize.min,
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

  // 3. Penjelasan Singkat & Deskripsi Section
  Widget _buildDescriptionSection() {
    final shortDesc = _getShortDescription();
    final fullDesc = _getEffectiveDescription();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Penjelasan Singkat Card jika ada
        if (shortDesc != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primaryBlue.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Singkat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shortDesc,
                        style: const TextStyle(
                          color: textNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Narasi Deskripsi Utama
        Text(
          fullDesc,
          style: const TextStyle(
            color: Color(0xFF434655),
            fontSize: 15,
            height: 1.6,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 4. Hal Menarik Section Widget
  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
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
            ),
            if (_attractions.length > 3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_attractions.length} Tempat',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Content
        if (_isLoadingTravelData)
          _buildAttractionSkeleton()
        else if (_attractions.isNotEmpty)
          Column(
            children: _attractions.map((item) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Image with Fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          item.image,
                          width: 95,
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 95,
                            height: 95,
                            color: primaryBlue.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.landscape_rounded,
                              color: primaryBlue,
                              size: 32,
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
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.explore_rounded,
                                        size: 13,
                                        color: primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (item.estimatedCost > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rp ${item.estimatedCost ~/ 1000}k',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
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
          )
        else
          // Fallback static highlights
          Column(
            children: (widget.highlights ?? _defaultHighlights).map((item) {
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          (item['imageUrl'] as String?) ?? '',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['title'] as String?) ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (item['description'] as String?) ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textSlate,
                              ),
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
        if (_isLoadingTravelData)
          _buildAccommodationSkeleton()
        else if (_accommodations.isNotEmpty)
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _accommodations.length,
              itemBuilder: (context, index) {
                final item = _accommodations[index];
                return Container(
                  width: 240,
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
                              item.image,
                              width: 240,
                              height: 145,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 240,
                                height: 145,
                                color: secondaryColor.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.hotel_rounded,
                                  color: secondaryColor,
                                  size: 36,
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
                                color: Colors.white.withValues(alpha: 0.95),
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
                                    item.rating > 0
                                        ? item.rating.toString()
                                        : '4.8',
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
                        item.name,
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
                        '${item.type} • ${item.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSlate,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.priceRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          // Fallback static accommodations
          SizedBox(
            height: 235,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: (widget.accommodations ?? _defaultAccommodations).length,
              itemBuilder: (context, index) {
                final item =
                    (widget.accommodations ?? _defaultAccommodations)[index];
                return Container(
                  width: 230,
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          (item['imageUrl'] as String?) ?? '',
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
                      const SizedBox(height: 10),
                      Text(
                        (item['title'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
                        ),
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

        // Local foods list
        if (_isLoadingTravelData)
          _buildCulinarySkeleton()
        else if (_localFoods.isNotEmpty)
          Column(
            children: _localFoods.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Avatar with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tertiaryOrange.withValues(alpha: 0.2),
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            item.image,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 76,
                              height: 76,
                              color: tertiaryOrange.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: tertiaryOrange,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Dish Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.place_outlined,
                                        size: 13,
                                        color: textSlate,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: textSlate,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tertiaryOrange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.priceRange,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: tertiaryOrange,
                                    ),
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
          )
        else
          // Fallback single culinary card
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
                ClipOval(
                  child: Image.network(
                    ((widget.culinary ?? _defaultCulinary)['imageUrl'] as String?) ??
                        '',
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ((widget.culinary ?? _defaultCulinary)['title'] as String?) ??
                            '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textNavy,
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
    final title = _getEffectiveTitle();

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
                  right: 14,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 14,
                          color: primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                            ),
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

  // Skeletons / Loading State Helpers
  Widget _buildAttractionSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAccommodationSkeleton() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 230,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: surfaceCard,
              borderRadius: BorderRadius.circular(18),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCulinarySkeleton() {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceCard,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }

  static const List<Map<String, dynamic>> _defaultHighlights = [
    {
      'title': 'Terasering Tegalalang',
      'description':
          'Jelajahi keindahan sawah berundak ikonik yang menawarkan pemandangan spektakuler.',
      'category': 'Aktivitas Alam',
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
    },
    {
      'title': 'Pura Uluwatu',
      'description':
          'Saksikan matahari terbenam magis dengan latar belakang pura kuno di atas tebing.',
      'category': 'Budaya & Sejarah',
      'imageUrl':
          'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=800&auto=format&fit=crop',
    },
  ];

  static const List<Map<String, dynamic>> _defaultAccommodations = [
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

  static const Map<String, dynamic> _defaultCulinary = {
    'title': 'Nasi Campur Bali',
    'description':
        'Perpaduan lauk pauk kaya rempah khas dewata dalam satu piring.',
    'imageUrl':
        'https://images.unsplash.com/photo-1596450514735-3769c3a37651?q=80&w=800&auto=format&fit=crop',
  };
}

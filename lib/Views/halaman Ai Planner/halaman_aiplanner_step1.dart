import 'package:flutter/material.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import '../../Widgets/custom_floating_nav_bar.dart';
import '../halaman profile/halaman_profil.dart';
import '../halaman_utama.dart';
import 'halaman_aiplanner_step2.dart' as step2;

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final bool isEmbeddedInShell;
  final ValueChanged<int>? onSwitchTab;
  final String? initialDestination;
  final DestinationModel? initialDestinationModel;
  final DateTime? initialDepartureDate;
  final DateTime? initialReturnDate;
  final bool? initialIsFlexible;
  final String? initialCompanion;
  final int? initialPeopleCount;
  final bool? initialHasChildren;
  final bool? initialHasElderly;
  final int? initialDurationDays;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.isEmbeddedInShell = false,
    this.onSwitchTab,
    this.initialDestination,
    this.initialDestinationModel,
    this.initialDepartureDate,
    this.initialReturnDate,
    this.initialIsFlexible,
    this.initialCompanion,
    this.initialPeopleCount,
    this.initialHasChildren,
    this.initialHasElderly,
    this.initialDurationDays,
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();

  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isFlexibleDate = false;
  int _durationDays = 5;

  String _selectedCompanion = 'Solo';
  int _peopleCount = 4;
  bool _hasChildren = true;
  bool _hasElderly = false;

  final List<String> _companions = ['Solo', 'Pasangan', 'Keluarga', 'Grup'];
  final List<int> _durationOptions = [3, 5, 7, 10];

  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _filteredDestinations = [];
  DestinationModel? _selectedDestinationModel;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _destinationController.text = widget.initialDestination ?? '';
    _selectedDestinationModel = widget.initialDestinationModel;
    _departureDate = widget.initialDepartureDate;
    _returnDate = widget.initialReturnDate;
    _isFlexibleDate = widget.initialIsFlexible ?? false;
    _durationDays = widget.initialDurationDays ?? 5;
    _selectedCompanion = widget.initialCompanion ?? 'Solo';
    _peopleCount = widget.initialPeopleCount ?? 4;
    _hasChildren = widget.initialHasChildren ?? true;
    _hasElderly = widget.initialHasElderly ?? false;

    _destinationController.addListener(_onDestinationQueryChanged);
    _destinationFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _destinationFocusNode.hasFocus &&
            _filteredDestinations.isNotEmpty;
      });
    });

    _loadDestinationsFromFirestore();
  }

  @override
  void dispose() {
    _destinationController.removeListener(_onDestinationQueryChanged);
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDestinationsFromFirestore() async {
    try {
      final destinations = await DestinationService.instance.getDestinations();
      if (mounted) {
        setState(() {
          _allDestinations = destinations;
          _filteredDestinations = destinations;

          if (_selectedDestinationModel == null && destinations.isNotEmpty) {
            if (_destinationController.text.isNotEmpty) {
              final match = destinations.firstWhere(
                (d) => d.name.toLowerCase().contains(
                      _destinationController.text.trim().toLowerCase(),
                    ),
                orElse: () => destinations.first,
              );
              _selectedDestinationModel = match;
            } else {
              _selectedDestinationModel = destinations.first;
            }
          }
        });
      }
    } catch (_) {}
  }

  void _onDestinationQueryChanged() {
    final query = _destinationController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDestinations = _allDestinations;
      } else {
        _filteredDestinations = _allDestinations.where((d) {
          final name = d.name.toLowerCase();
          final loc = d.location.toLowerCase();
          return name.contains(query) || loc.contains(query);
        }).toList();
      }
      _showSuggestions = _destinationFocusNode.hasFocus &&
          _filteredDestinations.isNotEmpty;

      if (query.isNotEmpty && _filteredDestinations.isNotEmpty) {
        final exact = _filteredDestinations.firstWhere(
          (d) => d.name.toLowerCase() == query,
          orElse: () => _filteredDestinations.first,
        );
        _selectedDestinationModel = exact;
      }
    });
  }

  void _selectDestinationFromList(DestinationModel destination) {
    setState(() {
      _selectedDestinationModel = destination;
      _destinationController.text = destination.name;
      _showSuggestions = false;
    });
    _destinationFocusNode.unfocus();
  }

  void _giveRandomRecommendation() {
    if (_allDestinations.isNotEmpty) {
      final popular = List<DestinationModel>.from(_allDestinations);
      popular.sort((a, b) => b.rating.compareTo(a.rating));
      final picked = (popular..shuffle()).first;
      _selectDestinationFromList(picked);
    }
  }

  Future<void> _selectDepartureDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004AC6),
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
        _isFlexibleDate = false;
        if (_returnDate != null && _returnDate!.isBefore(_departureDate!)) {
          _returnDate = _departureDate!.add(Duration(days: _durationDays));
        } else {
          _returnDate ??= _departureDate!.add(Duration(days: _durationDays));
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime initial = _departureDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? initial.add(Duration(days: _durationDays)),
      firstDate: initial,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004AC6),
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
        _isFlexibleDate = false;
        if (_departureDate != null) {
          final diff = _returnDate!.difference(_departureDate!).inDays + 1;
          if (diff > 0) _durationDays = diff;
        }
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

  String _getDayName(DateTime? date) {
    if (date == null) return "-";
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }

  void _onContinue() {
    final dest = _destinationController.text.trim().isNotEmpty
        ? _destinationController.text.trim()
        : (_selectedDestinationModel?.name ?? '');

    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Silakan masukkan atau pilih destinasi liburan."),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    String formattedDates = "Tanggal masih fleksibel ($_durationDays Hari)";
    if (!_isFlexibleDate && _departureDate != null) {
      if (_returnDate != null) {
        final days = _returnDate!.difference(_departureDate!).inDays + 1;
        formattedDates =
            "${_formatDate(_departureDate)} - ${_formatDate(_returnDate)} ($days Hari)";
      } else {
        formattedDates = "${_formatDate(_departureDate)} ($_durationDays Hari)";
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => step2.HalamanAiPlanner(
          user: widget.user,
          destination: dest,
          destinationModel: _selectedDestinationModel,
          dates: formattedDates,
          departureDate: _departureDate,
          returnDate: _returnDate,
          isFlexibleDate: _isFlexibleDate,
          durationDays: _durationDays,
          companion: _selectedCompanion,
          peopleCount: _peopleCount,
          hasChildren: _hasChildren,
          hasElderly: _hasElderly,
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == 2) return;

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
    const Color primaryFixed = Color(0xFFDBE1FF);
    const Color onPrimaryFixed = Color(0xFF00174B);
    const Color warmYellow = Color(0xFFFDB813);

    final previewModel = _selectedDestinationModel ??
        (_allDestinations.isNotEmpty ? _allDestinations.first : null);

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // App Bar matching Stitch Header
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
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
                    if (widget.onSwitchTab != null) {
                      widget.onSwitchTab!(4);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HalamanProfil(user: widget.user),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator (4 Segments, 1 filled)
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
                  const SizedBox(height: 20),

                  // Intro & Step Label
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
                          Icons.explore_rounded,
                          size: 14,
                          color: onPrimaryFixed,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "STEP 1 OF 4",
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
                    "Mau liburan ke mana?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Kasih tahu aku rencana dasarnya, sisanya biar aku yang bantu susun.",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSlate,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Destination Section Header
                  const Text(
                    "Tujuan Utama",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Destination Search Box
                  Container(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            focusNode: _destinationFocusNode,
                            style: const TextStyle(
                              fontSize: 15,
                              color: textNavy,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Cari destinasi...",
                              hintStyle: TextStyle(
                                color: Color(0x9964748B),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_destinationController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.cancel_rounded,
                                color: textSlate, size: 20),
                            onPressed: () {
                              _destinationController.clear();
                              setState(() {
                                _selectedDestinationModel = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  // Autocomplete Suggestions List from Firestore
                  if (_showSuggestions && _filteredDestinations.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _filteredDestinations.length > 5
                              ? 5
                              : _filteredDestinations.length,
                          separatorBuilder: (context, idx) =>
                              const Divider(height: 1, color: surfaceVariant),
                          itemBuilder: (context, idx) {
                            final dest = _filteredDestinations[idx];
                            return ListTile(
                              dense: true,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  dest.image,
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 38,
                                    height: 38,
                                    color: surfaceContainer,
                                    child: const Icon(Icons.image,
                                        size: 18, color: textSlate),
                                  ),
                                ),
                              ),
                              title: Text(
                                dest.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textNavy,
                                ),
                              ),
                              subtitle: Text(
                                dest.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textSlate,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 16, color: warmYellow),
                                  const SizedBox(width: 2),
                                  Text(
                                    dest.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _selectDestinationFromList(dest),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // AI Recommendation Chip
                  GestureDetector(
                    onTap: _giveRandomRecommendation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryFixed.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: primaryBlue,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Belum tahu tujuannya? Kasih rekomendasi",
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Destination Visual Snippet (from Firestore)
                  if (previewModel != null)
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                previewModel.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: primaryBlue,
                                  child: const Center(
                                    child: Icon(Icons.landscape_rounded,
                                        color: Colors.white, size: 36),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      textNavy.withValues(alpha: 0.85),
                                      textNavy.withValues(alpha: 0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: warmYellow,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        previewModel.category.isNotEmpty
                                            ? previewModel.category.toUpperCase()
                                            : "DESTINASI POPULER",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: warmYellow,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    previewModel.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    previewModel.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Dates & Duration Card
                  Container(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: surfaceContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: primaryBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Waktu Perjalanan",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textNavy,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    Text(
                                      "Atur tanggal atau durasi",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                        const SizedBox(height: 12),

                        // Flexible Status Label
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Tanggal masih fleksibel",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isFlexibleDate ? "Aktif" : "Nonaktif",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _isFlexibleDate
                                        ? primaryBlue
                                        : textSlate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Duration Chips
                        const Text(
                          "BERAPA LAMA LIBURANNYA?",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSlate,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _durationOptions.map((days) {
                            final isSelected = _durationDays == days;
                            final label =
                                days == 10 ? "10+ hari" : "$days hari";
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _durationDays = days;
                                      if (_departureDate != null) {
                                        _returnDate = _departureDate!
                                            .add(Duration(days: days));
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryBlue
                                          : surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : textNavy,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Date Pickers
                        Row(
                          children: [
                            // Berangkat
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectDepartureDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.flight_takeoff_rounded,
                                            size: 16,
                                            color: textSlate,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "BERANGKAT",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: textSlate,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatDate(_departureDate),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _getDayName(_departureDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Pulang
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectReturnDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.flight_land_rounded,
                                            size: 16,
                                            color: textSlate,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "PULANG",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: textSlate,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatDate(_returnDate),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _getDayName(_returnDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: textSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Companions Section
                  Container(
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Siapa yang ikut?",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                Text(
                                  "Kami sesuaikan ritme dan rekomendasi spot",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSlate,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.group_rounded,
                                color: textSlate, size: 22),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 4 Pill Companion Selector
                        Row(
                          children: _companions.map((companion) {
                            final isSelected = _selectedCompanion == companion;
                            IconData iconData;
                            switch (companion) {
                              case 'Solo':
                                iconData = Icons.person_rounded;
                                break;
                              case 'Pasangan':
                                iconData = Icons.favorite_rounded;
                                break;
                              case 'Keluarga':
                                iconData = Icons.family_restroom_rounded;
                                break;
                              case 'Grup':
                              default:
                                iconData = Icons.groups_rounded;
                                break;
                            }

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCompanion = companion;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryBlue
                                          : surfaceLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          iconData,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.white
                                              : textSlate,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          companion,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : textNavy,
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

                        // Sub-options for Keluarga / Grup
                        if (_selectedCompanion == 'Keluarga' ||
                            _selectedCompanion == 'Grup') ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surfaceLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Berapa orang totalnya?",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: textNavy,
                                          ),
                                        ),
                                        Text(
                                          "Dewasa, anak, atau bayi",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_rounded,
                                                size: 16),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28),
                                            onPressed: () {
                                              if (_peopleCount > 1) {
                                                setState(() {
                                                  _peopleCount--;
                                                });
                                              }
                                            },
                                          ),
                                          Text(
                                            "$_peopleCount Orang",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: textNavy,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_rounded,
                                                size: 16),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28),
                                            onPressed: () {
                                              if (_peopleCount < 30) {
                                                setState(() {
                                                  _peopleCount++;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Child Toggle
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.child_care_rounded,
                                            size: 18, color: textSlate),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Ada anak-anak?",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: textNavy,
                                              ),
                                            ),
                                            Text(
                                              "< 12 tahun (prioritaskan aktivitas aman)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textSlate,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _hasChildren,
                                      activeThumbColor: primaryBlue,
                                      onChanged: (val) {
                                        setState(() {
                                          _hasChildren = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                // Elderly Toggle
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.elderly_rounded,
                                            size: 18, color: textSlate),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Ada lansia?",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: textNavy,
                                              ),
                                            ),
                                            Text(
                                              "> 60 tahun (jalur landai)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textSlate,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _hasElderly,
                                      activeThumbColor: primaryBlue,
                                      onChanged: (val) {
                                        setState(() {
                                          _hasElderly = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bottom Action Button ("Lanjut")
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isEmbeddedInShell
          ? null
          : CustomFloatingNavBar(
              selectedIndex: 2,
              onDestinationSelected: _onNavTapped,
            ),
    );
  }
}

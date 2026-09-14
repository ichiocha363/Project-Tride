import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/trip_model.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Services/destination_service.dart';
import 'package:project_tride/Services/itinerary_planner_service.dart';
import 'package:project_tride/Services/trip_service.dart';
import '../halaman profile/halaman_profil.dart';
import '../halaman_utama.dart';

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
  final String budget;
  final int? budgetCeiling;
  final String pace;
  final String accommodation;
  final List<String>? accommodationsList;

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
    this.styles = const ['Photography', 'Nature'],
    this.budget = 'Menengah',
    this.budgetCeiling = 7500000,
    this.pace = 'Seimbang',
    this.accommodation = 'Hotel (Utama)',
    this.accommodationsList,
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final TextEditingController _specialNeedsController = TextEditingController();
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedItinerary;

  late String _destination;
  DestinationModel? _destinationModel;
  late String _dates;
  DateTime? _departureDate;
  DateTime? _returnDate;
  late int _durationDays;
  late String _companion;
  late int _peopleCount;
  late bool _hasChildren;
  late bool _hasElderly;
  late List<String> _styles;
  late String _budget;
  late int _budgetCeiling;
  late String _pace;
  late String _accommodation;
  late List<String> _accommodationsList;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _destinationModel = widget.destinationModel;
    _dates = widget.dates;
    _departureDate = widget.departureDate;
    _returnDate = widget.returnDate;
    _durationDays = widget.durationDays;
    _companion = widget.companion;
    _peopleCount = widget.peopleCount;
    _hasChildren = widget.hasChildren;
    _hasElderly = widget.hasElderly;
    _styles = List<String>.from(widget.styles);
    _budget = widget.budget;
    _budgetCeiling = widget.budgetCeiling ?? 7500000;
    _pace = widget.pace;
    _accommodation = widget.accommodation;
    _accommodationsList = widget.accommodationsList != null
        ? List<String>.from(widget.accommodationsList!)
        : [_accommodation];

    _fetchDestinationDetailsIfNeeded();
  }

  @override
  void dispose() {
    _specialNeedsController.dispose();
    super.dispose();
  }

  Future<void> _fetchDestinationDetailsIfNeeded() async {
    if (_destinationModel == null) {
      try {
        final all = await DestinationService.instance.getDestinations();
        if (all.isNotEmpty && mounted) {
          final match = all.firstWhere(
            (d) => d.name.toLowerCase() == _destination.toLowerCase(),
            orElse: () => all.first,
          );
          setState(() {
            _destinationModel = match;
          });
        }
      } catch (_) {}
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getPeopleSubtitle() {
    final List<String> details = [];
    if (_companion == 'Keluarga' || _companion == 'Grup') {
      details.add(_companion);
      if (_hasChildren) details.add("ada anak-anak");
      if (_hasElderly) details.add("ada lansia");
    } else {
      details.add(_companion);
    }
    return details.join(', ');
  }

  void _editDestination() {
    final controller = TextEditingController(text: _destination);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
              const Text(
                "Ubah Destinasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Masukkan nama destinasi...",
                  prefixIcon: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF004AC6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty) {
                      setState(() {
                        _destination = val;
                      });
                      _fetchDestinationDetailsIfNeeded();
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editDates() async {
    final DateTime now = DateTime.now();
    final DateTime initialStart = _departureDate ?? DateTime(now.year, 9, 12);
    final DateTime initialEnd = _returnDate ?? DateTime(now.year, 9, 16);

    final DateTime firstDateAllowed =
        initialStart.isBefore(now) ? initialStart : now;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd.isBefore(initialStart)
            ? initialStart.add(const Duration(days: 4))
            : initialEnd,
      ),
      firstDate: firstDateAllowed,
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
      final startStr = "${picked.start.day} ${months[picked.start.month - 1]}";
      final endStr =
          "${picked.end.day} ${months[picked.end.month - 1]} ${picked.end.year}";
      final days = picked.duration.inDays + 1;

      setState(() {
        _departureDate = picked.start;
        _returnDate = picked.end;
        _durationDays = days;
        _dates = "$startStr - $endStr ($days Hari)";
      });
    }
  }

  void _editStyles() {
    final selectedSet = Set<String>.from(_styles);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Gaya Perjalanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      'Photography',
                      'Nature',
                      'Fotografi',
                      'Kuliner',
                      'Alam',
                      'Petualangan',
                      'Budaya',
                      'Relaksasi'
                    ].map((style) {
                      final isSelected = selectedSet.contains(style);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(style),
                        selectedColor: const Color(0xFF004AC6),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              if (selectedSet.length < 3) {
                                selectedSet.add(style);
                              }
                            } else {
                              selectedSet.remove(style);
                            }
                          });
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
                        if (selectedSet.isNotEmpty) {
                          setState(() {
                            _styles = selectedSet.toList();
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
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

  void _editBudget() {
    String tempBudget = _budget;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Level Budget",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['Hemat', 'Menengah', 'Mewah'].map((b) {
                    final isSelected = tempBudget == b;
                    return ListTile(
                      title: Text(
                        b,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF004AC6)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? const Color(0xFF004AC6)
                            : const Color(0xFF64748B),
                      ),
                      onTap: () {
                        setModalState(() {
                          tempBudget = b;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _budget = tempBudget;
                          if (_budget == 'Hemat') {
                            _budgetCeiling = 3000000;
                          } else if (_budget == 'Mewah') {
                            _budgetCeiling = 15000000;
                          } else {
                            _budgetCeiling = 7500000;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
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

  void _editPace() {
    String tempPace = _pace;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Ritme Perjalanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['Santai', 'Seimbang', 'Padat'].map((p) {
                    final isSelected = tempPace == p;
                    return ListTile(
                      title: Text(
                        p,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF004AC6)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? const Color(0xFF004AC6)
                            : const Color(0xFF64748B),
                      ),
                      onTap: () {
                        setModalState(() {
                          tempPace = p;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _pace = tempPace;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
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

  void _editAccommodation() {
    final selectedAcc = Set<String>.from(_accommodationsList);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ubah Preferensi Akomodasi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['Hotel (Utama)', 'Hotel', 'Hostel', 'Homestay', 'Villa'].map((acc) {
                    final isSelected = selectedAcc.contains(acc);
                    return CheckboxListTile(
                      title: Text(
                        acc,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: isSelected,
                      activeColor: const Color(0xFF004AC6),
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selectedAcc.add(acc);
                          } else if (selectedAcc.length > 1) {
                            selectedAcc.remove(acc);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _accommodationsList = selectedAcc.toList();
                          _accommodation = _accommodationsList.join(' & ');
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
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

  void _generateItinerary() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final itinerary = await ItineraryPlannerService.instance.generateItinerary(
        destination: _destination,
        durationDays: _durationDays,
        dates: _dates,
        companion: _companion,
        peopleCount: _peopleCount,
        hasChildren: _hasChildren,
        hasElderly: _hasElderly,
        styles: _styles,
        budget: _budget,
        budgetCeiling: _budgetCeiling,
        pace: _pace,
        accommodation: _accommodation,
        specialNeeds: _specialNeedsController.text,
      );

      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _generatedItinerary = itinerary;
      });

      _showItineraryDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membuat itinerary AI. Coba lagi.\nDetail: $e"),
          backgroundColor: const Color(0xFFBA1A1A),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showItineraryDialog() {
    if (_generatedItinerary == null) return;

    bool isSavingTrip = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004AC6).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF004AC6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _generatedItinerary!['isAiGenerated'] == true
                                  ? "✨ Dynamic Gemini AI Itinerary"
                                  : "📍 Local TRIDE Recommendation Engine",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004AC6),
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              _generatedItinerary!['destination'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags (Wrap to prevent pixel overflow)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          _generatedItinerary!['isAiGenerated'] == true
                              ? Icons.psychology_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: const Color(0xFF004AC6),
                        ),
                        label: Text(
                          _generatedItinerary!['source'] ?? 'Gemini AI Engine',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF004AC6),
                          ),
                        ),
                        backgroundColor: const Color(0xFFE8EFFD),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.timer_outlined, size: 16),
                        label: Text(_generatedItinerary!['duration']),
                        backgroundColor: const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.style_outlined, size: 16),
                        label: Text(
                          _generatedItinerary!['styles'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        backgroundColor: const Color(0xFFDBE1FF),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Timeline List
                  Expanded(
                    child: ListView.builder(
                      itemCount: (_generatedItinerary!['schedule'] as List).length,
                      itemBuilder: (context, index) {
                        final dayItem = _generatedItinerary!['schedule'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GFAccordion(
                            titleChild: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF004AC6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dayItem['day'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dayItem['title'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            contentChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                ...((dayItem['activities'] as List).map(
                                  (act) {
                                    final Map<String, dynamic> actMap = act is Map
                                        ? Map<String, dynamic>.from(act)
                                        : {
                                            'time': 'Flexi Time',
                                            'location': _destination,
                                            'title': act.toString(),
                                            'description': act.toString(),
                                            'tips': null,
                                          };

                                    final timeStr = actMap['time']?.toString() ?? 'Pagi';
                                    final locationStr = actMap['location']?.toString() ?? _destination;
                                    final titleStr = actMap['title']?.toString() ?? actMap['description']?.toString() ?? '';
                                    final descStr = actMap['description']?.toString() ?? titleStr;
                                    final tipsStr = actMap['tips']?.toString();

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header Badges: Time & Location
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDBE1FF),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF004AC6)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      timeStr,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF004AC6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFFBA1A1A)),
                                                    const SizedBox(width: 3),
                                                    Expanded(
                                                      child: Text(
                                                        locationStr,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF0F172A),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Activity Title
                                          Text(
                                            titleStr,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          if (descStr != titleStr && descStr.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              descStr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF475569),
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                          if (tipsStr != null && tipsStr.trim().isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFFBEB),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: const Color(0xFFFDE68A)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.lightbulb_rounded, size: 13, color: Color(0xFFD97706)),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      tipsStr,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF92400E),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                )),
                              ],
                            ),
                            collapsedIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF004AC6),
                            ),
                            expandedIcon: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Color(0xFF004AC6),
                            ),
                            titlePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Action button (Save Trip via TripService)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSavingTrip
                          ? null
                          : () async {
                              setSheetState(() {
                                isSavingTrip = true;
                              });

                              try {
                                final now = DateTime.now();
                                final startDt =
                                    _departureDate ?? now.add(const Duration(days: 7));
                                final endDt =
                                    _returnDate ?? startDt.add(Duration(days: _durationDays));
                                final startStr =
                                    "${startDt.year.toString().padLeft(4, '0')}-${startDt.month.toString().padLeft(2, '0')}-${startDt.day.toString().padLeft(2, '0')}";
                                final endStr =
                                    "${endDt.year.toString().padLeft(4, '0')}-${endDt.month.toString().padLeft(2, '0')}-${endDt.day.toString().padLeft(2, '0')}";

                                final newTrip = TripModel(
                                  userId: widget.user?.id?.toString() ??
                                      TripService.instance.currentUserId ??
                                      '',
                                  tripName: "Trip ke $_destination",
                                  destinationId: _destinationModel?.id,
                                  destinationName: _destination,
                                  destinationLocation: _destinationModel?.location,
                                  imageUrl: _destinationModel?.image,
                                  startDate: startStr,
                                  endDate: endStr,
                                  budget: _budgetCeiling,
                                  travelStyle: _styles.join(', '),
                                  notes:
                                      "Akomodasi: $_accommodation · Ritme: $_pace · Teman: $_companion ($_peopleCount Orang)",
                                  status: 'upcoming',
                                  createdAt: DateTime.now().toIso8601String(),
                                  itineraryDays: _generatedItinerary != null &&
                                          _generatedItinerary!['schedule'] is List
                                      ? List<Map<String, dynamic>>.from(
                                          (_generatedItinerary!['schedule'] as List).map(
                                            (e) => Map<String, dynamic>.from(e as Map),
                                          ),
                                        )
                                      : null,
                                );

                                final saved = await TripService.instance.createTrip(newTrip);

                                if (saved == null) {
                                  throw Exception("Gagal menyimpan trip ke Firestore.");
                                }

                                if (modalContext.mounted) {
                                  Navigator.pop(modalContext);

                                  // Direct navigation to Home, clearing AI Planner navigation stack
                                  Navigator.pushAndRemoveUntil(
                                    modalContext,
                                    MaterialPageRoute(
                                      builder: (context) => HalamanUtama(
                                        user: widget.user,
                                        initialTab: 0,
                                      ),
                                    ),
                                    (route) => false,
                                  );

                                  ScaffoldMessenger.of(modalContext).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.bookmark_added_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Rencana Perjalanan berhasil disimpan!"),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF3E9C5D),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (modalContext.mounted) {
                                  setSheetState(() {
                                    isSavingTrip = false;
                                  });

                                  ScaffoldMessenger.of(modalContext).showSnackBar(
                                    SnackBar(
                                      content: Text("Gagal menyimpan trip. Coba lagi.\nDetail: $e"),
                                      backgroundColor: const Color(0xFFBA1A1A),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF004AC6).withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSavingTrip
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Menyimpan...",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Text(
                              "Simpan Rencana Perjalanan",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    const Color bgCloud = Color(0xFFF8FAFC);
    const Color textNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textSlate = Color(0xFF64748B);
    const Color surfaceContainer = Color(0xFFEDEDF9);
    const Color surfaceLow = Color(0xFFF3F3FE);
    const Color sandBeige = Color(0xFFEDE0CB);
    const Color warmYellow = Color(0xFFFDB813);
    const Color naturalGreen = Color(0xFF3E9C5D);
    const Color primaryFixed = Color(0xFFDBE1FF);
    const Color onPrimaryFixed = Color(0xFF00174B);

    final imageUrl = _destinationModel?.image ??
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=600&auto=format&fit=crop';

    final ticketCode = "#TRIDE-${_destination.split(' ').first.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')}25";

    final teaserTitle = _destination.split(',').first.trim();

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
                  // 4-Segment Progress Bar (All 4 active)
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
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
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
                          Icons.done_all_rounded,
                          size: 14,
                          color: onPrimaryFixed,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "STEP 4 OF 4",
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
                    "Tambahkan detail",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ada kebutuhan khusus? Lalu cek lagi sebelum aku buatkan itinerary-nya.",
                    style: TextStyle(
                      fontSize: 13,
                      color: textSlate,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Destination Teaser Thumbnail Card (Dynamic Image)
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
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
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "TUJUAN IMPIAN",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: sandBeige,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          teaserTitle,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.wb_sunny_rounded,
                                            color: warmYellow,
                                            size: 13,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Cerah 29°C",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                  ),

                  const SizedBox(height: 16),

                  // Section 1: Kebutuhan khusus (opsional)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note_rounded,
                              color: primaryBlue, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Kebutuhan khusus (opsional)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Maks. 250 karakter",
                        style: TextStyle(
                          fontSize: 11,
                          color: textSlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.all(10),
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
                      children: [
                        TextField(
                          controller: _specialNeedsController,
                          maxLines: 2,
                          maxLength: 250,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textNavy,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "Alergi kacang, pengguna kursi roda, atau ingin hindari jalanan berbatu...",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0x9964748B),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            counterText: "",
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 13, color: naturalGreen),
                                SizedBox(width: 4),
                                Text(
                                  "AI akan memprioritaskan preferensi ini",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: naturalGreen,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${_specialNeedsController.text.length}/250",
                              style: const TextStyle(
                                fontSize: 10,
                                color: textSlate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Ringkasan Perjalanan Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_rounded,
                              color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Ringkasan Perjalanan",
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
                        "LANGKAH 1 - 3",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSlate,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Master Summary Card (Boarding Pass Motif)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Card Header Strip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.explore_rounded,
                                    color: primaryBlue,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "TIKET RENCANA TRIDE",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textNavy,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryFixed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Siap Diramu",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: onPrimaryFixed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              // Destinasi
                              _buildSummaryRow(
                                icon: Icons.location_on_rounded,
                                iconColor: primaryBlue,
                                iconBgColor: surfaceContainer,
                                label: "Destinasi",
                                valueWidget: Text(
                                  _destination,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                onEdit: _editDestination,
                              ),
                              _buildDivider(),

                              // Tanggal
                              _buildSummaryRow(
                                icon: Icons.calendar_today_rounded,
                                iconColor: const Color(0xFF00668A),
                                iconBgColor: surfaceContainer,
                                label: "Tanggal",
                                valueWidget: Text(
                                  _dates,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                onEdit: _editDates,
                              ),
                              _buildDivider(),

                              // Jumlah Orang
                              _buildSummaryRow(
                                icon: Icons.group_rounded,
                                iconColor: const Color(0xFF943700),
                                iconBgColor: surfaceContainer,
                                label: "Jumlah Orang",
                                valueWidget: Text(
                                  "$_peopleCount Orang (${_getPeopleSubtitle()})",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                onEdit: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildDivider(),

                              // Gaya Perjalanan
                              _buildSummaryRow(
                                icon: Icons.stars_rounded,
                                iconColor: const Color(0xFFFB7A3C),
                                iconBgColor: surfaceContainer,
                                label: "Gaya Perjalanan",
                                valueWidget: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: _styles.map((style) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: surfaceContainer,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        style,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                onEdit: _editStyles,
                              ),
                              _buildDivider(),

                              // Budget
                              _buildSummaryRow(
                                icon: Icons.payments_rounded,
                                iconColor: naturalGreen,
                                iconBgColor: surfaceContainer,
                                label: "Budget",
                                valueWidget: Row(
                                  children: [
                                    Text(
                                      _budget,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sandBeige,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "Pagu Rp ${_formatCurrency(_budgetCeiling)}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onEdit: _editBudget,
                              ),
                              _buildDivider(),

                              // Pace
                              _buildSummaryRow(
                                icon: Icons.speed_rounded,
                                iconColor: warmYellow,
                                iconBgColor: surfaceContainer,
                                label: "Pace",
                                valueWidget: Text(
                                  _pace,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                onEdit: _editPace,
                              ),
                              _buildDivider(),

                              // Akomodasi
                              _buildSummaryRow(
                                icon: Icons.hotel_rounded,
                                iconColor: primaryBlue,
                                iconBgColor: surfaceContainer,
                                label: "Akomodasi",
                                valueWidget: Text(
                                  _accommodation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
                                ),
                                onEdit: _editAccommodation,
                              ),
                            ],
                          ),
                        ),

                        // Ticket Perforation Footer Accent
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: const BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: textSlate,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Estimasi optimasi rute 98.4%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textSlate,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                ticketCode,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Floating / Sticky CTA Button ("Buat Itinerary Saya")
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateItinerary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Meramu Perjalananmu...",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: warmYellow, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Buat Itinerary Saya",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      "AI Tride akan meracik jadwal, rute jalan, & estimasi budget.",
                      style: TextStyle(
                        fontSize: 10,
                        color: textSlate,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required Widget valueWidget,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget,
            ],
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF004AC6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Ubah",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004AC6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        color: Color(0xFFE1E2ED),
      ),
    );
  }
}

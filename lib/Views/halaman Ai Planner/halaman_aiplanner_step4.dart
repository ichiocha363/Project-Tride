import 'package:flutter/material.dart';
import 'package:project_tride/Models/user_model.dart';
import '../halaman beranda/halaman_beranda.dart';
import '../halaman budget/halaman_budget.dart';
import '../halaman explore/halaman_jelajah.dart';
import '../halaman profile/halaman_profil.dart';

class HalamanAiPlanner extends StatefulWidget {
  final UserModel? user;
  final String destination;
  final String dates;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String companion;
  final List<String> styles;
  final String budget;
  final String pace;
  final String accommodation;

  const HalamanAiPlanner({
    super.key,
    this.user,
    this.destination = 'Bali, Indonesia',
    this.dates = '12 - 16 Sep 2024 (5 Hari)',
    this.departureDate,
    this.returnDate,
    this.companion = 'Solo',
    this.styles = const ['Photography', 'Nature'],
    this.budget = 'Menengah',
    this.pace = 'Seimbang',
    this.accommodation = 'Hotel (Utama)',
  });

  @override
  State<HalamanAiPlanner> createState() => _HalamanAiPlannerState();
}

class _HalamanAiPlannerState extends State<HalamanAiPlanner> {
  final TextEditingController _specialNeedsController = TextEditingController();
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedItinerary;

  late String _destination;
  late String _dates;
  DateTime? _departureDate;
  DateTime? _returnDate;
  late List<String> _styles;
  late String _budget;
  late String _pace;
  late String _accommodation;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _dates = widget.dates;
    _departureDate = widget.departureDate;
    _returnDate = widget.returnDate;
    _styles = List<String>.from(widget.styles);
    _budget = widget.budget;
    _pace = widget.pace;
    _accommodation = widget.accommodation;
  }

  @override
  void dispose() {
    _specialNeedsController.dispose();
    super.dispose();
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

    final DateTime firstDateAllowed = initialStart.isBefore(now)
        ? initialStart
        : now;

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
                    children: ['Fotografi', 'Kuliner', 'Alam', 'Petualangan']
                        .map((style) {
                          final isSelected =
                              selectedSet.contains(style) ||
                              (style == 'Fotografi' &&
                                  selectedSet.contains('Photography')) ||
                              (style == 'Alam' &&
                                  selectedSet.contains('Nature'));
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
                                  selectedSet.add(style);
                                } else {
                                  selectedSet.remove(style);
                                  if (style == 'Fotografi') {
                                    selectedSet.remove('Photography');
                                  }
                                  if (style == 'Alam') {
                                    selectedSet.remove('Nature');
                                  }
                                }
                              });
                            },
                          );
                        })
                        .toList(),
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
                    return RadioListTile<String>(
                      title: Text(
                        b,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: b,
                      groupValue: tempBudget,
                      activeColor: const Color(0xFF004AC6),
                      onChanged: (val) {
                        setModalState(() {
                          tempBudget = val!;
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
                    return RadioListTile<String>(
                      title: Text(
                        p,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: p,
                      groupValue: tempPace,
                      activeColor: const Color(0xFF004AC6),
                      onChanged: (val) {
                        setModalState(() {
                          tempPace = val!;
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
    String tempAcc = _accommodation;
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
                  ...['Hotel (Utama)', 'Hostel', 'Homestay', 'Villa'].map((
                    acc,
                  ) {
                    return RadioListTile<String>(
                      title: Text(
                        acc,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: acc,
                      groupValue: tempAcc,
                      activeColor: const Color(0xFF004AC6),
                      onChanged: (val) {
                        setModalState(() {
                          tempAcc = val!;
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
                          _accommodation = tempAcc;
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

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final stylesText = _styles.join(' & ');

    setState(() {
      _isGenerating = false;
      _generatedItinerary = {
        'destination': _destination,
        'duration': '5 Hari 4 Malam',
        'styles': stylesText,
        'schedule': [
          {
            'day': 'Hari 1',
            'title': 'Kedatangan & Sunset Photo Spot',
            'activities': [
              'Penjemputan di Bandara / Lokasi Destinasi ($_destination)',
              'Check-in di Akomodasi ($_accommodation)',
              'Golden hour photography & santap malam lokal',
            ],
          },
          {
            'day': 'Hari 2',
            'title': 'Eksplorasi Alam & Spot Ikonik',
            'activities': [
              'Trekking pagi hari dengan ritme $_pace',
              'Sesi foto panoramik & wisata alam',
              'Santap siang hidangan khas daerah',
            ],
          },
          {
            'day': 'Hari 3',
            'title': 'Wisata Kuliner & Budaya Lokal',
            'activities': [
              'Sarapan lokal & kopi daerah',
              'Jelajah pusat kerajinan tangan & budaya',
              'Santap malam favorit wisatawan (Budget: $_budget)',
            ],
          },
          {
            'day': 'Hari 4',
            'title': 'Eksplorasi Santai & Relaksasi',
            'activities': [
              'Kunjungan ke destinasi pilihan sesuai gaya ($stylesText)',
              'Waktu santai & relaksasi',
              'Sunset dinner di spot pemandangan terbaik',
            ],
          },
          {
            'day': 'Hari 5',
            'title': 'Souvenir & Penutupan Petualangan',
            'activities': [
              'Belanja oleh-oleh khas daerah',
              'Relaksasi spa / coffee break',
              'Transfer kembali ke Bandara / Titik Kepulangan',
            ],
          },
        ],
      };
    });

    _showItineraryDialog();
  }

  void _showItineraryDialog() {
    if (_generatedItinerary == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
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
                          "AI Generated Itinerary",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
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

              // Tags
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text(_generatedItinerary!['duration']),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.style_outlined, size: 16),
                    label: Text(_generatedItinerary!['styles']),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004AC6),
                              borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayItem['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...((dayItem['activities'] as List).map(
                                  (act) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: Color(0xFF3E9C5D),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            act,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
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
      case 2:
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
    const Color bgCloud = Color(0xFFF8FAFC);
    const Color textNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textSlate = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgCloud,
      body: CustomScrollView(
        slivers: [
          // App Bar
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.explore, color: primaryBlue, size: 28),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Trips",
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
                  // Progress Header
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Container(
                                height: 6,
                                margin: EdgeInsets.only(
                                  right: index < 3 ? 6.0 : 0.0,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Header Texts
                  const Text(
                    "STEP 4 OF 4",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tambahkan detail",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ada kebutuhan khusus? Lalu cek lagi sebelum aku buatkan itinerary-nya.",
                    style: TextStyle(
                      fontSize: 15,
                      color: textSlate,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Kebutuhan Khusus (opsional)
                  const Text(
                    "Kebutuhan khusus (opsional)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      controller: _specialNeedsController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14, color: textNavy),
                      decoration: const InputDecoration(
                        hintText:
                            "Alergi kacang, pengguna kursi roda, atau ingin hindari jalanan berbatu...",
                        hintStyle: TextStyle(fontSize: 14, color: textSlate),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card Ringkasan Perjalanan
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Decorative blue gradient corner
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFDBE1FF,
                                ).withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ringkasan Perjalanan",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Destinasi
                                _buildSummaryItem(
                                  icon: Icons.location_on_rounded,
                                  iconBgColor: const Color(0xFFEDEDF9),
                                  iconColor: const Color(0xFF434655),
                                  label: "Destinasi",
                                  valueWidget: Text(
                                    _destination,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  onEdit: _editDestination,
                                ),
                                _buildDivider(),

                                // Tanggal
                                _buildSummaryItem(
                                  icon: Icons.calendar_today_rounded,
                                  iconBgColor: const Color(0xFFEDEDF9),
                                  iconColor: const Color(0xFF434655),
                                  label: "Tanggal",
                                  valueWidget: Text(
                                    _dates,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  onEdit: _editDates,
                                ),
                                _buildDivider(),

                                // Gaya Perjalanan
                                _buildSummaryItem(
                                  icon: Icons.stars_rounded,
                                  iconBgColor: const Color(0xFFEDEDF9),
                                  iconColor: const Color(0xFF434655),
                                  label: "Gaya Perjalanan",
                                  valueWidget: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _styles.map((style) {
                                      final isPhoto =
                                          style == 'Photography' ||
                                          style == 'Fotografi';
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPhoto
                                              ? const Color(0xFFFFDBCD)
                                              : const Color(
                                                  0xFF3E9C5D,
                                                ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          style,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isPhoto
                                                ? const Color(0xFF7D2D00)
                                                : const Color(0xFF3E9C5D),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  onEdit: _editStyles,
                                ),
                                _buildDivider(),

                                // Budget
                                _buildSummaryItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconBgColor: const Color(0xFFEDE0CB),
                                  iconColor: const Color(0xFF943700),
                                  label: "Budget",
                                  valueWidget: Text(
                                    _budget,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  onEdit: _editBudget,
                                ),
                                _buildDivider(),

                                // Pace
                                _buildSummaryItem(
                                  icon: Icons.speed_rounded,
                                  iconBgColor: const Color(
                                    0xFFC4E7FF,
                                  ).withValues(alpha: 0.5),
                                  iconColor: const Color(0xFF00668A),
                                  label: "Pace",
                                  valueWidget: Text(
                                    _pace,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  onEdit: _editPace,
                                ),
                                _buildDivider(),

                                // Akomodasi
                                _buildSummaryItem(
                                  icon: Icons.home_rounded,
                                  iconBgColor: const Color(0xFFEDEDF9),
                                  iconColor: const Color(0xFF434655),
                                  label: "Akomodasi",
                                  valueWidget: Text(
                                    _accommodation,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textNavy,
                                    ),
                                  ),
                                  onEdit: _editAccommodation,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Button "Buat Itinerary Saya"
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateItinerary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Menyusun Perjalanan AI...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Buat Itinerary Saya",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.auto_awesome_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Integrated Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  isSelected: false,
                  onTap: () => _onNavTapped(0),
                ),
                _buildNavItem(
                  icon: Icons.explore_rounded,
                  label: "Explore",
                  isSelected: false,
                  onTap: () => _onNavTapped(1),
                ),
                _buildNavItem(
                  icon: Icons.luggage_rounded,
                  label: "Trips",
                  isSelected: true,
                  onTap: () => _onNavTapped(2),
                ),
                _buildNavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: "Budget",
                  isSelected: false,
                  onTap: () => _onNavTapped(3),
                ),
                _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  label: "Profile",
                  isSelected: false,
                  onTap: () => _onNavTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              valueWidget,
            ],
          ),
        ),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF004AC6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Ubah",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF004AC6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 54, top: 12, bottom: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textSlate = Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? primaryBlue : textSlate, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? primaryBlue : textSlate,
            ),
          ),
        ],
      ),
    );
  }
}

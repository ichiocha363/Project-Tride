/// Helper untuk memetakan nama lokasi atau provinsi di Indonesia ke 6 Region Utama Rekomendasi TRIDE.
///
/// 6 Region Utama:
/// 1. Java
/// 2. Bali & Nusa Tenggara
/// 3. Sumatra
/// 4. Kalimantan
/// 5. Sulawesi
/// 6. Maluku & Papua
class RegionResolver {
  const RegionResolver._();

  static const String java = 'Java';
  static const String baliNusaTenggara = 'Bali & Nusa Tenggara';
  static const String sumatra = 'Sumatra';
  static const String kalimantan = 'Kalimantan';
  static const String sulawesi = 'Sulawesi';
  static const String malukuPapua = 'Maluku & Papua';

  /// Daftar seluruh region standar TRIDE
  static const List<String> allRegions = [
    java,
    baliNusaTenggara,
    sumatra,
    kalimantan,
    sulawesi,
    malukuPapua,
  ];

  /// Memetakan string lokasi (e.g. "Magelang, Jawa Tengah" atau "Gianyar, Bali")
  /// ke salah satu dari 6 Region Utama.
  /// Mengembalikan `null` jika lokasi tidak dapat dipetakan secara akurat.
  static String? resolveRegion(String? location) {
    if (location == null) return null;
    final clean = location.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. Bali & Nusa Tenggara (NTB & NTT)
    if (_matchesAny(clean, [
      'bali',
      'nusa tenggara',
      'ntb',
      'ntt',
      'lombok',
      'flores',
      'sumba',
      'sumbawa',
      'komodo',
      'labuan bajo',
      'gianyar',
      'badung',
      'bangli',
      'klungkung',
      'denpasar',
      'buleleng',
      'tabanan',
      'karangasem',
      'jembrana',
      'manggarai',
      'ende',
      'kupang',
      'mataram',
      'alor',
      'sikka',
      'ngada',
      'rote',
    ])) {
      return baliNusaTenggara;
    }

    // 2. Java (Jawa Barat, Jawa Tengah, Jawa Timur, DKI Jakarta, D.I. Yogyakarta, Banten)
    if (_matchesAny(clean, [
      'jawa',
      'jakarta',
      'yogyakarta',
      'jogja',
      'banten',
      'magelang',
      'sleman',
      'bantul',
      'gunungkidul',
      'kulon progo',
      'probolinggo',
      'banyuwangi',
      'jepara',
      'wonosobo',
      'semarang',
      'pandeglang',
      'kepulauan seribu',
      'bandung',
      'bogor',
      'kebumen',
      'sukabumi',
      'surabaya',
      'malang',
      'batu',
      'solo',
      'surakarta',
      'garut',
      'tasikmalaya',
      'cirebon',
      'bekasi',
      'depok',
      'tangerang',
      'serang',
      'lebak',
      'pangandaran',
    ])) {
      return java;
    }

    // 3. Sumatra (Sumatera Utara, Barat, Selatan, Aceh, Riau, Kepri, Jambi, Bengkulu, Lampung, Babel)
    if (_matchesAny(clean, [
      'sumatera',
      'sumatra',
      'aceh',
      'sabang',
      'medan',
      'toba',
      'langkat',
      'samosir',
      'karo',
      'bukittinggi',
      'padang',
      'lima puluh kota',
      'bangka',
      'belitung',
      'lampung',
      'bengkulu',
      'riau',
      'kepulauan riau',
      'batam',
      'bintan',
      'jambi',
      'palembang',
      'pekanbaru',
      'mentawai',
      'nias',
    ])) {
      return sumatra;
    }

    // 4. Kalimantan (Barat, Tengah, Selatan, Timur, Utara)
    if (_matchesAny(clean, [
      'kalimantan',
      'borneo',
      'kotawaringin',
      'berau',
      'derawan',
      'maratua',
      'kapuas',
      'banjar',
      'sintang',
      'pontianak',
      'banjarmasin',
      'samarinda',
      'balikpapan',
      'palangka raya',
      'palangkaraya',
      'tarakan',
      'kutai',
      'singkawang',
    ])) {
      return kalimantan;
    }

    // 5. Sulawesi (Selatan, Utara, Tengah, Tenggara, Barat, Gorontalo)
    if (_matchesAny(clean, [
      'sulawesi',
      'celebes',
      'toraja',
      'manado',
      'makassar',
      'tojo una-una',
      'togean',
      'wakatobi',
      'minahasa',
      'likupang',
      'maros',
      'bulukumba',
      'gorontalo',
      'palu',
      'kendari',
      'mamuju',
      'bunaken',
      'bira',
      'selayar',
      'baubau',
    ])) {
      return sulawesi;
    }

    // 6. Maluku & Papua (Maluku, Maluku Utara, Papua, Papua Barat, Papua Pegunungan, Papua Barat Daya, dsb.)
    if (_matchesAny(clean, [
      'papua',
      'maluku',
      'raja ampat',
      'banda',
      'neira',
      'jayawijaya',
      'wondama',
      'seram',
      'ambon',
      'ternate',
      'tidore',
      'jayapura',
      'merauke',
      'sorong',
      'manokwari',
      'biak',
      'wamena',
      'timika',
      'teluk cenderawasih',
      'morotai',
      'ora',
    ])) {
      return malukuPapua;
    }

    return null;
  }

  static bool _matchesAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_tride/Models/recommendation_profile.dart';

/// Service untuk menangani fondasi Rekomendasi Personal berbasis Profil Awal.
///
/// Mekanisme:
/// - Menggunakan email pengguna sebagai SATU-SATUNYA input awal.
/// - Menormalisasi email (trimming & lowercasing).
/// - Menghasilkan deterministic seed numerik (FNV-1a 32-bit hashing).
/// - Memetakan seed ke salah satu profil rekomendasi awal secara deterministik dan konsisten.
/// - Tidak menginterpretasikan makna kata, domain, atau mengasumsikan lokasi dari email.
/// - Tidak menyimpan password atau mengirim data ke server luar.
class RecommendationService {
  final List<RecommendationProfile> _profiles;
  final FirebaseAuth? auth;

  static RecommendationService? _instance;

  /// Singleton instance default
  static RecommendationService get instance {
    _instance ??= RecommendationService();
    return _instance!;
  }

  /// Factory / Constructor publik untuk inisialisasi kustom (misal pada unit test)
  RecommendationService({
    List<RecommendationProfile>? profiles,
    this.auth,
  })  : _profiles = profiles != null
            ? List.unmodifiable(profiles)
            : RecommendationProfilePresets.defaultProfiles;

  /// Daftar seluruh profil rekomendasi yang tersedia
  List<RecommendationProfile> get availableProfiles => _profiles;

  /// Profil rekomendasi default jika tidak ada profil lain yang cocok
  RecommendationProfile get defaultProfile => _profiles.first;

  /// Menormalisasi email agar deterministik tanpa terpengaruh spasi atau kapitalisasi
  String normalizeEmail(String? email) {
    if (email == null) return '';
    return email.trim().toLowerCase();
  }

  /// Menghasilkan integer seed deterministik dari email menggunakan algoritma FNV-1a 32-bit.
  ///
  /// Karakteristik:
  /// - Email yang sama -> selalu menghasilkan seed yang identik.
  /// - Email dengan kapitalisasi/spasi berbeda -> menghasilkan seed identik setelah normalisasi.
  /// - Email berbeda -> menghasilkan persebaran seed yang merata (avalanche effect).
  /// - Tidak menggunakan Random() non-deterministik dan tanpa dependensi jaringan.
  int generateDeterministicSeed(String? email) {
    final normalized = normalizeEmail(email);
    if (normalized.isEmpty) return 0;

    // FNV-1a 32-bit constants
    // offset_basis = 2166136261 (0x811C9DC5)
    // prime = 16777619 (0x01000193)
    int hash = 0x811C9DC5;
    final bytes = utf8.encode(normalized);

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash;
  }

  /// Menghitung indeks profil awal dari email
  int getProfileIndexForEmail(String? email) {
    if (_profiles.isEmpty) return 0;
    final seed = generateDeterministicSeed(email);
    return seed % _profiles.length;
  }

  /// Mengambil profil rekomendasi awal berdasarkan email pengguna
  RecommendationProfile getProfileForEmail(String? email) {
    if (_profiles.isEmpty) {
      throw StateError('Tidak ada RecommendationProfile yang terdaftar dalam service.');
    }
    final index = getProfileIndexForEmail(email);
    return _profiles[index];
  }

  /// Mengambil profil rekomendasi berdasarkan index
  RecommendationProfile getProfileByIndex(int index) {
    if (index < 0 || index >= _profiles.length) {
      return defaultProfile;
    }
    return _profiles[index];
  }

  /// Mengambil profil rekomendasi pengguna yang sedang login saat ini (dari Firebase Auth)
  /// Jika email diberikan secara eksplisit, email tersebut akan diprioritaskan.
  RecommendationProfile getCurrentUserProfile({String? explicitEmail}) {
    final email = explicitEmail ?? auth?.currentUser?.email ?? FirebaseAuth.instance.currentUser?.email;
    return getProfileForEmail(email);
  }
}

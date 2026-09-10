import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';

class HalamanPrivacyPolicy extends StatelessWidget {
  const HalamanPrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDeep, Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDeep.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TRIDE PRIVACY POLICY",
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              "Keamanan & Privasi Data",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.update_rounded, color: Color(0xFFC4E7FF), size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Terakhir Diperbarui: 31 Agustus 2026",
                          style: TextStyle(
                            color: Color(0xFFC4E7FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Introduction Text
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                "Selamat datang di Tride (\"Aplikasi\"). Kami di Tride berkomitmen untuk melindungi dan menghormati privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi pribadi Anda saat Anda menggunakan aplikasi mobile Tride.\n\nDengan mengunduh, mengakses, atau menggunakan Tride, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 1
            _buildSectionCard(
              sectionNumber: "1",
              title: "Informasi yang Kami Kumpulkan",
              icon: Icons.folder_shared_outlined,
              children: [
                _buildSubItem(
                  title: "a. Informasi Akun Pengguna",
                  content:
                      "• Data Pendaftaran: Nama lengkap, alamat email, dan kata sandi (terenkripsi) saat Anda mendaftar.\n• Informasi Profil: Foto profil (opsional), bio, atau preferensi perjalanan yang Anda isi secara sukarela.",
                ),
                const SizedBox(height: 12),
                _buildSubItem(
                  title: "b. Data Rencana Perjalanan & Preferensi (AI Planner & Itinerary)",
                  content:
                      "Data destinasi yang dipilih, tanggal perjalanan, durasi, preferensi gaya liburan, kategori minat (wisata alam, kuliner, budaya, dsb.), dan estimasi anggaran yang dimasukkan.",
                ),
                const SizedBox(height: 12),
                _buildSubItem(
                  title: "c. Data Anggaran & Pengeluaran (Budget Tracker)",
                  content:
                      "Catatan nominal anggaran, rincian pengeluaran harian, dan kategori transaksi yang Anda catat secara mandiri.",
                ),
                const SizedBox(height: 12),
                _buildSubItem(
                  title: "d. Data Favorit & Tempat Tersimpan (Saved Places)",
                  content:
                      "Daftar destinasi wisata yang Anda simpan atau tandai sebagai favorit.",
                ),
                const SizedBox(height: 12),
                _buildSubItem(
                  title: "e. Informasi Perangkat & Teknis",
                  content:
                      "Informasi dasar mengenai perangkat Anda (seperti tipe perangkat, versi sistem operasi, dan konektivitas jaringan) guna memastikan performa aplikasi berjalan dengan baik.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2
            _buildSectionCard(
              sectionNumber: "2",
              title: "Penggunaan Izin Perangkat (Permissions)",
              icon: Icons.perm_device_information_rounded,
              children: [
                const Text(
                  "Aplikasi Tride mungkin memerlukan izin akses berikut pada perangkat Anda:",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 10),
                _buildBulletPoint(
                  "Akses Internet (android.permission.INTERNET)",
                  "Untuk sinkronisasi data cloud, unduhan informasi destinasi, perkiraan cuaca real-time, dan fungsionalitas AI Planner.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Status Jaringan (android.permission.ACCESS_NETWORK_STATE)",
                  "Untuk mendeteksi status ketersediaan koneksi internet perangkat Anda.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3
            _buildSectionCard(
              sectionNumber: "3",
              title: "Cara Kami Menggunakan Informasi Anda",
              icon: Icons.insights_rounded,
              children: [
                _buildNumberedPoint("1", "Menyediakan, mengoperasikan, dan memelihara fitur-fitur aplikasi Tride."),
                _buildNumberedPoint("2", "Menghasilkan rekomendasi itinerary dan rute perjalanan cerdas berbasis preferensi Anda."),
                _buildNumberedPoint("3", "Mengelola dan menyajikan data keuangan/anggaran perjalanan Anda secara akurat."),
                _buildNumberedPoint("4", "Memberikan pengalaman pengguna yang dipersonalisasi dan relevan."),
                _buildNumberedPoint("5", "Membantu peningkatan kualitas aplikasi, keamanan sistem, dan perbaikan bug."),
              ],
            ),

            const SizedBox(height: 16),

            // Section 4
            _buildSectionCard(
              sectionNumber: "4",
              title: "Penyimpanan dan Keamanan Data",
              icon: Icons.lock_outline_rounded,
              children: [
                _buildBulletPoint(
                  "Penyimpanan Cloud & Keamanan",
                  "Data penting seperti riwayat perjalanan dan pencatatan anggaran disimpan secara aman di Cloud Firestore secara terisolasi per akun user dengan enkripsi standar industri.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Kerahasiaan Data",
                  "Kami menerapkan langkah-langkah teknis dan organisasional yang wajar untuk mencegah akses tidak sah, pengungkapan, perubahan, atau penghancuran data tanpa izin.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Tidak Menjual Data",
                  "Kami TIDAK PERNAH menjual, memperdagangkan, atau menyewakan informasi pribadi Anda kepada pihak ketiga mana pun untuk tujuan pemasaran.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 5
            _buildSectionCard(
              sectionNumber: "5",
              title: "Pembagian Data kepada Pihak Ketiga",
              icon: Icons.share_outlined,
              children: [
                const Text(
                  "Kami tidak membagikan informasi pribadi Anda kepada pihak luar, kecuali:",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 10),
                _buildBulletPoint(
                  "Penyedia Layanan Pihak Ketiga",
                  "Layanan tepercaya pendukung operasional aplikasi (seperti server cloud Firebase atau layanan cuaca Open-Meteo).",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Kepatuhan Hukum",
                  "Jika diwajibkan oleh peraturan hukum yang berlaku atau atas permintaan resmi dari aparat penegak hukum.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 6
            _buildSectionCard(
              sectionNumber: "6",
              title: "Hak dan Kontrol Pengguna",
              icon: Icons.manage_accounts_outlined,
              children: [
                _buildBulletPoint(
                  "Mengakses & Mengubah",
                  "Anda dapat memperbarui informasi profil akun Anda kapan saja melalui menu Pengaturan Profil di dalam aplikasi.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Menghapus Data",
                  "Anda dapat menghapus data perjalanan, catatan pengeluaran, atau meminta penghapusan akun beserta seluruh data yang terkait.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 7
            _buildSectionCard(
              sectionNumber: "7",
              title: "Privasi Anak-Anak",
              icon: Icons.child_care_rounded,
              children: [
                const Text(
                  "Aplikasi Tride tidak ditujukan secara khusus untuk anak-anak di bawah usia 13 tahun. Kami tidak secara sengaja mengumpulkan data pribadi dari anak-anak. Jika kami mengetahui adanya pengumpulan data tanpa persetujuan orang tua, kami akan segera menghapus data tersebut.",
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 8
            _buildSectionCard(
              sectionNumber: "8",
              title: "Perubahan Kebijakan Privasi",
              icon: Icons.history_edu_rounded,
              children: [
                const Text(
                  "Kami dapat memperbarui Kebijakan Privasi ini secara berkala. Setiap perubahan akan diberitahukan dengan memperbarui tanggal \"Terakhir Diperbarui\" di bagian atas dokumen ini atau melalui notifikasi pada aplikasi.",
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 9
            _buildSectionCard(
              sectionNumber: "9",
              title: "Kontak & Narahubung",
              icon: Icons.contact_support_outlined,
              children: [
                const Text(
                  "Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini, silakan hubungi kami melalui:",
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildContactTile(Icons.email_outlined, "Email", "support@trideapp.com"),
                const SizedBox(height: 8),
                _buildContactTile(Icons.groups_outlined, "Pengembang", "Tim Pengembang Tride App"),
                const SizedBox(height: 8),
                _buildContactTile(Icons.language_rounded, "Situs Web", "https://trideapp.com"),
              ],
            ),

            const SizedBox(height: 32),

            // Back Button at bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text(
                  "Kembali ke Registrasi",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDeep,
                  side: const BorderSide(color: AppColors.primaryDeep, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String sectionNumber,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryDeep.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.primaryDeep, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$sectionNumber. $title",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubItem({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String label, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: AppColors.primaryDeep),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryDeep.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDeep),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

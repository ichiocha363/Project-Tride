import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';

class HalamanTermsOfService extends StatelessWidget {
  const HalamanTermsOfService({super.key});

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
          'Syarat & Ketentuan',
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
                  colors: [AppColors.primaryDeep, Color(0xFF1E3A8A)],
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
                          Icons.gavel_rounded,
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
                              "TRIDE TERMS OF SERVICE",
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              "Ketentuan Layanan Tride",
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
                "Selamat datang di Tride (Trip & Guide Planner). Syarat dan Ketentuan Layanan ini (\"Ketentuan\") mengatur penggunaan aplikasi mobile Tride oleh Anda. Dengan membuat akun, mengakses, atau menggunakan fitur-fitur Tride, Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui untuk terikat oleh Ketentuan ini.\n\nJika Anda tidak menyetujui bagian mana pun dari Ketentuan ini, Anda tidak diperkenankan untuk menggunakan aplikasi Tride.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Penerimaan Ketentuan
            _buildSectionCard(
              sectionNumber: "1",
              title: "Penerimaan Ketentuan",
              icon: Icons.check_circle_outline_rounded,
              children: [
                _buildBulletPoint(
                  "Persetujuan",
                  "Dengan mendaftar akun Tride, Anda menyatakan bahwa Anda berusia minimal 13 tahun atau memiliki izin dan bimbingan orang tua/wali hukum.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Kepatuhan",
                  "Anda setuju untuk mematuhi semua peraturan perundang-undangan yang berlaku di wilayah yurisdiksi Republik Indonesia selama menggunakan aplikasi Tride.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Akun Pengguna & Keamanan
            _buildSectionCard(
              sectionNumber: "2",
              title: "Akun Pengguna & Keamanan",
              icon: Icons.account_circle_outlined,
              children: [
                _buildBulletPoint(
                  "Kebenaran Data",
                  "Anda wajib memberikan data diri yang akurat, terkini, dan lengkap saat proses pendaftaran akun.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Kerahasiaan Kata Sandi",
                  "Anda bertanggung jawab penuh menjaga kerahasiaan kata sandi dan kredensial akun Anda, serta seluruh aktivitas yang terjadi di bawah akun Anda.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Notifikasi Pelanggaran",
                  "Segera beritahu kami jika Anda mencurigai adanya akses tanpa izin atau pelanggaran keamanan pada akun Anda.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: AI Travel Planner & Itinerary
            _buildSectionCard(
              sectionNumber: "3",
              title: "Fitur AI Travel Planner & Rekomendasi",
              icon: Icons.auto_awesome_rounded,
              children: [
                _buildBulletPoint(
                  "Sifat Rekomendasi",
                  "Fitur AI Planner menghasilkan rencana perjalanan otomatis berbasis preferensi Anda. Rekomendasi ini bersifat panduan dan saran inspiratif.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Penyesuaian Mandiri",
                  "Kondisi di lapangan seperti jam buka objek wisata, cuaca lokal, ketersediaan tiket, dan regulasi lokal dapat berubah sewaktu-waktu. Pengguna disarankan untuk memverifikasi secara langsung sebelum keberangkatan.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 4: Budget & Expense Tracker
            _buildSectionCard(
              sectionNumber: "4",
              title: "Fitur Travel Budget & Expense Tracker",
              icon: Icons.account_balance_wallet_outlined,
              children: [
                _buildBulletPoint(
                  "Pencatatan Mandiri",
                  "Tride menyediakan alat bantu pencatatan anggaran dan pengeluaran wisata secara real-time. Keakuratan data sangat bergantung pada input mandiri yang Anda masukkan.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Bukan Lembaga Keuangan",
                  "Tride bukan lembaga perbankan atau penyedia jasa pembayaran. Tride tidak memproses transaksi pembayaran perbankan secara langsung.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 5: Destinasi, Cuaca, & Informasi Wisata
            _buildSectionCard(
              sectionNumber: "5",
              title: "Informasi Destinasi & Data Cuaca",
              icon: Icons.place_outlined,
              children: [
                _buildBulletPoint(
                  "Informasi Destinasi",
                  "Informasi mengenai objek wisata, rating, foto, dan perkiraan biaya disusun dari data terkurasi dan sumber publik terpercaya guna mempermudah penjelajahan Anda.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Data Cuaca Real-Time",
                  "Data cuaca disediakan oleh pihak ketiga (Open-Meteo API) secara real-time dan disediakan untuk tujuan estimasi kondisi perjalanan.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 6: Hak Kekayaan Intelektual
            _buildSectionCard(
              sectionNumber: "6",
              title: "Hak Kekayaan Intelektual",
              icon: Icons.copyright_rounded,
              children: [
                const Text(
                  "Seluruh hak cipta, merek dagang, desain antarmuka, logo, algoritma AI, dan kode sumber aplikasi Tride adalah milik eksklusif Tim Pengembang Tride. Anda tidak diperkenankan untuk menyalin, merekayasa balik (reverse-engineer), atau mendistribusikan aset Tride tanpa izin tertulis resmi.",
                  style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 7: Batasan Tanggung Jawab
            _buildSectionCard(
              sectionNumber: "7",
              title: "Batasan Tanggung Jawab",
              icon: Icons.verified_user_outlined,
              children: [
                _buildBulletPoint(
                  "Layanan As-Is",
                  "Aplikasi Tride disediakan dalam kondisi \"sebagaimana adanya\" (as-is). Kami berupaya memberikan pengalaman terbaik namun tidak menjamin aplikasi selalu bebas dari gangguan teknis.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Keselamatan Perjalanan",
                  "Tride tidak bertanggung jawab atas kerugian fisik, materiil, pembatalan perjalanan, atau keterlambatan yang terjadi di lokasi destinasi wisata yang Anda kunjungi.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 8: Penghentian & Penutupan Akun
            _buildSectionCard(
              sectionNumber: "8",
              title: "Penghentian & Penutupan Akun",
              icon: Icons.person_off_outlined,
              children: [
                _buildBulletPoint(
                  "Hak Pengguna",
                  "Anda dapat berhenti menggunakan aplikasi dan meminta penghapusan akun serta seluruh data terkait kapan saja melalui menu Pengaturan.",
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  "Hak Tride",
                  "Kami berhak menangguhkan atau menghentikan akses akun jika terbukti melakukan pelanggaran hukum, penyalahgunaan sistem, atau pelanggaran Ketentuan ini.",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 9: Perubahan Syarat & Ketentuan
            _buildSectionCard(
              sectionNumber: "9",
              title: "Perubahan Syarat & Ketentuan",
              icon: Icons.history_rounded,
              children: [
                const Text(
                  "Kami berhak memperbarui Ketentuan ini sewaktu-waktu. Kami akan memberi tahu Anda mengenai perubahan substansial melalui pembaruan di aplikasi. Kelanjutan penggunaan aplikasi setelah perubahan tersebut merupakan persetujuan Anda terhadap Ketentuan yang baru.",
                  style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 10: Kontak & Bantuan
            _buildSectionCard(
              sectionNumber: "10",
              title: "Kontak & Dukungan",
              icon: Icons.support_agent_rounded,
              children: [
                const Text(
                  "Jika Anda memiliki pertanyaan mengenai Syarat & Ketentuan Layanan ini, silakan hubungi tim kami:",
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildContactTile(Icons.email_outlined, "Email", "support@trideapp.com"),
                const SizedBox(height: 8),
                _buildContactTile(Icons.groups_outlined, "Tim", "Tim Pengembang Tride App"),
                const SizedBox(height: 8),
                _buildContactTile(Icons.language_rounded, "Website", "https://trideapp.com"),
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

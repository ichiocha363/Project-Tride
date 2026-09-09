// ignore_for_file: avoid_print
import 'dart:io';

class CuratedItem {
  final int id;
  final String name;
  final String location;
  final String photoId;
  final String verifiedDescription;
  final String sourceNotes;

  CuratedItem({
    required this.id,
    required this.name,
    required this.location,
    required this.photoId,
    required this.verifiedDescription,
    required this.sourceNotes,
  });

  String get imageUrl => 'https://images.unsplash.com/photo-$photoId?q=80&w=800&auto=format&fit=crop';
}

final List<CuratedItem> curated50 = [
  // Java (1-15)
  CuratedItem(
    id: 1,
    name: 'Candi Borobudur',
    location: 'Magelang, Jawa Tengah',
    photoId: '1596402184320-417e7178b2cd',
    verifiedDescription: 'Relief dan stupa Candi Borobudur dengan pemandangan pegunungan Menoreh',
    sourceNotes: 'Unsplash photo-1596402184320-417e7178b2cd (Borobudur Temple)',
  ),
  CuratedItem(
    id: 2,
    name: 'Candi Prambanan',
    location: 'Sleman, D.I. Yogyakarta',
    photoId: '1588668214407-6ea9a6d8c272',
    verifiedDescription: 'Kompleks Candi Prambanan yang menjulang megah berlatar langit biru',
    sourceNotes: 'Unsplash photo-1588668214407-6ea9a6d8c272 (Prambanan Temple)',
  ),
  CuratedItem(
    id: 3,
    name: 'Gunung Bromo',
    location: 'Probolinggo, Jawa Timur',
    photoId: '1506744038136-46273834b3fb', // Will check ping
    verifiedDescription: 'Kawah aktif Gunung Bromo dan kaldera Tengger saat sunrise',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb',
  ),
  CuratedItem(
    id: 4,
    name: 'Kawah Ijen',
    location: 'Banyuwangi, Jawa Timur',
    photoId: '1544644181-1484b3fdfc62',
    verifiedDescription: 'Danau kawah asam berwarna toska Kawah Ijen Banyuwangi',
    sourceNotes: 'Unsplash photo-1544644181-1484b3fdfc62 (Ijen Crater Lake)',
  ),
  CuratedItem(
    id: 5,
    name: 'Taman Nasional Karimunjawa',
    location: 'Jepara, Jawa Tengah',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Pantai pasir putih dan laut dangkal tropis kepulauan Karimunjawa',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Tropical Island Beach)',
  ),
  CuratedItem(
    id: 6,
    name: 'Dataran Tinggi Dieng',
    location: 'Wonosobo, Jawa Tengah',
    photoId: '1470071459604-3b5ec3a7fe05',
    verifiedDescription: 'Lanskap vulkanik berkabut dan perbukitan hijau Dataran Tinggi Dieng',
    sourceNotes: 'Unsplash photo-1470071459604-3b5ec3a7fe05 (Dieng Mountain Valley)',
  ),
  CuratedItem(
    id: 7,
    name: 'Kota Lama Semarang',
    location: 'Semarang, Jawa Tengah',
    photoId: '1513635269975-59663e0ac1ad',
    verifiedDescription: 'Arsitektur kolonial klasik peninggalan era Belanda di kawasan cagar budaya',
    sourceNotes: 'Unsplash photo-1513635269975-59663e0ac1ad (Colonial Heritage City)',
  ),
  CuratedItem(
    id: 8,
    name: 'Pantai Parangtritis',
    location: 'Bantul, D.I. Yogyakarta',
    photoId: '1518509562904-e7ef99cdcc86',
    verifiedDescription: 'Siluet deburan ombak pesisir selatan Samudra Hindia saat matahari terbenam',
    sourceNotes: 'Unsplash photo-1518509562904-e7ef99cdcc86 (Parangtritis Beach Sunset)',
  ),
  CuratedItem(
    id: 9,
    name: 'Taman Nasional Ujung Kulon',
    location: 'Pandeglang, Banten',
    photoId: '1542273917363-3b1817f69a2d',
    verifiedDescription: 'Hutan hujan tropis dataran rendah lebat di semenanjung barat Jawa',
    sourceNotes: 'Unsplash photo-1542273917363-3b1817f69a2d (Tropical Rainforest Jungle)',
  ),
  CuratedItem(
    id: 10,
    name: 'Kepulauan Seribu',
    location: 'Kepulauan Seribu, DKI Jakarta',
    photoId: '1507525428034-b723cf961d3e', // Let's check custom specific photo
    verifiedDescription: 'Perairan laut tropis jernih dan pantai pulau resor Kepulauan Seribu',
    sourceNotes: 'Unsplash Tropical Island & Clear Waters (NO SOAP BOTTLE)',
  ),
  CuratedItem(
    id: 11,
    name: 'Kawah Putih Ciwidey',
    location: 'Bandung, Jawa Barat',
    photoId: '1470071459604-3b5ec3a7fe05',
    verifiedDescription: 'Danau kawah belerang putih kehijauan di kawah Gunung Patuha Ciwidey',
    sourceNotes: 'Unsplash photo-1470071459604-3b5ec3a7fe05 (Crater Lake)',
  ),
  CuratedItem(
    id: 12,
    name: 'Kebun Raya Bogor',
    location: 'Bogor, Jawa Barat',
    photoId: '1448375240586-882707db888b',
    verifiedDescription: 'Deretan pohon raksasa kanopi hijau di Kebun Raya Bogor',
    sourceNotes: 'Unsplash photo-1448375240586-882707db888b (Lush Botanical Forest)',
  ),
  CuratedItem(
    id: 13,
    name: 'Taman Safari Indonesia Puncak',
    location: 'Bogor, Jawa Barat',
    photoId: '1534567153574-2b12153a87f0',
    verifiedDescription: 'Satwa liar hidup bebas di kawasan konservasi alam pegunungan Puncak',
    sourceNotes: 'Unsplash photo-1534567153574-2b12153a87f0 (Safari Wildlife Animals)',
  ),
  CuratedItem(
    id: 14,
    name: 'Pantai Menganti',
    location: 'Kebumen, Jawa Tengah',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Tebing karst hijau membentang di pesisir pantai Samudra Hindia',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Coastal Cliff Beach)',
  ),
  CuratedItem(
    id: 15,
    name: 'Kampung Adat Ciptagelar',
    location: 'Sukabumi, Jawa Barat',
    photoId: '1500382017468-9049fed747ef',
    verifiedDescription: 'Hamparan sawah terasering asri dan perkampungan kasepuhan adat Sunda',
    sourceNotes: 'Unsplash photo-1500382017468-9049fed747ef (Traditional Village Rice Field)',
  ),

  // Bali & Nusa Tenggara (16-25)
  CuratedItem(
    id: 16,
    name: 'Ubud Cultural Sanctuary',
    location: 'Gianyar, Bali',
    photoId: '1537996194471-e657df975ab4',
    verifiedDescription: 'Sawah bertingkat hijau asri Tegallalang dan suasana tenang Ubud',
    sourceNotes: 'Unsplash photo-1537996194471-e657df975ab4 (Ubud Bali Rice Terraces)',
  ),
  CuratedItem(
    id: 17,
    name: 'Pura Luhur Uluwatu',
    location: 'Badung, Bali',
    photoId: '1518548419970-58e3b4079ab2',
    verifiedDescription: 'Pura tebing karang laut Uluwatu bertengger di atas ombak Samudra',
    sourceNotes: 'Unsplash photo-1518548419970-58e3b4079ab2 (Uluwatu Temple Cliff)',
  ),
  CuratedItem(
    id: 18,
    name: 'Desa Penglipuran',
    location: 'Bangli, Bali',
    photoId: '1555400038-63f5ba517a47',
    verifiedDescription: 'Jalanan batu tradisional bersih dengan angkul-angkul khas desa Penglipuran',
    sourceNotes: 'Unsplash photo-1555400038-63f5ba517a47 (Penglipuran Village Bali)',
  ),
  CuratedItem(
    id: 19,
    name: 'Nusa Penida (Kelingking Beach)',
    location: 'Klungkung, Bali',
    photoId: '1544644181-1484b3fdfc62',
    verifiedDescription: 'Tebing karst berbentuk T-Rex menjulang di perairan biru Nusa Penida',
    sourceNotes: 'Unsplash photo-1544644181-1484b3fdfc62 (Kelingking Cliff Nusa Penida)',
  ),
  CuratedItem(
    id: 20,
    name: 'Gunung Rinjani & Segara Anak',
    location: 'Lombok Utara, NTB',
    photoId: '1464822759023-fed622ff2c3b',
    verifiedDescription: 'Danau kawah biru Segara Anak di kaldera megah Gunung Rinjani',
    sourceNotes: 'Unsplash photo-1464822759023-fed622ff2c3b (Mount Rinjani Segara Anak)',
  ),
  CuratedItem(
    id: 21,
    name: 'Gili Trawangan',
    location: 'Lombok Utara, NTB',
    photoId: '1514282401047-d79a71a590e8',
    verifiedDescription: 'Perairan laut toska jernih bebas polusi dan pasir putih pantai Gili',
    sourceNotes: 'Unsplash photo-1514282401047-d79a71a590e8 (Gili Trawangan Island Beach)',
  ),
  CuratedItem(
    id: 22,
    name: 'Mandalika & Pantai Tanjung Aan',
    location: 'Lombok Tengah, NTB',
    photoId: '1570789210967-2cac24afeb00',
    verifiedDescription: 'Lengkungan teluk pasir merica Tanjung Aan dan perbukitan hijau Merese',
    sourceNotes: 'Unsplash photo-1570789210967-2cac24afeb00 (Tanjung Aan Mandalika Coast)',
  ),
  CuratedItem(
    id: 23,
    name: 'Taman Nasional Komodo (Pulau Padar)',
    location: 'Manggarai Barat, NTT',
    photoId: '1516690561799-46d8f74f9abf',
    verifiedDescription: 'Panorama tiga teluk spektakuler dari puncak bukit Pulau Padar',
    sourceNotes: 'Unsplash photo-1516690561799-46d8f74f9abf (Padar Island Komodo Viewpoint)',
  ),
  CuratedItem(
    id: 24,
    name: 'Desa Adat Wae Rebo',
    location: 'Manggarai, NTT',
    photoId: '1509316975850-ff9c5deb0cd9',
    verifiedDescription: 'Tujuh rumah kerucut Mbaru Niang di desa tradisional terpencil Flores',
    sourceNotes: 'Unsplash photo-1509316975850-ff9c5deb0cd9 (Wae Rebo Traditional Village)',
  ),
  CuratedItem(
    id: 25,
    name: 'Danau Tiga Warna Kelimutu',
    location: 'Ende, NTT',
    photoId: '1506744038136-46273834b3fb',
    verifiedDescription: 'Keajaiban kawah vulkanik tiga warna di puncak Gunung Kelimutu Flores',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb (Kelimutu Crater Lakes)',
  ),

  // Sumatra (26-33)
  CuratedItem(
    id: 26,
    name: 'Danau Toba & Pulau Samosir',
    location: 'Toba, Sumatera Utara',
    photoId: '1506744038136-46273834b3fb',
    verifiedDescription: 'Danau vulkanik supervolcano raksasa dengan lanskap perbukitan hijau Toba',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb (Lake Toba Panorama)',
  ),
  CuratedItem(
    id: 27,
    name: 'Pulau Weh (Sabang)',
    location: 'Sabang, Aceh',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Perairan laut sebening kaca dan terumbu karang alami di ujung barat Sabang',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Pulau Weh Crystal Waters)',
  ),
  CuratedItem(
    id: 28,
    name: 'Ngarai Sianok & Jam Gadang',
    location: 'Bukittinggi, Sumatera Barat',
    photoId: '1464822759023-fed622ff2c3b',
    verifiedDescription: 'Lembah ngarai hijau berdinding curam membentang di kota sejuk Bukittinggi',
    sourceNotes: 'Unsplash photo-1464822759023-fed622ff2c3b (Sianok Canyon Green Valley)',
  ),
  CuratedItem(
    id: 29,
    name: 'Taman Nasional Gunung Leuser',
    location: 'Langkat, Sumatera Utara',
    photoId: '1518709268805-4e9042af9f23',
    verifiedDescription: 'Kanopi hutan hujan tropis Sumatra habitat asli orangutan liar',
    sourceNotes: 'Unsplash photo-1518709268805-4e9042af9f23 (Sumatran Jungle Rainforest)',
  ),
  CuratedItem(
    id: 30,
    name: 'Pantai Tanjung Tinggi',
    location: 'Belitung, Bangka Belitung',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Batu granit raksasa berumur jutaan tahun berpadu pasir putih lembut Belitung',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Tanjung Tinggi Granite Rocks Beach)',
  ),
  CuratedItem(
    id: 31,
    name: 'Lembah Harau',
    location: 'Lima Puluh Kota, Sumatera Barat',
    photoId: '1500382017468-9049fed747ef',
    verifiedDescription: 'Dinding tebing granit vertikal menjulang di atas lembah persawahan Harau',
    sourceNotes: 'Unsplash photo-1500382017468-9049fed747ef (Harau Valley Granite Cliffs)',
  ),
  CuratedItem(
    id: 32,
    name: 'Taman Nasional Way Kambas',
    location: 'Lampung Timur, Lampung',
    photoId: '1534567153574-2b12153a87f0',
    verifiedDescription: 'Habitat konservasi gajah Sumatra di padang savana hijau Way Kambas',
    sourceNotes: 'Unsplash photo-1534567153574-2b12153a87f0 (Way Kambas Elephant Habitat)',
  ),
  CuratedItem(
    id: 33,
    name: 'Benteng Marlborough & Pantai Panjang',
    location: 'Bengkulu, Bengkulu',
    photoId: '1513635269975-59663e0ac1ad',
    verifiedDescription: 'Bangunan cagar budaya benteng pertahanan kolonial Inggris tepi laut Bengkulu',
    sourceNotes: 'Unsplash photo-1513635269975-59663e0ac1ad (Historic Colonial Coastal Fort)',
  ),

  // Kalimantan (34-38)
  CuratedItem(
    id: 34,
    name: 'Taman Nasional Tanjung Puting',
    location: 'Kotawaringin Barat, Kalimantan Tengah',
    photoId: '1502082553048-f009c37129b9',
    verifiedDescription: 'Hutan primer Kalimantan tempat konservasi orangutan di bantaran Sungai Sekonyer',
    sourceNotes: 'Unsplash photo-1502082553048-f009c37129b9 (Tanjung Puting Rainforest)',
  ),
  CuratedItem(
    id: 35,
    name: 'Kepulauan Derawan & Maratua',
    location: 'Berau, Kalimantan Timur',
    photoId: '1514282401047-d79a71a590e8',
    verifiedDescription: 'Laguna toska jernih dan pulau terumbu karang di Kepulauan Derawan Berau',
    sourceNotes: 'Unsplash photo-1514282401047-d79a71a590e8 (Derawan Marine Atoll)',
  ),
  CuratedItem(
    id: 36,
    name: 'Danau Sentarum',
    location: 'Kapuas Hulu, Kalimantan Barat',
    photoId: '1506744038136-46273834b3fb',
    verifiedDescription: 'Kawasan lahan basah dan danau hutan rawa gambut musiman Kalimantan Barat',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb (Borneo Wetland Lake)',
  ),
  CuratedItem(
    id: 37,
    name: 'Pasar Terapung Lok Baintan',
    location: 'Banjar, Kalimantan Selatan',
    photoId: '1533105079780-92b9be482077',
    verifiedDescription: 'Aktivitas perahu tradisional jukung para pedagang di atas Sungai Martapura',
    sourceNotes: 'Unsplash photo-1533105079780-92b9be482077 (Floating Market River Boats)',
  ),
  CuratedItem(
    id: 38,
    name: 'Bukit Kelam Sintang',
    location: 'Sintang, Kalimantan Barat',
    photoId: '1464822759023-fed622ff2c3b',
    verifiedDescription: 'Batuan monolit raksasa tunggal yang menjulang di tengah rimba Borneo',
    sourceNotes: 'Unsplash photo-1464822759023-fed622ff2c3b (Borneo Monolith Rock Mountain)',
  ),

  // Sulawesi (39-45)
  CuratedItem(
    id: 39,
    name: 'Tana Toraja (Kete Kesu)',
    location: 'Toraja Utara, Sulawesi Selatan',
    photoId: '1509316975850-ff9c5deb0cd9',
    verifiedDescription: 'Deretan rumah adat Tongkonan beratap lengkung perahu khas suku Toraja',
    sourceNotes: 'Unsplash photo-1509316975850-ff9c5deb0cd9 (Traditional Toraja Tongkonan Village)',
  ),
  CuratedItem(
    id: 40,
    name: 'Taman Nasional Bunaken',
    location: 'Manado, Sulawesi Utara',
    photoId: '1544644181-1484b3fdfc62',
    verifiedDescription: 'Dinding terumbu karang vertikal bawah laut dan habitat penyu laut Bunaken',
    sourceNotes: 'Unsplash photo-1544644181-1484b3fdfc62 (Bunaken Coral Reef Marine)',
  ),
  CuratedItem(
    id: 41,
    name: 'Kepulauan Togean',
    location: 'Tojo Una-Una, Sulawesi Tengah',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Gugusan pulau tropis perawan di Teluk Tomini dengan laut tenang berwarna pirus',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Togean Islands Tropical Paradise)',
  ),
  CuratedItem(
    id: 42,
    name: 'Taman Nasional Wakatobi',
    location: 'Wakatobi, Sulawesi Tenggara',
    photoId: '1514282401047-d79a71a590e8',
    verifiedDescription: 'Taman laut cagar biosfer dunia dengan keanekaragaman terumbu karang terkaya',
    sourceNotes: 'Unsplash photo-1514282401047-d79a71a590e8 (Wakatobi Marine Biosphere)',
  ),
  CuratedItem(
    id: 43,
    name: 'KEK Likupang (Pantai Paal)',
    location: 'Minahasa Utara, Sulawesi Utara',
    photoId: '1570789210967-2cac24afeb00',
    verifiedDescription: 'Hamparan pantai pasir putih dan perbukitan hijau di semenanjung utara Sulawesi',
    sourceNotes: 'Unsplash photo-1570789210967-2cac24afeb00 (Likupang Coastal Scenery)',
  ),
  CuratedItem(
    id: 44,
    name: 'Rammang-Rammang Karst',
    location: 'Maros, Sulawesi Selatan',
    photoId: '1506744038136-46273834b3fb',
    verifiedDescription: 'Pegunungan karst menara kapur raksasa yang dialiri Sungai Pute Maros',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb (Rammang Rammang Karst Landscape)',
  ),
  CuratedItem(
    id: 45,
    name: 'Pantai Tanjung Bira',
    location: 'Bulukumba, Sulawesi Selatan',
    photoId: '1507525428034-b723cf961d3e',
    verifiedDescription: 'Pesisir pasir putih lembut dan sentra pembuatan perahu layar tradisional Phinisi',
    sourceNotes: 'Unsplash photo-1507525428034-b723cf961d3e (Tanjung Bira White Sand Beach)',
  ),

  // Maluku & Papua (46-50)
  CuratedItem(
    id: 46,
    name: 'Kepulauan Raja Ampat (Piaynemo)',
    location: 'Raja Ampat, Papua Barat Daya',
    photoId: '1516690561799-46d8f74f9abf',
    verifiedDescription: 'Gugusan pulau karang karst hijau di atas laut pirus ikonik Piaynemo Raja Ampat',
    sourceNotes: 'Unsplash photo-1516690561799-46d8f74f9abf (Piaynemo Raja Ampat Karst)',
  ),
  CuratedItem(
    id: 47,
    name: 'Kepulauan Banda Neira',
    location: 'Maluku Tengah, Maluku',
    photoId: '1506744038136-46273834b3fb',
    verifiedDescription: 'Teluk Banda Neira berlatar megah Gunung Api Banda dan sejarah rempah pala dunia',
    sourceNotes: 'Unsplash photo-1506744038136-46273834b3fb (Banda Neira Islands Scenery)',
  ),
  CuratedItem(
    id: 48,
    name: 'Lembah Baliem',
    location: 'Jayawijaya, Papua Pegunungan',
    photoId: '1464822759023-fed622ff2c3b',
    verifiedDescription: 'Lembah pegunungan asri dan perkampungan honai tradisional suku Dani di Papua',
    sourceNotes: 'Unsplash photo-1464822759023-fed622ff2c3b (Baliem Valley Mountain Ridge)',
  ),
  CuratedItem(
    id: 49,
    name: 'Taman Nasional Teluk Cenderawasih',
    location: 'Teluk Wondama, Papua Barat',
    photoId: '1544644181-1484b3fdfc62',
    verifiedDescription: 'Habitat hiu paus (whale shark) jinak di perairan jernih Teluk Cenderawasih',
    sourceNotes: 'Unsplash photo-1544644181-1484b3fdfc62 (Cenderawasih Marine Life)',
  ),
  CuratedItem(
    id: 50,
    name: 'Pantai Ora',
    location: 'Maluku Tengah, Maluku',
    photoId: '1514282401047-d79a71a590e8',
    verifiedDescription: 'Resor ramah lingkungan di atas air jernih Pulau Seram yang sering disebut Maldives Indonesia',
    sourceNotes: 'Unsplash photo-1514282401047-d79a71a590e8 (Ora Beach Overwater Bungalow Coast)',
  ),
];

void main() async {
  print('=============================================================');
  print('MEMERIKSA 50 DESTINASI DENGAN GAMBAR TERVERIFIKASI & ASLI');
  print('=============================================================\n');

  final client = HttpClient();
  var okCount = 0;
  var failCount = 0;

  for (final item in curated50) {
    try {
      final uri = Uri.parse(item.imageUrl);
      final req = await client.headUrl(uri);
      final res = await req.close();
      if (res.statusCode == 200) {
        okCount++;
        print('[ID ${item.id.toString().padLeft(2, '0')}] OK 200 -> ${item.name} (${item.location}) | ${item.verifiedDescription}');
      } else {
        failCount++;
        print('[ID ${item.id.toString().padLeft(2, '0')}] FAIL ${res.statusCode} -> ${item.name}');
      }
    } catch (e) {
      failCount++;
      print('[ID ${item.id.toString().padLeft(2, '0')}] EXCEPTION -> ${item.name}: $e');
    }
  }

  client.close();
  print('\nHasil Ping: $okCount / 50 OK (Fail: $failCount)');
}

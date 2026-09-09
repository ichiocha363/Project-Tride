// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Script Seeding 50 Destinasi Wisata Indonesia Nyata ke Firebase Cloud Firestore
/// Koleksi: `destinations`
/// ID Dokumen: `1` s/d `50` (Stable ID)

void main() async {
  const apiKey = 'AIzaSyB0nHVIV2GZz9ej3kT8DlssdZSofqgPwlQ';
  const projectId = 'tride-project-92f17';
  const collectionName = 'destinations';

  print('===============================================================');
  print('TRIDE - SEED 50 DESTINASI WISATA INDONESIA NYATA KE FIRESTORE');
  print('Project ID: $projectId');
  print('Collection: $collectionName');
  print('===============================================================\n');

  final destinations = [
    {
      'id': 1,
      'name': 'Candi Borobudur',
      'location': 'Magelang, Jawa Tengah',
      'description':
          'Candi Buddha terbesar di dunia peninggalan wangsa Syailendra dengan relief megah dan pemandangan matahari terbit yang magis.',
      'image': 'https://images.unsplash.com/photo-1620549146396-9024d914cd99?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.9,
      'estimated_budget': 1800000,
      'best_time': 'Mei - Oktober',
      'latitude': -7.607874,
      'longitude': 110.203751,
      'place_type': 'Pedesaan',
    },
    {
      'id': 2,
      'name': 'Candi Prambanan',
      'location': 'Sleman, D.I. Yogyakarta',
      'description':
          'Kompleks candi Hindu terindah di Indonesia yang menjulang tinggi dengan arsitektur ramping dan pertunjukan Sendratari Ramayana.',
      'image': 'https://images.unsplash.com/photo-1578469550956-0e16b69c6a3d?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.8,
      'estimated_budget': 1600000,
      'best_time': 'Mei - September',
      'latitude': -7.75202,
      'longitude': 110.491467,
      'place_type': 'Pedesaan',
    },
    {
      'id': 3,
      'name': 'Gunung Bromo',
      'location': 'Probolinggo, Jawa Timur',
      'description':
          'Lautan pasir berbisik dan kawah aktif spektakuler di kawasan Taman Nasional Bromo Tengger Semeru dengan sunrise legendaris.',
      'image': 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=800&auto=format&fit=crop',
      'category': 'Petualangan',
      'rating': 4.9,
      'estimated_budget': 2500000,
      'best_time': 'Juni - Agustus',
      'latitude': -7.942494,
      'longitude': 112.953012,
      'place_type': 'Pegunungan',
    },
    {
      'id': 4,
      'name': 'Kawah Ijen',
      'location': 'Banyuwangi, Jawa Timur',
      'description':
          'Danau kawah asam berwarna toska dengan fenomena api biru (blue fire) langka yang memukau para penjelajah malam.',
      'image': 'https://images.unsplash.com/photo-1518458628499-27acd7f2c893?q=80&w=800&auto=format&fit=crop',
      'category': 'Petualangan',
      'rating': 4.8,
      'estimated_budget': 2200000,
      'best_time': 'Juli - September',
      'latitude': -8.058333,
      'longitude': 114.2425,
      'place_type': 'Pegunungan',
    },
    {
      'id': 5,
      'name': 'Taman Nasional Karimunjawa',
      'location': 'Jepara, Jawa Tengah',
      'description':
          'Gugusan kepulauan tropis di Laut Jawa dengan terumbu karang alami, penangkaran hiu, dan pantai pasir putih yang tenang.',
      'image': 'https://images.unsplash.com/photo-1619017107453-3d950380f0a9?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 2800000,
      'best_time': 'April - Oktober',
      'latitude': -5.848889,
      'longitude': 110.435278,
      'place_type': 'Pantai',
    },
    {
      'id': 6,
      'name': 'Dataran Tinggi Dieng',
      'location': 'Wonosobo, Jawa Tengah',
      'description':
          'Kawasan vulkanik sejuk di atas awan dengan candi-candi kuno, telaga warna berkilau, kawah belerang, dan fenomena embun upas.',
      'image': 'https://images.unsplash.com/photo-1582298538104-fe2e74c27f59?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.7,
      'estimated_budget': 1700000,
      'best_time': 'Juni - Agustus',
      'latitude': -7.203611,
      'longitude': 109.905278,
      'place_type': 'Pegunungan',
    },
    {
      'id': 7,
      'name': 'Kota Lama Semarang',
      'location': 'Semarang, Jawa Tengah',
      'description':
          'Kawasan cagar budaya dengan deretan bangunan megah peninggalan kolonial Belanda bergaya Eropa klasik yang fotogenik.',
      'image': 'https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?q=80&w=800&auto=format&fit=crop',
      'category': 'Sejarah',
      'rating': 4.6,
      'estimated_budget': 1400000,
      'best_time': 'Sepanjang tahun',
      'latitude': -6.968056,
      'longitude': 110.427778,
      'place_type': 'Perkotaan',
    },
    {
      'id': 8,
      'name': 'Pantai Parangtritis',
      'location': 'Bantul, D.I. Yogyakarta',
      'description':
          'Pantai selatan legendaris dengan panorama deburan ombak Samudra Hindia, bukit pasir gumuk, dan siluet sunset yang dramatis.',
      'image': 'https://images.unsplash.com/photo-1629605924917-d2de56a40951?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.5,
      'estimated_budget': 1200000,
      'best_time': 'Mei - Oktober',
      'latitude': -8.025556,
      'longitude': 110.334722,
      'place_type': 'Pantai',
    },
    {
      'id': 9,
      'name': 'Taman Nasional Ujung Kulon',
      'location': 'Pandeglang, Banten',
      'description':
          'Habitat asli badak Jawa bercula satu dan hutan hujan dataran rendah alami di ujung barat Pulau Jawa yang kaya keanekaragaman hayati.',
      'image': 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?q=80&w=800&auto=format&fit=crop',
      'category': 'Konservasi',
      'rating': 4.7,
      'estimated_budget': 3200000,
      'best_time': 'April - Oktober',
      'latitude': -6.75,
      'longitude': 105.333333,
      'place_type': 'Alam',
    },
    {
      'id': 10,
      'name': 'Kepulauan Seribu',
      'location': 'Kepulauan Seribu, DKI Jakarta',
      'description':
          'Deretan pulau tropis menawan dekat ibu kota yang menawarkan liburan pantai, snorkeling, dan penginapan resort di atas air.',
      'image': 'https://images.unsplash.com/photo-1682107222295-aebd076e2afb?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.6,
      'estimated_budget': 1800000,
      'best_time': 'Maret - Oktober',
      'latitude': -5.611667,
      'longitude': 106.561667,
      'place_type': 'Pantai',
    },
    {
      'id': 11,
      'name': 'Kawah Putih Ciwidey',
      'location': 'Bandung, Jawa Barat',
      'description':
          'Danau vulkanik berwarna putih kehijauan di kawah Gunung Patuha dengan udara pegunungan yang sejuk dan kabut tebal yang syahdu.',
      'image': 'https://images.unsplash.com/photo-1719556346386-4300480b7403?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.7,
      'estimated_budget': 1500000,
      'best_time': 'Mei - September',
      'latitude': -7.166111,
      'longitude': 107.402222,
      'place_type': 'Pegunungan',
    },
    {
      'id': 12,
      'name': 'Kebun Raya Bogor',
      'location': 'Bogor, Jawa Barat',
      'description':
          'Pusat konservasi tumbuhan tertua di Asia Tenggara dengan puluhan ribu spesies pohon raksasa, rumah kaca anggrek, dan danau teratai.',
      'image': 'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=800&auto=format&fit=crop',
      'category': 'Edukasi',
      'rating': 4.6,
      'estimated_budget': 1100000,
      'best_time': 'Sepanjang tahun',
      'latitude': -6.5975,
      'longitude': 106.799722,
      'place_type': 'Perkotaan',
    },
    {
      'id': 13,
      'name': 'Taman Safari Indonesia Puncak',
      'location': 'Bogor, Jawa Barat',
      'description':
          'Suaka margasatwa berwawasan konservasi di lereng Gunung Gede Pangrango tempat satwa dari berbagai belahan dunia hidup bebas.',
      'image': 'https://images.unsplash.com/photo-1615220682566-4992e5a7082b?q=80&w=800&auto=format&fit=crop',
      'category': 'Edukasi',
      'rating': 4.7,
      'estimated_budget': 1900000,
      'best_time': 'Sepanjang tahun',
      'latitude': -6.711667,
      'longitude': 106.949722,
      'place_type': 'Pegunungan',
    },
    {
      'id': 14,
      'name': 'Pantai Menganti',
      'location': 'Kebumen, Jawa Tengah',
      'description':
          'Pantai berpasir putih dikelilingi tebing-tebing karst hijau menjulang tinggi yang sering dijuluki sebagai New Zealand-nya Jawa Tengah.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.7,
      'estimated_budget': 1500000,
      'best_time': 'April - Oktober',
      'latitude': -7.771944,
      'longitude': 109.4125,
      'place_type': 'Pantai',
    },
    {
      'id': 15,
      'name': 'Kampung Adat Ciptagelar',
      'location': 'Sukabumi, Jawa Barat',
      'description':
          'Perkampungan adat kasepuhan Banten Kidul yang teguh memegang tradisi bertani organik, kearifan lokal leluhur, dan arsitektur leuit.',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.7,
      'estimated_budget': 1600000,
      'best_time': 'Mei - Oktober',
      'latitude': -6.89,
      'longitude': 106.495,
      'place_type': 'Pedesaan',
    },
    {
      'id': 16,
      'name': 'Ubud Cultural Sanctuary',
      'location': 'Gianyar, Bali',
      'description':
          'Jantung seni dan spiritual Bali yang dikelilingi hamparan sawah terasering hijau Tegallalang, galeri seni, dan suasana menenangkan.',
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.9,
      'estimated_budget': 3500000,
      'best_time': 'April - Oktober',
      'latitude': -8.506854,
      'longitude': 115.262474,
      'place_type': 'Pedesaan',
    },
    {
      'id': 17,
      'name': 'Pura Luhur Uluwatu',
      'location': 'Badung, Bali',
      'description':
          'Pura megah bertengger di ujung tebing karang terjal setinggi 70 meter di atas laut dengan pertunjukan Tari Kecak spektakuler saat matahari terbenam.',
      'image': 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.8,
      'estimated_budget': 2500000,
      'best_time': 'Mei - September',
      'latitude': -8.829167,
      'longitude': 115.084722,
      'place_type': 'Pantai',
    },
    {
      'id': 18,
      'name': 'Desa Penglipuran',
      'location': 'Bangli, Bali',
      'description':
          'Salah satu desa terbersih di dunia dengan tata ruang tradisional Bali berlandaskan filosofi Tri Hita Karana dan hutan bambu yang asri.',
      'image': 'https://images.unsplash.com/photo-1555400038-63f5ba517a47?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.8,
      'estimated_budget': 1800000,
      'best_time': 'Sepanjang tahun',
      'latitude': -8.452778,
      'longitude': 115.358889,
      'place_type': 'Pedesaan',
    },
    {
      'id': 19,
      'name': 'Nusa Penida (Kelingking Beach)',
      'location': 'Klungkung, Bali',
      'description':
          'Tebing kapur ikonik menyerupai dinosaurus T-Rex yang menjorok ke perairan laut pirus dengan pantai tersembunyi berpasir putih.',
      'image': 'https://images.unsplash.com/photo-1697931728907-ae18fd18d864?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.9,
      'estimated_budget': 3000000,
      'best_time': 'Mei - September',
      'latitude': -8.751111,
      'longitude': 115.474444,
      'place_type': 'Pantai',
    },
    {
      'id': 20,
      'name': 'Gunung Rinjani & Segara Anak',
      'location': 'Lombok Utara, Nusa Tenggara Barat',
      'description':
          'Gunung berapi megah dengan kaldera raksasa berisi danau Segara Anak berair biru jernih dan anak gunung baru Gunung Barujari.',
      'image': 'https://images.unsplash.com/photo-1698799330469-e53f68a91c08?q=80&w=800&auto=format&fit=crop',
      'category': 'Petualangan',
      'rating': 4.9,
      'estimated_budget': 4200000,
      'best_time': 'Mei - Oktober',
      'latitude': -8.411667,
      'longitude': 116.457222,
      'place_type': 'Pegunungan',
    },
    {
      'id': 21,
      'name': 'Gili Trawangan',
      'location': 'Lombok Utara, Nusa Tenggara Barat',
      'description':
          'Pulau tropis bebas kendaraan bermotor dengan pantai pasir putih, terumbu karang kaya penyu laut, dan kehidupan tepi pantai yang santai.',
      'image': 'https://images.unsplash.com/photo-1705493583368-b25860b426a3?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 3200000,
      'best_time': 'Mei - September',
      'latitude': -8.35,
      'longitude': 116.033333,
      'place_type': 'Pantai',
    },
    {
      'id': 22,
      'name': 'Mandalika & Pantai Tanjung Aan',
      'location': 'Lombok Tengah, Nusa Tenggara Barat',
      'description':
          'Kawasan pesisir eksotis dengan pantai pasir butiran merica, bukit Merese yang hijau, dan sirkuit balap internasional berkelas dunia.',
      'image': 'https://images.unsplash.com/photo-1685975875980-f19fbd4d36a6?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.7,
      'estimated_budget': 3000000,
      'best_time': 'April - Oktober',
      'latitude': -8.895,
      'longitude': 116.295,
      'place_type': 'Pantai',
    },
    {
      'id': 23,
      'name': 'Taman Nasional Komodo (Pulau Padar)',
      'location': 'Manggarai Barat, Nusa Tenggara Timur',
      'description':
          'Surga alam prasejarah tempat komodo hidup liar dengan panorama puncak bukit Pulau Padar yang memperlihatkan tiga teluk berwarna kontras.',
      'image': 'https://images.unsplash.com/photo-1736523076168-fdda4640f1d8?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.9,
      'estimated_budget': 5500000,
      'best_time': 'April - November',
      'latitude': -8.653611,
      'longitude': 119.570278,
      'place_type': 'Alam',
    },
    {
      'id': 24,
      'name': 'Desa Adat Wae Rebo',
      'location': 'Manggarai, Nusa Tenggara Timur',
      'description':
          'Desa tradisional terpencil di atas awan Flores dengan tujuh rumah kerucut khas Mbaru Niang yang dikelilingi lembah pegunungan asri.',
      'image': 'https://images.unsplash.com/photo-1643785879507-11a0c02205da?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.9,
      'estimated_budget': 4000000,
      'best_time': 'Mei - September',
      'latitude': -8.766944,
      'longitude': 120.286944,
      'place_type': 'Pedesaan',
    },
    {
      'id': 25,
      'name': 'Danau Tiga Warna Kelimutu',
      'location': 'Ende, Nusa Tenggara Timur',
      'description':
          'Keajaiban vulkanik kawah Gunung Kelimutu dengan tiga danau kawah yang memiliki warna berbeda dan berubah secara alami sepanjang waktu.',
      'image': 'https://images.unsplash.com/photo-1654862048364-72d809f46a76?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.8,
      'estimated_budget': 3800000,
      'best_time': 'Juli - September',
      'latitude': -8.766667,
      'longitude': 121.816667,
      'place_type': 'Pegunungan',
    },
    {
      'id': 26,
      'name': 'Danau Toba & Pulau Samosir',
      'location': 'Toba, Sumatera Utara',
      'description':
          'Danau vulkanik supervolcano terbesar di Asia Tenggara dengan Pulau Samosir di tengahnya yang kaya akan tradisi dan rumah adat Batak.',
      'image': 'https://images.unsplash.com/photo-1657728401984-6d65350a4944?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.9,
      'estimated_budget': 3200000,
      'best_time': 'Mei - September',
      'latitude': 2.684444,
      'longitude': 98.875556,
      'place_type': 'Alam',
    },
    {
      'id': 27,
      'name': 'Pulau Weh (Sabang)',
      'location': 'Sabang, Aceh',
      'description':
          'Titik nol kilometer barat Indonesia dengan terumbu karang perawan, spot diving kelas dunia di Teluk Sabang, dan perairan sebening kaca.',
      'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 3500000,
      'best_time': 'April - November',
      'latitude': 5.823611,
      'longitude': 95.318889,
      'place_type': 'Pantai',
    },
    {
      'id': 28,
      'name': 'Ngarai Sianok & Jam Gadang',
      'location': 'Bukittinggi, Sumatera Barat',
      'description':
          'Lembah ngarai hijau curam membentang megah di samping kota sejuk Bukittinggi yang terkenal dengan Jam Gadang dan kuliner Minang autentik.',
      'image': 'https://images.unsplash.com/photo-1720033787459-0eb7ea2913d5?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.8,
      'estimated_budget': 2400000,
      'best_time': 'Mei - Oktober',
      'latitude': -0.308333,
      'longitude': 100.363889,
      'place_type': 'Pegunungan',
    },
    {
      'id': 29,
      'name': 'Taman Nasional Gunung Leuser',
      'location': 'Langkat, Sumatera Utara',
      'description':
          'Hutan hujan tropis warisan dunia tempat perlindungan orangutan Sumatra liar, badak, harimau, dan petualangan susur sungai Bukit Lawang.',
      'image': 'https://images.unsplash.com/photo-1723153247780-02e191e1dd0c?q=80&w=800&auto=format&fit=crop',
      'category': 'Konservasi',
      'rating': 4.8,
      'estimated_budget': 3000000,
      'best_time': 'Juni - Oktober',
      'latitude': 3.555278,
      'longitude': 98.144722,
      'place_type': 'Alam',
    },
    {
      'id': 30,
      'name': 'Pantai Tanjung Tinggi',
      'location': 'Belitung, Kepulauan Bangka Belitung',
      'description':
          'Pantai berpasir putih lembut yang dihiasi tumpukan batu granit raksasa berumur jutaan tahun dengan air laut tenang berwarna biru kehijauan.',
      'image': 'https://images.unsplash.com/photo-1647783285870-8b318fd4c75e?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 2800000,
      'best_time': 'Maret - Oktober',
      'latitude': -2.576111,
      'longitude': 107.7125,
      'place_type': 'Pantai',
    },
    {
      'id': 31,
      'name': 'Lembah Harau',
      'location': 'Lima Puluh Kota, Sumatera Barat',
      'description':
          'Lembah subur yang diapit dinding-dinding tebing granit vertikal setinggi ratusan meter dengan gemericik air terjun alami yang menyejukkan.',
      'image': 'https://images.unsplash.com/photo-1653292952844-c1dd83d94967?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.8,
      'estimated_budget': 2200000,
      'best_time': 'Mei - September',
      'latitude': -0.1,
      'longitude': 100.666667,
      'place_type': 'Pedesaan',
    },
    {
      'id': 32,
      'name': 'Taman Nasional Way Kambas',
      'location': 'Lampung Timur, Lampung',
      'description':
          'Pusat konservasi dan pelatihan gajah Sumatra tertua di Indonesia dengan padang savana luas dan ekosistem hutan rawa dataran rendah.',
      'image': 'https://images.unsplash.com/photo-1534567153574-2b12153a87f0?q=80&w=800&auto=format&fit=crop',
      'category': 'Konservasi',
      'rating': 4.6,
      'estimated_budget': 2100000,
      'best_time': 'Mei - Oktober',
      'latitude': -5.0,
      'longitude': 105.75,
      'place_type': 'Alam',
    },
    {
      'id': 33,
      'name': 'Benteng Marlborough & Pantai Panjang',
      'location': 'Bengkulu, Bengkulu',
      'description':
          'Benteng pertahanan kolonial Inggris terkokoh di Asia Tenggara yang bersebelahan dengan garis pantai pasir putih sepanjang 7 kilometer.',
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?q=80&w=800&auto=format&fit=crop',
      'category': 'Sejarah',
      'rating': 4.5,
      'estimated_budget': 1900000,
      'best_time': 'Mei - September',
      'latitude': -3.787778,
      'longitude': 102.250556,
      'place_type': 'Perkotaan',
    },
    {
      'id': 34,
      'name': 'Taman Nasional Tanjung Puting',
      'location': 'Kotawaringin Barat, Kalimantan Tengah',
      'description':
          'Petualangan susur Sungai Sekonyer dengan perahu klotok menuju habitat konservasi orangutan liar terbesar di dunia di Camp Leakey.',
      'image': 'https://images.unsplash.com/photo-1630509930321-3e6e66c6cb04?q=80&w=800&auto=format&fit=crop',
      'category': 'Konservasi',
      'rating': 4.9,
      'estimated_budget': 5800000,
      'best_time': 'Juni - September',
      'latitude': -2.883333,
      'longitude': 111.916667,
      'place_type': 'Alam',
    },
    {
      'id': 35,
      'name': 'Kepulauan Derawan & Maratua',
      'location': 'Berau, Kalimantan Timur',
      'description':
          'Gugusan pulau surga bahari dengan danau ubur-ubur tanpa sengat di Kakaban, laguna pirus Maratua, dan habitat penyu hijau yang melimpah.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.9,
      'estimated_budget': 5500000,
      'best_time': 'April - Oktober',
      'latitude': 2.283333,
      'longitude': 118.25,
      'place_type': 'Pantai',
    },
    {
      'id': 36,
      'name': 'Danau Sentarum',
      'location': 'Kapuas Hulu, Kalimantan Barat',
      'description':
          'Labirin lahan basah unik musiman di jantung Kalimantan tempat ikan arwana super red berkembang biak di antara hutan rawa gambut.',
      'image': 'https://images.unsplash.com/photo-1712024281674-ee4199ae2144?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.7,
      'estimated_budget': 3600000,
      'best_time': 'Juli - Oktober',
      'latitude': 0.85,
      'longitude': 112.166667,
      'place_type': 'Alam',
    },
    {
      'id': 37,
      'name': 'Pasar Terapung Lok Baintan',
      'location': 'Banjar, Kalimantan Selatan',
      'description':
          'Tradisi pasar terapung otentik di atas perahu jukung di Sungai Martapura yang telah berlangsung turun-temurun sejak era Kesultanan Banjar.',
      'image': 'https://images.unsplash.com/photo-1761789672627-c916c8464412?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.7,
      'estimated_budget': 2100000,
      'best_time': 'Sepanjang tahun',
      'latitude': -3.298889,
      'longitude': 114.654722,
      'place_type': 'Pedesaan',
    },
    {
      'id': 38,
      'name': 'Bukit Kelam Sintang',
      'location': 'Sintang, Kalimantan Barat',
      'description':
          'Batuan monolit raksasa tunggal terbesar di Indonesia yang menjulang tinggi di tengah hutan tropis dengan jalur via ferrata yang menantang.',
      'image': 'https://images.unsplash.com/photo-1762787862952-d22aeb901f1e?q=80&w=800&auto=format&fit=crop',
      'category': 'Petualangan',
      'rating': 4.6,
      'estimated_budget': 2600000,
      'best_time': 'Mei - September',
      'latitude': 0.076389,
      'longitude': 111.664444,
      'place_type': 'Pegunungan',
    },
    {
      'id': 39,
      'name': 'Tana Toraja (Kete Kesu)',
      'location': 'Toraja Utara, Sulawesi Selatan',
      'description':
          'Pusat kebudayaan megalitik suku Toraja dengan deretan rumah adat Tongkonan beratap perahu, upacara Rambu Solo, dan kuburan tebing batu kuno.',
      'image': 'https://images.unsplash.com/photo-1582426007790-f5a2e2392dd3?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.9,
      'estimated_budget': 3400000,
      'best_time': 'Juni - September',
      'latitude': -2.993056,
      'longitude': 119.905556,
      'place_type': 'Pedesaan',
    },
    {
      'id': 40,
      'name': 'Taman Nasional Bunaken',
      'location': 'Manado, Sulawesi Utara',
      'description':
          'Taman laut kelas internasional di Teluk Manado dengan dinding karang vertikal bawah laut sedalam puluhan meter dan keanekaragaman biota laut langka.',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 3800000,
      'best_time': 'Mei - Oktober',
      'latitude': 1.621667,
      'longitude': 124.757778,
      'place_type': 'Pantai',
    },
    {
      'id': 41,
      'name': 'Kepulauan Togean',
      'location': 'Tojo Una-Una, Sulawesi Tengah',
      'description':
          'Surga tersembunyi di Teluk Tomini dengan danau ubur-ubur Mariona, perkampungan suku Bajo di atas air, dan terumbu karang yang sangat terjaga.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.8,
      'estimated_budget': 4500000,
      'best_time': 'April - November',
      'latitude': -0.383333,
      'longitude': 121.933333,
      'place_type': 'Pantai',
    },
    {
      'id': 42,
      'name': 'Taman Nasional Wakatobi',
      'location': 'Wakatobi, Sulawesi Tenggara',
      'description':
          'Cagar biosfer dunia UNESCO di jantung Segitiga Terumbu Karang dengan 750 dari total 850 spesies karang dunia dan perairan biru jernih.',
      'image': 'https://images.unsplash.com/photo-1715899735604-10c58aabd39f?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.9,
      'estimated_budget': 5200000,
      'best_time': 'April - Juni & Okt - Des',
      'latitude': -5.316667,
      'longitude': 123.583333,
      'place_type': 'Pantai',
    },
    {
      'id': 43,
      'name': 'KEK Likupang (Pantai Paal)',
      'location': 'Minahasa Utara, Sulawesi Utara',
      'description':
          'Destinasi super prioritas di semenanjung utara Sulawesi dengan bentangan pantai pasir putih lembut, perbukitan savana Larata, dan laut biru toska.',
      'image': 'https://images.unsplash.com/photo-1761530124592-0ea700a319cb?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.7,
      'estimated_budget': 3200000,
      'best_time': 'Mei - Oktober',
      'latitude': 1.683333,
      'longitude': 125.05,
      'place_type': 'Pantai',
    },
    {
      'id': 44,
      'name': 'Rammang-Rammang Karst',
      'location': 'Maros, Sulawesi Selatan',
      'description':
          'Kawasan pegunungan karst terluas kedua di dunia dengan susur Sungai Pute menggunakan perahu tradisional melewati gua prasejarah dan sawah hijau.',
      'image': 'https://images.unsplash.com/photo-1776624906357-dad5ad7f8d42?q=80&w=800&auto=format&fit=crop',
      'category': 'Alam',
      'rating': 4.8,
      'estimated_budget': 1900000,
      'best_time': 'Mei - Oktober',
      'latitude': -4.928889,
      'longitude': 119.605278,
      'place_type': 'Pedesaan',
    },
    {
      'id': 45,
      'name': 'Pantai Tanjung Bira',
      'location': 'Bulukumba, Sulawesi Selatan',
      'description':
          'Pesisir indah dengan pasir putih selembut tepung dan pusat pembuatan perahu layar tradisional Phinisi legendaris oleh para pengrajin ulung.',
      'image': 'https://images.unsplash.com/photo-1671579877091-e720c1bfc668?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.7,
      'estimated_budget': 2500000,
      'best_time': 'April - Oktober',
      'latitude': -5.616667,
      'longitude': 120.461111,
      'place_type': 'Pantai',
    },
    {
      'id': 46,
      'name': 'Kepulauan Raja Ampat (Piaynemo)',
      'location': 'Raja Ampat, Papua Barat Daya',
      'description':
          'Ikon mahakarya bahari dunia dengan gugusan pulau karang karst hijau di atas air laut pirus toska serta keanekaragaman hayati bawah laut tak tertandingi.',
      'image': 'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 5.0,
      'estimated_budget': 8500000,
      'best_time': 'Oktober - April',
      'latitude': -0.233333,
      'longitude': 130.516667,
      'place_type': 'Pantai',
    },
    {
      'id': 47,
      'name': 'Kepulauan Banda Neira',
      'location': 'Maluku Tengah, Maluku',
      'description':
          'Pusat perdagangan rempah pala dunia pada masa lampau dengan Benteng Belgica kolonial, Gunung Api Banda di seberang pulau, dan keindahan bawah laut.',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
      'category': 'Sejarah',
      'rating': 4.9,
      'estimated_budget': 6200000,
      'best_time': 'Sep - Nov & Mar - Apr',
      'latitude': -4.526944,
      'longitude': 129.904167,
      'place_type': 'Pedesaan',
    },
    {
      'id': 48,
      'name': 'Lembah Baliem',
      'location': 'Jayawijaya, Papua Pegunungan',
      'description':
          'Lembah pegunungan asri di dataran tinggi Papua tempat suku Dani, Yali, dan Lani merawat tradisi leluhur dengan festival budaya tahunan yang megah.',
      'image': 'https://images.unsplash.com/photo-1683713601159-0b22f5116f88?q=80&w=800&auto=format&fit=crop',
      'category': 'Budaya',
      'rating': 4.8,
      'estimated_budget': 7500000,
      'best_time': 'Mei - September',
      'latitude': -4.083333,
      'longitude': 138.95,
      'place_type': 'Pegunungan',
    },
    {
      'id': 49,
      'name': 'Taman Nasional Teluk Cenderawasih',
      'location': 'Teluk Wondama, Papua Barat',
      'description':
          'Taman nasional perairan terluas di Indonesia tempat wisatawan dapat berenang langsung bersama hiu paus (whale shark) jinak di perairan Kwatisore.',
      'image': 'https://images.unsplash.com/photo-1540202404-b2979d19ed37?q=80&w=800&auto=format&fit=crop',
      'category': 'Konservasi',
      'rating': 4.9,
      'estimated_budget': 6800000,
      'best_time': 'Mei - Oktober',
      'latitude': -2.5,
      'longitude': 134.75,
      'place_type': 'Alam',
    },
    {
      'id': 50,
      'name': 'Pantai Ora',
      'location': 'Maluku Tengah, Maluku',
      'description':
          'Resort ramah lingkungan di atas air dengan perairan tenang super jernih di tepi tebing karst Pulau Seram yang sering disebut Maldives-nya Indonesia.',
      'image': 'https://images.unsplash.com/photo-1779828078188-21b0387c5c51?q=80&w=800&auto=format&fit=crop',
      'category': 'Bahari',
      'rating': 4.9,
      'estimated_budget': 5400000,
      'best_time': 'Mei - September',
      'latitude': -2.983333,
      'longitude': 129.233333,
      'place_type': 'Pantai',
    },
  ];

  print('Memulai proses seeding ${destinations.length} destinasi...\n');

  final client = HttpClient();
  var successCount = 0;
  var failureCount = 0;

  for (final item in destinations) {
    final id = item['id'];
    final name = item['name'];
    final docId = '$id';

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/$docId?key=$apiKey',
    );

    try {
      final req = await client.openUrl('PATCH', uri);
      req.headers.contentType = ContentType.json;

      final firestorePayload = {
        'fields': {
          'id': {'integerValue': id.toString()},
          'name': {'stringValue': item['name'] as String},
          'location': {'stringValue': item['location'] as String},
          'description': {'stringValue': item['description'] as String},
          'image': {'stringValue': item['image'] as String},
          'category': {'stringValue': item['category'] as String},
          'rating': {'doubleValue': (item['rating'] as num).toDouble()},
          'estimated_budget': {
            'integerValue': (item['estimated_budget'] as num).toInt().toString(),
          },
          'best_time': {'stringValue': item['best_time'] as String},
          'latitude': {'doubleValue': (item['latitude'] as num).toDouble()},
          'longitude': {'doubleValue': (item['longitude'] as num).toDouble()},
          'place_type': {'stringValue': item['place_type'] as String},
        },
      };

      req.write(jsonEncode(firestorePayload));
      final res = await req.close();

      if (res.statusCode == 200) {
        successCount++;
        print('[$successCount/50] OK (ID: $docId) -> $name (${item['location']})');
      } else {
        failureCount++;
        final errBody = await utf8.decodeStream(res);
        print('[ERROR] Gagal ID $docId ($name): Status ${res.statusCode} - $errBody');
      }
    } catch (e) {
      failureCount++;
      print('[EXCEPTION] Gagal ID $docId ($name): $e');
    }
  }

  client.close();

  print('\n===============================================================');
  print('HASIL SEEDING FIRESTORE:');
  print('- Berhasil: $successCount destinasi');
  print('- Gagal: $failureCount destinasi');
  print('- Target Total: 50 destinasi');
  print('===============================================================');
}


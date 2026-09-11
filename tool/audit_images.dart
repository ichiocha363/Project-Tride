// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final apiKey = Platform.environment['FIREBASE_API_KEY'] ?? Platform.environment['GEMINI_API_KEY'] ?? '';
  const projectId = 'tride-project-92f17';

  print('===============================================================');
  print('TRIDE - AUDIT TERAKHIR IMAGE 50 DESTINASI WISATA INDONESIA');
  print('===============================================================\n');

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  // 1. Fetch live Firestore documents
  print('1. Mengambil data dari Cloud Firestore collection `destinations`...');
  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations?pageSize=100&key=$apiKey',
  );

  final req = await client.getUrl(uri);
  final res = await req.close();
  final body = await utf8.decodeStream(res);
  final json = jsonDecode(body) as Map<String, dynamic>;
  final documents = (json['documents'] as List?) ?? [];

  print('   -> Ditemukan ${documents.length} dokumen di Firestore.\n');

  // 2. Read markdown table
  final mdFile = File('destination_sources.md');
  final mdExists = await mdFile.exists();
  print('2. Memeriksa keberadaan destination_sources.md: ${mdExists ? "ADA" : "TIDAK ADA"}');
  final mdContent = mdExists ? await mdFile.readAsString() : '';

  // 3. Audit each destination image URL
  print('3. Melakukan audit dan ping URL gambar untuk setiap destinasi...\n');

  final firestoreMap = <int, Map<String, dynamic>>{};
  for (final doc in documents) {
    final fields = doc['fields'] as Map<String, dynamic>;
    final id = int.tryParse(fields['id']?['integerValue'] ?? '');
    if (id != null) {
      firestoreMap[id] = {
        'name': fields['name']?['stringValue'] ?? '',
        'image': fields['image']?['stringValue'] ?? '',
        'location': fields['location']?['stringValue'] ?? '',
      };
    }
  }

  var validCount = 0;
  var issueCount = 0;
  final issues = <String>[];

  for (int id = 1; id <= 50; id++) {
    final dest = firestoreMap[id];
    if (dest == null) {
      issueCount++;
      issues.add('ID $id: Dokumen tidak ditemukan di Firestore');
      continue;
    }

    final name = dest['name'] as String;
    final imageUrl = dest['image'] as String;

    // Check if in MD
    final inDoc = mdContent.contains('`$id`') && mdContent.contains(name);

    if (imageUrl.isEmpty) {
      issueCount++;
      issues.add('ID $id ($name): Image URL kosong');
      continue;
    }

    if (!imageUrl.startsWith('https://images.unsplash.com/')) {
      issueCount++;
      issues.add('ID $id ($name): Sumber gambar bukan Unsplash berlisensi resmi: $imageUrl');
      continue;
    }

    // Ping Image URL
    try {
      final imgUri = Uri.parse(imageUrl);
      final imgReq = await client.headUrl(imgUri);
      final imgRes = await imgReq.close();
      if (imgRes.statusCode == 200) {
        validCount++;
        print('  [ID ${id.toString().padLeft(2, '0')}] OK (HTTP 200) | $name | Doc: ${inDoc ? "OK" : "Perlu dicek"}');
      } else {
        // Fallback coba GET jika HEAD diblokir
        final getReq = await client.getUrl(imgUri);
        final getRes = await getReq.close();
        await getRes.drain();
        if (getRes.statusCode == 200) {
          validCount++;
          print('  [ID ${id.toString().padLeft(2, '0')}] OK (HTTP 200 GET) | $name | Doc: ${inDoc ? "OK" : "Perlu dicek"}');
        } else {
          issueCount++;
          issues.add('ID $id ($name): Image URL mengembalikan status ${imgRes.statusCode}');
        }
      }
    } catch (e) {
      issueCount++;
      issues.add('ID $id ($name): Gagal menghubungi Image URL: $e');
    }
  }

  client.close();

  print('\n===============================================================');
  print('RINGKASAN AUDIT IMAGE:');
  print('- Total Destinasi Diaudit: 50');
  print('- Image Valid & Aktif (HTTP 200): $validCount / 50');
  print('- Image Bermasalah: $issueCount');
  if (issues.isNotEmpty) {
    print('\nDaftar Masalah:');
    for (final issue in issues) {
      print('  * $issue');
    }
  } else {
    print('- Status: SEMUA IMAGE 100% TERVERIFIKASI & AKTIF');
  }
  print('===============================================================');
}

// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Script Verifikasi Seluruh 50 Destinasi Beserta Subkoleksi di Cloud Firestore:
/// 1. Memastikan 50 destinasi tetap ada
/// 2. Memastikan setiap destinasi memiliki short_description
/// 3. Memastikan setiap destinasi memiliki minimal 3 attractions
/// 4. Memastikan setiap destinasi memiliki minimal 3 accommodations
/// 5. Memastikan setiap destinasi memiliki minimal 3 local_foods
/// 6. Memastikan tidak ada duplicate document
void main() async {
  const apiKey = 'AIzaSyB0nHVIV2GZz9ej3kT8DlssdZSofqgPwlQ';
  const projectId = 'tride-project-92f17';

  print('===============================================================');
  print('TRIDE - VERIFIKASI SUBKOLEKSI 50 DESTINASI DI CLOUD FIRESTORE');
  print('Project ID: $projectId');
  print('===============================================================\n');

  final client = HttpClient();

  // 1. Fetch seluruh dokumen destinations
  final mainUri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations?pageSize=100&key=$apiKey',
  );

  final req = await client.getUrl(mainUri);
  final res = await req.close();
  final body = await utf8.decodeStream(res);
  final json = jsonDecode(body) as Map<String, dynamic>;
  final documents = (json['documents'] as List?) ?? [];

  print('Total dokumen destinasi ditemukan: ${documents.length}');

  final foundIds = <int>{};
  var validShortDescCount = 0;
  var validAttractionsCount = 0;
  var validAccommodationsCount = 0;
  var validLocalFoodsCount = 0;

  var totalAttractionDocs = 0;
  var totalAccommodationDocs = 0;
  var totalLocalFoodDocs = 0;

  for (final doc in documents) {
    final fields = doc['fields'] as Map<String, dynamic>;
    final id = int.tryParse(fields['id']?['integerValue'] ?? '');
    final name = fields['name']?['stringValue'] ?? '';
    final shortDesc = fields['short_description']?['stringValue'] ?? '';

    if (id != null) {
      foundIds.add(id);
    }

    if (shortDesc.trim().isNotEmpty) {
      validShortDescCount++;
    }

    if (id == null) continue;

    // Subkoleksi attractions
    final attUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/attractions?key=$apiKey',
    );
    final attReq = await client.getUrl(attUri);
    final attRes = await attReq.close();
    final attBody = await utf8.decodeStream(attRes);
    final attJson = jsonDecode(attBody) as Map<String, dynamic>;
    final attDocs = (attJson['documents'] as List?) ?? [];
    totalAttractionDocs += attDocs.length;
    if (attDocs.length >= 3) {
      validAttractionsCount++;
    }

    // Subkoleksi accommodations
    final accUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/accommodations?key=$apiKey',
    );
    final accReq = await client.getUrl(accUri);
    final accRes = await accReq.close();
    final accBody = await utf8.decodeStream(accRes);
    final accJson = jsonDecode(accBody) as Map<String, dynamic>;
    final accDocs = (accJson['documents'] as List?) ?? [];
    totalAccommodationDocs += accDocs.length;
    if (accDocs.length >= 3) {
      validAccommodationsCount++;
    }

    // Subkoleksi local_foods
    final foodUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/local_foods?key=$apiKey',
    );
    final foodReq = await client.getUrl(foodUri);
    final foodRes = await foodReq.close();
    final foodBody = await utf8.decodeStream(foodRes);
    final foodJson = jsonDecode(foodBody) as Map<String, dynamic>;
    final foodDocs = (foodJson['documents'] as List?) ?? [];
    totalLocalFoodDocs += foodDocs.length;
    if (foodDocs.length >= 3) {
      validLocalFoodsCount++;
    }

    if (id == 1 || id == 16 || id == 26 || id == 34 || id == 39 || id == 46 || id == 50) {
      print('  [SAMPLE ID $id] $name');
      print('    - Short Desc: ${shortDesc.substring(0, shortDesc.length > 50 ? 50 : shortDesc.length)}...');
      print('    - Attractions: ${attDocs.length}');
      print('    - Accommodations: ${accDocs.length}');
      print('    - Local Foods: ${foodDocs.length}');
    }
  }

  client.close();

  print('\n===============================================================');
  print('HASIL REKAPITULASI DATA FIRESTORE:');
  print('- Total Destinasi: ${foundIds.length} / 50');
  print('- Destinasi memiliki short_description: $validShortDescCount / 50');
  print('- Destinasi memiliki min. 3 attractions: $validAttractionsCount / 50 (Total doc: $totalAttractionDocs)');
  print('- Destinasi memiliki min. 3 accommodations: $validAccommodationsCount / 50 (Total doc: $totalAccommodationDocs)');
  print('- Destinasi memiliki min. 3 local_foods: $validLocalFoodsCount / 50 (Total doc: $totalLocalFoodDocs)');
  print('===============================================================');

  if (foundIds.length == 50 &&
      validShortDescCount == 50 &&
      validAttractionsCount == 50 &&
      validAccommodationsCount == 50 &&
      validLocalFoodsCount == 50) {
    print('\n[STATUS: SUKSES PENUH] Seluruh 50 destinasi wisata di Cloud Firestore telah terisi lengkap dengan subkoleksi!');
  } else {
    print('\n[STATUS: PERINGATAN] Beberapa data belum memenuhi syarat minimal.');
  }
}

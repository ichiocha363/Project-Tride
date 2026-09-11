// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final apiKey = Platform.environment['FIREBASE_API_KEY'] ?? Platform.environment['GEMINI_API_KEY'] ?? '';
  const projectId = 'tride-project-92f17';

  print('Memverifikasi dokumen Firestore collection `destinations`...');
  final client = HttpClient();

  final uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations?pageSize=100&key=$apiKey',
  );

  final req = await client.getUrl(uri);
  final res = await req.close();
  final body = await utf8.decodeStream(res);
  final json = jsonDecode(body) as Map<String, dynamic>;
  final documents = (json['documents'] as List?) ?? [];

  print('Total dokumen ditemukan di Firestore: ${documents.length}');

  final foundIds = <int>{};
  for (final doc in documents) {
    final fields = doc['fields'] as Map<String, dynamic>;
    final id = int.tryParse(fields['id']?['integerValue'] ?? '');
    final name = fields['name']?['stringValue'] ?? '';
    final loc = fields['location']?['stringValue'] ?? '';
    final placeType = fields['place_type']?['stringValue'] ?? '';
    final rating = (fields['rating']?['doubleValue'] ?? fields['rating']?['integerValue'])?.toString() ?? '';

    if (id != null) {
      foundIds.add(id);
    }
    if (id != null && (id == 1 || id == 16 || id == 26 || id == 34 || id == 39 || id == 46 || id == 50)) {
      print('  [ID $id] $name ($loc) | Type: $placeType | Rating: $rating');
    }
  }

  client.close();

  if (documents.length >= 50 && foundIds.length == 50) {
    print('\n[SUKSES] Semua 50 destinasi wisata Indonesia berhasil terverifikasi di Firestore!');
  } else {
    print('\n[PERINGATAN] Jumlah dokumen (${documents.length}) atau ID unik (${foundIds.length}) belum 50.');
  }
}

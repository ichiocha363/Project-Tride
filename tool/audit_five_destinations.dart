// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  const apiKey = 'AIzaSyB0nHVIV2GZz9ej3kT8DlssdZSofqgPwlQ';
  const projectId = 'tride-project-92f17';
  final sampleIds = [1, 2, 3, 16, 46];

  for (final id in sampleIds) {
    print('================================================================');
    print('AUDIT DESTINATION ID $id');
    print('================================================================');
    
    // Dest doc
    final destUri = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id?key=$apiKey');
    final req = await client.getUrl(destUri);
    final res = await req.close();
    final json = jsonDecode(await utf8.decodeStream(res)) as Map<String, dynamic>;
    final name = json['fields']?['name']?['stringValue'];
    final shortDesc = json['fields']?['short_description']?['stringValue'];
    print('Name: $name');
    print('Short Desc: $shortDesc');

    // Attractions
    final attUri = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/attractions?key=$apiKey');
    final reqAtt = await client.getUrl(attUri);
    final resAtt = await reqAtt.close();
    final jsonAtt = jsonDecode(await utf8.decodeStream(resAtt)) as Map<String, dynamic>;
    final attDocs = (jsonAtt['documents'] as List?) ?? [];
    print('Attractions (${attDocs.length}):');
    for (final doc in attDocs) {
      final fields = doc['fields'] as Map<String, dynamic>;
      print('  - ${fields['name']?['stringValue']} (${fields['category']?['stringValue']}) - Biaya: ${fields['estimated_cost']?['integerValue']}');
    }

    // Accommodations
    final accUri = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/accommodations?key=$apiKey');
    final reqAcc = await client.getUrl(accUri);
    final resAcc = await reqAcc.close();
    final jsonAcc = jsonDecode(await utf8.decodeStream(resAcc)) as Map<String, dynamic>;
    final accDocs = (jsonAcc['documents'] as List?) ?? [];
    print('Accommodations (${accDocs.length}):');
    for (final doc in accDocs) {
      final fields = doc['fields'] as Map<String, dynamic>;
      print('  - ${fields['name']?['stringValue']} (${fields['type']?['stringValue']}) - Rating: ${fields['rating']?['doubleValue']} - Harga: ${fields['price_range']?['stringValue']}');
    }

    // Local foods
    final foodUri = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$id/local_foods?key=$apiKey');
    final reqFood = await client.getUrl(foodUri);
    final resFood = await reqFood.close();
    final jsonFood = jsonDecode(await utf8.decodeStream(resFood)) as Map<String, dynamic>;
    final foodDocs = (jsonFood['documents'] as List?) ?? [];
    print('Local Foods (${foodDocs.length}):');
    for (final doc in foodDocs) {
      final fields = doc['fields'] as Map<String, dynamic>;
      print('  - ${fields['name']?['stringValue']} - Lokasi: ${fields['location']?['stringValue']} - Harga: ${fields['price_range']?['stringValue']}');
    }
    print('');
  }
  client.close();
}

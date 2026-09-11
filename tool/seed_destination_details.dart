// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'destination_details_data.dart';

/// Script Seeding Detail Destinasi (Short Description & Subkoleksi) ke Cloud Firestore:
/// - destinations/{id} -> short_description
/// - destinations/{id}/attractions/{1..3}
/// - destinations/{id}/accommodations/{1..3}
/// - destinations/{id}/local_foods/{1..3}
void main() async {
  final apiKey = Platform.environment['FIREBASE_API_KEY'] ?? Platform.environment['GEMINI_API_KEY'] ?? '';
  const projectId = 'tride-project-92f17';

  print('===============================================================');
  print('TRIDE - SEED DETAIL 50 DESTINASI KE FIRESTORE (FAST CONCURRENT)');
  print('Project ID: $projectId');
  print('Total Destinasi: ${destinationDetailsData.length}');
  print('===============================================================\n');

  final client = HttpClient();
  var totalShortDescOk = 0;
  var totalAttractionsOk = 0;
  var totalAccommodationsOk = 0;
  var totalLocalFoodsOk = 0;
  var errorsCount = 0;

  Future<void> processDestination(DestinationDetailEntry entry) async {
    final docId = '${entry.id}';

    // 1. Patch short_description ke dokumen destinasi
    final destUri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$docId?updateMask.fieldPaths=short_description&key=$apiKey',
    );

    final futures = <Future<void>>[];

    futures.add(() async {
      try {
        final req = await client.openUrl('PATCH', destUri);
        req.headers.contentType = ContentType.json;
        final payload = {
          'fields': {
            'short_description': {'stringValue': entry.shortDescription},
          },
        };
        req.write(jsonEncode(payload));
        final res = await req.close();
        if (res.statusCode == 200) {
          totalShortDescOk++;
        } else {
          errorsCount++;
          final err = await utf8.decodeStream(res);
          print('  [ERROR] short_description ID $docId: $err');
        }
      } catch (e) {
        errorsCount++;
        print('  [EXCEPTION] short_description ID $docId: $e');
      }
    }());

    // 2. Subkoleksi attractions
    for (int i = 0; i < entry.attractions.length; i++) {
      final item = entry.attractions[i];
      final attId = item['id']?.toString() ?? '${i + 1}';
      final attUri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$docId/attractions/$attId?key=$apiKey',
      );

      futures.add(() async {
        try {
          final req = await client.openUrl('PATCH', attUri);
          req.headers.contentType = ContentType.json;
          final payload = {
            'fields': {
              'name': {'stringValue': item['name'] as String},
              'description': {'stringValue': item['description'] as String},
              'image': {'stringValue': item['image'] as String},
              'category': {'stringValue': item['category'] as String},
              'estimated_cost': {
                'integerValue': ((item['estimated_cost'] as num?)?.toInt() ?? 0).toString(),
              },
              if (item['source'] != null)
                'source': {'stringValue': item['source'] as String},
            },
          };
          req.write(jsonEncode(payload));
          final res = await req.close();
          if (res.statusCode == 200) {
            totalAttractionsOk++;
          } else {
            errorsCount++;
            final err = await utf8.decodeStream(res);
            print('  [ERROR] attraction $attId ID $docId: $err');
          }
        } catch (e) {
          errorsCount++;
          print('  [EXCEPTION] attraction $attId ID $docId: $e');
        }
      }());
    }

    // 3. Subkoleksi accommodations
    for (int i = 0; i < entry.accommodations.length; i++) {
      final item = entry.accommodations[i];
      final accId = item['id']?.toString() ?? '${i + 1}';
      final accUri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$docId/accommodations/$accId?key=$apiKey',
      );

      futures.add(() async {
        try {
          final req = await client.openUrl('PATCH', accUri);
          req.headers.contentType = ContentType.json;
          final payload = {
            'fields': {
              'name': {'stringValue': item['name'] as String},
              'type': {'stringValue': item['type'] as String},
              'location': {'stringValue': item['location'] as String},
              'price_range': {'stringValue': item['price_range'] as String},
              'rating': {'doubleValue': ((item['rating'] as num?)?.toDouble() ?? 0.0)},
              'image': {'stringValue': item['image'] as String},
              if (item['source'] != null)
                'source': {'stringValue': item['source'] as String},
            },
          };
          req.write(jsonEncode(payload));
          final res = await req.close();
          if (res.statusCode == 200) {
            totalAccommodationsOk++;
          } else {
            errorsCount++;
            final err = await utf8.decodeStream(res);
            print('  [ERROR] accommodation $accId ID $docId: $err');
          }
        } catch (e) {
          errorsCount++;
          print('  [EXCEPTION] accommodation $accId ID $docId: $e');
        }
      }());
    }

    // 4. Subkoleksi local_foods
    for (int i = 0; i < entry.localFoods.length; i++) {
      final item = entry.localFoods[i];
      final foodId = item['id']?.toString() ?? '${i + 1}';
      final foodUri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/destinations/$docId/local_foods/$foodId?key=$apiKey',
      );

      futures.add(() async {
        try {
          final req = await client.openUrl('PATCH', foodUri);
          req.headers.contentType = ContentType.json;
          final payload = {
            'fields': {
              'name': {'stringValue': item['name'] as String},
              'description': {'stringValue': item['description'] as String},
              'price_range': {'stringValue': item['price_range'] as String},
              'location': {'stringValue': item['location'] as String},
              'image': {'stringValue': item['image'] as String},
              if (item['source'] != null)
                'source': {'stringValue': item['source'] as String},
            },
          };
          req.write(jsonEncode(payload));
          final res = await req.close();
          if (res.statusCode == 200) {
            totalLocalFoodsOk++;
          } else {
            errorsCount++;
            final err = await utf8.decodeStream(res);
            print('  [ERROR] local_food $foodId ID $docId: $err');
          }
        } catch (e) {
          errorsCount++;
          print('  [EXCEPTION] local_food $foodId ID $docId: $e');
        }
      }());
    }

    await Future.wait(futures);
    print('  [Destinasi ID $docId] Selesai diperbarui.');
  }

  // Process in chunks of 5 destinations
  const chunkSize = 5;
  for (var i = 0; i < destinationDetailsData.length; i += chunkSize) {
    final end = (i + chunkSize < destinationDetailsData.length) ? i + chunkSize : destinationDetailsData.length;
    final chunk = destinationDetailsData.sublist(i, end);
    print('Memproses destinasi ID ${chunk.first.id} sampai ${chunk.last.id}...');
    await Future.wait(chunk.map((e) => processDestination(e)));
  }

  client.close();

  print('\n===============================================================');
  print('HASIL SEEDING SUBCOLLECTIONS FIRESTORE:');
  print('- Short Descriptions Berhasil: $totalShortDescOk / 50');
  print('- Attractions Berhasil: $totalAttractionsOk / 150');
  print('- Accommodations Berhasil: $totalAccommodationsOk / 150');
  print('- Local Foods Berhasil: $totalLocalFoodsOk / 150');
  print('- Total Errors: $errorsCount');
  print('===============================================================');
}

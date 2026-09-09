import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/destination_model.dart';
import '../tool/destinations_data.dart';

void main() {
  group('50 Real Indonesian Destinations Dataset Validation', () {
    test('Total destination count must be exactly 50', () {
      expect(realIndonesianDestinations.length, 50);
    });

    test('All IDs must be unique from 1 to 50', () {
      final ids = realIndonesianDestinations.map((d) => d.id).toSet();
      expect(ids.length, 50);
      for (int i = 1; i <= 50; i++) {
        expect(ids.contains(i), isTrue, reason: 'Missing destination ID: $i');
      }
    });

    test('All destination names must be unique and non-empty', () {
      final names = realIndonesianDestinations.map((d) => d.name.trim()).toSet();
      expect(names.length, 50, reason: 'Duplicate destination names detected');
      for (final dest in realIndonesianDestinations) {
        expect(dest.name.isNotEmpty, isTrue);
        expect(dest.location.isNotEmpty, isTrue);
        expect(dest.description.isNotEmpty, isTrue);
        expect(dest.image.startsWith('https://'), isTrue);
        expect(dest.rating, inInclusiveRange(4.0, 5.0));
        expect(dest.estimatedBudget, greaterThan(500000));
        expect(dest.bestTime != null && dest.bestTime!.isNotEmpty, isTrue);
        expect(dest.latitude != null && dest.latitude!.isFinite, isTrue);
        expect(dest.longitude != null && dest.longitude!.isFinite, isTrue);
        expect(
          ['Pantai', 'Pegunungan', 'Perkotaan', 'Pedesaan', 'Alam']
              .contains(dest.placeType),
          isTrue,
          reason: 'Invalid placeType: ${dest.placeType} for ${dest.name}',
        );
      }
    });

    test('Regional distribution matches specifications', () {
      // Java: 1 - 15 (15)
      final java = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 1 && (d.id ?? 0) <= 15).toList();
      expect(java.length, 15, reason: 'Java must have 15 destinations');

      // Bali & Nusa Tenggara: 16 - 25 (10)
      final baliNusa = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 16 && (d.id ?? 0) <= 25).toList();
      expect(baliNusa.length, 10, reason: 'Bali & Nusa Tenggara must have 10 destinations');

      // Sumatra: 26 - 33 (8)
      final sumatra = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 26 && (d.id ?? 0) <= 33).toList();
      expect(sumatra.length, 8, reason: 'Sumatra must have 8 destinations');

      // Kalimantan: 34 - 38 (5)
      final kalimantan = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 34 && (d.id ?? 0) <= 38).toList();
      expect(kalimantan.length, 5, reason: 'Kalimantan must have 5 destinations');

      // Sulawesi: 39 - 45 (7)
      final sulawesi = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 39 && (d.id ?? 0) <= 45).toList();
      expect(sulawesi.length, 7, reason: 'Sulawesi must have 7 destinations');

      // Maluku & Papua: 46 - 50 (5)
      final malukuPapua = realIndonesianDestinations.where((d) => (d.id ?? 0) >= 46 && (d.id ?? 0) <= 50).toList();
      expect(malukuPapua.length, 5, reason: 'Maluku & Papua must have 5 destinations');
    });

    test('DestinationModel serialization and fromFirestoreData roundtrip', () {
      for (final dest in realIndonesianDestinations) {
        final map = dest.toMap();
        final fromMap = DestinationModel.fromMap(map);
        expect(fromMap.id, dest.id);
        expect(fromMap.name, dest.name);
        expect(fromMap.placeType, dest.placeType);
        expect(fromMap.rating, dest.rating);

        final fromFirestore = DestinationModel.fromFirestoreData(map, dest.id);
        expect(fromFirestore.id, dest.id);
        expect(fromFirestore.name, dest.name);
        expect(fromFirestore.placeType, dest.placeType);
        expect(fromFirestore.rating, dest.rating);
      }
    });
  });
}

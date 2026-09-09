import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/attraction_model.dart';
import 'package:project_tride/Database/accommodation_model.dart';
import 'package:project_tride/Database/local_food_model.dart';
import '../tool/destination_details_data.dart';

void main() {
  group('Destination Details Models Tests', () {
    test('AttractionModel serialization test', () {
      final attraction = AttractionModel(
        id: 'attr_1',
        name: 'Stupa Utama Borobudur',
        description: 'Stupa terbesar di puncak candi dengan pemandangan lembah Manoreh.',
        image: 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?w=600',
        category: 'Budaya',
        estimatedCost: 180000,
        source: 'Indonesia.travel',
      );

      final map = attraction.toMap();
      expect(map['name'], 'Stupa Utama Borobudur');
      expect(map['category'], 'Budaya');
      expect(map['estimated_cost'], 180000);
      expect(map['source'], 'Indonesia.travel');

      final fromMap = AttractionModel.fromMap(map, 'attr_1');
      expect(fromMap.id, 'attr_1');
      expect(fromMap.name, 'Stupa Utama Borobudur');
      expect(fromMap.estimatedCost, 180000);
      expect(fromMap.category, 'Budaya');
    });

    test('AccommodationModel serialization test', () {
      final hotel = AccommodationModel(
        id: 'acc_1',
        name: 'Plataran Borobudur Resort & Spa',
        type: 'Resort',
        location: 'Borobudur, Magelang',
        priceRange: 'Rp 3.500.000 - Rp 7.000.000 / malam',
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
        source: 'Indonesia.travel',
      );

      final map = hotel.toMap();
      expect(map['name'], 'Plataran Borobudur Resort & Spa');
      expect(map['type'], 'Resort');
      expect(map['price_range'], 'Rp 3.500.000 - Rp 7.000.000 / malam');
      expect(map['rating'], 4.8);

      final fromMap = AccommodationModel.fromMap(map, 'acc_1');
      expect(fromMap.id, 'acc_1');
      expect(fromMap.name, 'Plataran Borobudur Resort & Spa');
      expect(fromMap.rating, 4.8);
    });

    test('LocalFoodModel serialization test', () {
      final food = LocalFoodModel(
        id: 'food_1',
        name: 'Mangut Beong Borobudur',
        description: 'Olahan ikan beong khas Sungai Progo dengan kuah santan pedas gurih.',
        priceRange: 'Rp 25.000 - Rp 50.000 / porsi',
        location: 'Borobudur, Magelang',
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
        source: 'Dinas Pariwisata Jawa Tengah',
      );

      final map = food.toMap();
      expect(map['name'], 'Mangut Beong Borobudur');
      expect(map['price_range'], 'Rp 25.000 - Rp 50.000 / porsi');
      expect(map['location'], 'Borobudur, Magelang');

      final fromMap = LocalFoodModel.fromMap(map, 'food_1');
      expect(fromMap.id, 'food_1');
      expect(fromMap.name, 'Mangut Beong Borobudur');
    });

    test('DestinationModel with shortDescription', () {
      final dest = DestinationModel(
        id: 1,
        name: 'Candi Borobudur',
        location: 'Magelang, Jawa Tengah',
        description: 'Candi Buddha mahakarya abad ke-8.',
        shortDescription: 'Mahakarya candi Buddha terbesar di dunia peninggalan Dinasti Syailendra.',
        image: 'https://example.com/borobudur.jpg',
        category: 'Budaya',
      );

      expect(dest.shortDescription, isNotNull);
      final map = dest.toMap();
      expect(map['short_description'], 'Mahakarya candi Buddha terbesar di dunia peninggalan Dinasti Syailendra.');

      final fromMap = DestinationModel.fromMap(map);
      expect(fromMap.shortDescription, 'Mahakarya candi Buddha terbesar di dunia peninggalan Dinasti Syailendra.');

      final updated = dest.copyWith(shortDescription: 'Deskripsi baru');
      expect(updated.shortDescription, 'Deskripsi baru');
    });
  });

  group('Destination Details Dataset (50 Destinations) Integrity', () {
    test('Dataset contains all 50 destinations', () {
      expect(destinationDetailsData.length, 50);
      final ids = destinationDetailsData.map((e) => e.id).toSet();
      expect(ids.length, 50);
      for (int i = 1; i <= 50; i++) {
        expect(ids.contains(i), isTrue,
            reason: 'Missing destination detail entry for ID: $i');
      }
    });

    test('All destinations have valid short_description and >= 3 attractions, accommodations, local_foods', () {
      int totalAttractions = 0;
      int totalAccommodations = 0;
      int totalLocalFoods = 0;

      final map = {for (final e in destinationDetailsData) e.id: e};

      for (int id = 1; id <= 50; id++) {
        final entry = map[id]!;
        expect(entry.shortDescription.trim().isNotEmpty, isTrue,
            reason: 'Destination $id shortDescription is empty');
        
        expect(entry.attractions.length, greaterThanOrEqualTo(3),
            reason: 'Destination $id has less than 3 attractions');
        expect(entry.accommodations.length, greaterThanOrEqualTo(3),
            reason: 'Destination $id has less than 3 accommodations');
        expect(entry.localFoods.length, greaterThanOrEqualTo(3),
            reason: 'Destination $id has less than 3 local foods');

        for (final attr in entry.attractions) {
          expect(attr['name'].toString().isNotEmpty, isTrue);
          expect(attr['description'].toString().isNotEmpty, isTrue);
          expect(attr['image'].toString().startsWith('https://'), isTrue);
          expect(attr['category'].toString().isNotEmpty, isTrue);
          expect(attr['estimated_cost'], isNotNull);

          // Test model instantiation
          final model = AttractionModel.fromMap(attr);
          expect(model.name, attr['name']);
        }

        for (final acc in entry.accommodations) {
          expect(acc['name'].toString().isNotEmpty, isTrue);
          expect(acc['type'].toString().isNotEmpty, isTrue);
          expect(acc['location'].toString().isNotEmpty, isTrue);
          expect(acc['price_range'].toString().isNotEmpty, isTrue);
          expect(acc['image'].toString().startsWith('https://'), isTrue);
          expect((acc['rating'] as num).toDouble(), inInclusiveRange(3.5, 5.0));

          // Test model instantiation
          final model = AccommodationModel.fromMap(acc);
          expect(model.name, acc['name']);
        }

        for (final food in entry.localFoods) {
          expect(food['name'].toString().isNotEmpty, isTrue);
          expect(food['description'].toString().isNotEmpty, isTrue);
          expect(food['price_range'].toString().isNotEmpty, isTrue);
          expect(food['location'].toString().isNotEmpty, isTrue);
          expect(food['image'].toString().startsWith('https://'), isTrue);

          // Test model instantiation
          final model = LocalFoodModel.fromMap(food);
          expect(model.name, food['name']);
        }

        totalAttractions += entry.attractions.length;
        totalAccommodations += entry.accommodations.length;
        totalLocalFoods += entry.localFoods.length;
      }

      expect(totalAttractions, greaterThanOrEqualTo(150));
      expect(totalAccommodations, greaterThanOrEqualTo(150));
      expect(totalLocalFoods, greaterThanOrEqualTo(150));
    });

    test('Distinct destination IDs produce unique subcollections without cross-pollution', () {
      final map = {for (final e in destinationDetailsData) e.id: e};

      // Check Borobudur (1) vs Prambanan (2) vs Bromo (3) vs Ubud (16) vs Raja Ampat (46)
      final borobudur = map[1]!;
      final prambanan = map[2]!;
      final bromo = map[3]!;
      final ubud = map[16]!;
      final toba = map[26]!;
      final rajaAmpat = map[46]!;

      // 1. Borobudur specific
      expect(borobudur.attractions.any((a) => a['name'].toString().contains('Candirejo') || a['name'].toString().contains('Setumbu')), isTrue);
      expect(borobudur.localFoods.any((f) => f['name'].toString().contains('Mangut Beong')), isTrue);
      expect(borobudur.localFoods.any((f) => f['name'].toString().contains('Papeda')), isFalse);

      // 2. Prambanan specific
      expect(prambanan.attractions.any((a) => a['name'].toString().contains('Ramayana') || a['name'].toString().contains('Ratu Boko')), isTrue);
      expect(prambanan.localFoods.any((f) => f['name'].toString().contains('Kalasan')), isTrue);
      expect(prambanan.localFoods.any((f) => f['name'].toString().contains('Mangut Beong')), isFalse);

      // 3. Bromo specific
      expect(bromo.attractions.any((a) => a['name'].toString().contains('Penanjakan') || a['name'].toString().contains('Pasir Berbisik')), isTrue);
      expect(bromo.localFoods.any((f) => f['name'].toString().contains('Pokak') || f['name'].toString().contains('Rawon')), isTrue);
      expect(bromo.localFoods.any((f) => f['name'].toString().contains('Mangut Beong')), isFalse);

      // 4. Ubud specific
      expect(ubud.attractions.any((a) => a['name'].toString().contains('Tegalalang') || a['name'].toString().contains('Monkey Forest')), isTrue);
      expect(ubud.localFoods.any((f) => f['name'].toString().contains('Bebek') || f['name'].toString().contains('Kedewatan')), isTrue);
      expect(ubud.localFoods.any((f) => f['name'].toString().contains('Rawon')), isFalse);

      // 5. Danau Toba specific
      expect(toba.attractions.any((a) => a['name'].toString().contains('Tomok') || a['name'].toString().contains('Sipiso-piso')), isTrue);
      expect(toba.localFoods.any((f) => f['name'].toString().contains('Arsik') || f['name'].toString().contains('Naniura')), isTrue);

      // 6. Raja Ampat specific
      expect(rajaAmpat.attractions.any((a) => a['name'].toString().contains('Piaynemo') || a['name'].toString().contains('Cape Kri')), isTrue);
      expect(rajaAmpat.localFoods.any((f) => f['name'].toString().contains('Papeda') || f['name'].toString().contains('Ulat Sagu')), isTrue);
      expect(rajaAmpat.localFoods.any((f) => f['name'].toString().contains('Mangut Beong')), isFalse);
    });
  });
}

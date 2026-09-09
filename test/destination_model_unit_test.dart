import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Database/destination_model.dart';
import 'package:project_tride/Database/database_tables.dart';

void main() {
  group('DestinationModel Unit Tests', () {
    test('Construct DestinationModel and convert toMap / toJson', () {
      final model = DestinationModel(
        id: 1,
        name: 'Candi Borobudur',
        location: 'Magelang, Jawa Tengah',
        description: 'Candi Buddha terbesar',
        image: 'https://example.com/borobudur.jpg',
        category: 'Budaya',
        rating: 4.9,
        estimatedBudget: 1800000,
        bestTime: 'Mei - Oktober',
        latitude: -7.607874,
        longitude: 110.203751,
        placeType: 'Pedesaan',
      );

      final map = model.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Candi Borobudur');
      expect(map['location'], 'Magelang, Jawa Tengah');
      expect(map['rating'], 4.9);
      expect(map['estimated_budget'], 1800000);
      expect(map[DestinationColumns.placeType], 'Pedesaan');

      final json = model.toJson();
      expect(json, equals(map));
    });

    test('Parse DestinationModel fromMap with tolerant numeric and string types', () {
      final dynamicMap = {
        'destination_id': '10',
        'name': '  Kepulauan Seribu  ',
        'location': ' DKI Jakarta ',
        'description': 'Wisata pulau ',
        'image': 'https://example.com/seribu.jpg',
        'category': 'Alam',
        'rating': '4.7',
        'budget': '1200000',
        'best_time': 'April - Oktober',
        'lat': '-5.5878',
        'lng': '106.5583',
        'place_type': 'Pantai',
      };

      final model = DestinationModel.fromMap(dynamicMap);
      expect(model.id, 10);
      expect(model.name, 'Kepulauan Seribu');
      expect(model.location, 'DKI Jakarta');
      expect(model.rating, 4.7);
      expect(model.estimatedBudget, 1200000);
      expect(model.latitude, -5.5878);
      expect(model.longitude, 106.5583);
      expect(model.placeType, 'Pantai');
    });

    test('DestinationModel copyWith updates fields correctly', () {
      final model = DestinationModel(
        id: 1,
        name: 'Bromo',
        location: 'Jawa Timur',
        description: 'Gunung berapi',
        image: 'https://example.com/bromo.jpg',
        category: 'Alam',
      );

      final updated = model.copyWith(
        rating: 4.9,
        placeType: 'Pegunungan',
      );

      expect(updated.id, 1);
      expect(updated.name, 'Bromo');
      expect(updated.rating, 4.9);
      expect(updated.placeType, 'Pegunungan');
    });

    test('DestinationModel equality and hashCode', () {
      final m1 = DestinationModel(
        id: 5,
        name: 'Karimunjawa',
        location: 'Jepara',
        description: 'Taman Nasional',
        image: 'https://example.com/kj.jpg',
        category: 'Bahari',
      );

      final m2 = DestinationModel(
        id: 5,
        name: 'Karimunjawa',
        location: 'Jepara, Jawa Tengah',
        description: 'Deskripsi berbeda',
        image: 'https://example.com/kj2.jpg',
        category: 'Bahari',
      );

      expect(m1 == m2, isTrue);
      expect(m1.hashCode, m2.hashCode);
    });
  });
}

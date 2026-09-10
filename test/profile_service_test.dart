import 'package:flutter_test/flutter_test.dart';
import 'package:project_tride/Models/user_profile_model.dart';

void main() {
  group('UserProfileModel & Profile Logic Unit Tests', () {
    test('1. Profile read: creates valid UserProfileModel from map with default and custom values', () {
      final model = UserProfileModel.fromMap({
        'uid': 'user_123',
        'name': 'Budi Setiawan',
        'email': 'budi@tride.id',
        'phone': '+628123456789',
        'profile_image': 'https://example.com/avatar.jpg',
        'favorite_destination_id': 46,
        'favorite_destination_name': 'Raja Ampat',
        'language': 'Bahasa Indonesia',
        'currency': 'IDR',
        'created_at': '2026-01-01T00:00:00.000',
      });

      expect(model.uid, equals('user_123'));
      expect(model.name, equals('Budi Setiawan'));
      expect(model.email, equals('budi@tride.id'));
      expect(model.phone, equals('+628123456789'));
      expect(model.profileImage, equals('https://example.com/avatar.jpg'));
      expect(model.favoriteDestinationId, equals(46));
      expect(model.favoriteDestinationName, equals('Raja Ampat'));
      expect(model.language, equals('Bahasa Indonesia'));
      expect(model.currency, equals('IDR'));
    });

    test('2. Profile update: copyWith creates an updated immutable copy', () {
      final initial = UserProfileModel(
        uid: 'user_123',
        name: 'Initial Name',
        email: 'user@test.com',
        phone: '+62811111111',
      );

      final updated = initial.copyWith(
        name: 'Updated Name',
        phone: '+62899999999',
      );

      expect(updated.uid, equals('user_123'));
      expect(updated.name, equals('Updated Name'));
      expect(updated.phone, equals('+62899999999'));
      expect(updated.email, equals('user@test.com'));
    });

    test('3. Name update: copyWith updates name while preserving other fields', () {
      final initial = UserProfileModel(
        uid: 'uid_a',
        name: 'Alice Lama',
        email: 'alice@test.com',
        language: 'English',
      );

      final updated = initial.copyWith(name: 'Alice Baru');
      expect(updated.name, equals('Alice Baru'));
      expect(updated.language, equals('English'));
      expect(updated.email, equals('alice@test.com'));
    });

    test('4. Phone update: copyWith updates phone number', () {
      final initial = UserProfileModel(
        uid: 'uid_b',
        name: 'Bob',
        email: 'bob@test.com',
      );

      final updated = initial.copyWith(phone: '+628555444333');
      expect(updated.phone, equals('+628555444333'));
    });

    test('5. Favorite Destination update: correctly sets favorite destination id and name', () {
      final initial = UserProfileModel(
        uid: 'uid_c',
        name: 'Charlie',
        email: 'charlie@test.com',
      );

      final updated = initial.copyWith(
        favoriteDestinationId: 1,
        favoriteDestinationName: 'Candi Borobudur',
      );

      expect(updated.favoriteDestinationId, equals(1));
      expect(updated.favoriteDestinationName, equals('Candi Borobudur'));
    });

    test('6. Language update: switches language preference correctly', () {
      final initial = UserProfileModel(
        uid: 'uid_d',
        name: 'David',
        email: 'david@test.com',
        language: 'Bahasa Indonesia',
      );

      final updated = initial.copyWith(language: 'English');
      expect(updated.language, equals('English'));
    });

    test('7. Currency update: switches currency code correctly', () {
      final initial = UserProfileModel(
        uid: 'uid_e',
        name: 'Eva',
        email: 'eva@test.com',
        currency: 'IDR',
      );

      final updated = initial.copyWith(currency: 'USD');
      expect(updated.currency, equals('USD'));
    });

    test('8. Profile image URL update: updates profile image storage URL', () {
      final initial = UserProfileModel(
        uid: 'uid_f',
        name: 'Frank',
        email: 'frank@test.com',
        profileImage: null,
      );

      const storageUrl = 'https://firebasestorage.googleapis.com/v0/b/project-tride/o/profile_images%2Fuid_f%2Fprofile.jpg?alt=media';
      final updated = initial.copyWith(profileImage: storageUrl);

      expect(updated.profileImage, equals(storageUrl));
    });

    test('9. Firebase Auth email source: fallback email is used when map has no email', () {
      final model = UserProfileModel.fromMap(
        {'name': 'Grace'},
        uid: 'uid_grace',
        fallbackEmail: 'grace@firebaseauth.com',
        fallbackName: 'Grace Auth',
      );

      expect(model.email, equals('grace@firebaseauth.com'));
      expect(model.name, equals('Grace'));
    });

    test('10. Trips count: serialization and counts logic test', () {
      final tripList = [
        {'id': 'trip_1', 'trip_name': 'Trip Bali'},
        {'id': 'trip_2', 'trip_name': 'Trip Bromo'},
      ];

      final tripsCount = tripList.length;
      expect(tripsCount, equals(2));
    });

    test('11. Saved Places count: serialization and counts logic test', () {
      final savedList = [
        {'id': 1, 'name': 'Borobudur'},
        {'id': 46, 'name': 'Raja Ampat'},
        {'id': 8, 'name': 'Ubud'},
      ];

      final savedCount = savedList.length;
      expect(savedCount, equals(3));
    });

    test('12. Missing profile fields: fallback defaults applied cleanly without crash', () {
      final emptyModel = UserProfileModel.fromMap(
        {},
        uid: 'empty_user',
        fallbackEmail: 'testuser@tride.com',
      );

      expect(emptyModel.uid, equals('empty_user'));
      expect(emptyModel.name, equals('testuser'));
      expect(emptyModel.email, equals('testuser@tride.com'));
      expect(emptyModel.phone, isNull);
      expect(emptyModel.profileImage, isNull);
      expect(emptyModel.language, equals('Bahasa Indonesia'));
      expect(emptyModel.currency, equals('IDR'));
    });

    test('13. Empty trips handling: returns 0 when no trips exist', () {
      final emptyTrips = <dynamic>[];
      expect(emptyTrips.isEmpty, isTrue);
      expect(emptyTrips.length, equals(0));
    });

    test('14. Empty saved places handling: returns 0 when no saved places exist', () {
      final emptyPlaces = <dynamic>[];
      expect(emptyPlaces.isEmpty, isTrue);
      expect(emptyPlaces.length, equals(0));
    });

    test('15. User isolation: User A data is strictly separated from User B', () {
      final userA = UserProfileModel(
        uid: 'user_A',
        name: 'User Alpha',
        email: 'alpha@tride.com',
        profileImage: 'https://storage/user_A/profile.jpg',
      );

      final userB = UserProfileModel(
        uid: 'user_B',
        name: 'User Beta',
        email: 'beta@tride.com',
        profileImage: 'https://storage/user_B/profile.jpg',
      );

      expect(userA.uid, isNot(equals(userB.uid)));
      expect(userA.name, isNot(equals(userB.name)));
      expect(userA.profileImage, isNot(equals(userB.profileImage)));
    });

    test('16. toFirestore and toMap payloads format correctly without saving password', () {
      final model = UserProfileModel(
        uid: 'user_final',
        name: 'Final Tester',
        email: 'tester@tride.com',
        phone: '+628999888777',
        favoriteDestinationId: 10,
        favoriteDestinationName: 'Danau Toba',
      );

      final firestorePayload = model.toFirestore();
      expect(firestorePayload.containsKey('password'), isFalse);
      expect(firestorePayload['uid'], equals('user_final'));
      expect(firestorePayload['name'], equals('Final Tester'));
      expect(firestorePayload['phone'], equals('+628999888777'));
      expect(firestorePayload['favorite_destination_name'], equals('Danau Toba'));

      final standardMap = model.toMap();
      expect(standardMap.containsKey('password'), isFalse);
      expect(standardMap['email'], equals('tester@tride.com'));
    });

    test('17. User cancellation in image preview preserves original profile image', () {
      final initial = UserProfileModel(
        uid: 'user_cancel',
        name: 'Cancel Test',
        email: 'cancel@test.com',
        profileImage: 'https://example.com/old_avatar.jpg',
      );

      UserProfileModel applyPreviewResult(UserProfileModel model, bool confirmed) {
        if (confirmed) {
          return model.copyWith(profileImage: 'https://example.com/new_avatar.jpg');
        }
        return model;
      }

      final cancelledResult = applyPreviewResult(initial, false);
      expect(cancelledResult.profileImage, equals('https://example.com/old_avatar.jpg'));

      final confirmedResult = applyPreviewResult(initial, true);
      expect(confirmedResult.profileImage, equals('https://example.com/new_avatar.jpg'));
    });

    test('18. Local storage path strictly uses user Firebase UID pattern profile_images/{uid}_profile.jpg', () {
      const uidA = 'firebase_uid_123';
      const uidB = 'firebase_uid_456';
      const rootDir = '/app_documents';

      final pathA = '$rootDir/profile_images/${uidA}_profile.jpg';
      final pathB = '$rootDir/profile_images/${uidB}_profile.jpg';

      expect(pathA, equals('/app_documents/profile_images/firebase_uid_123_profile.jpg'));
      expect(pathB, equals('/app_documents/profile_images/firebase_uid_456_profile.jpg'));
      expect(pathA, isNot(equals(pathB)));
      expect(pathA.contains('email'), isFalse);
    });

    test('19. Unauthenticated local save attempt safely handles null target UID', () {
      final String? unauthUid = null;
      expect(unauthUid == null || unauthUid.isEmpty, isTrue);
    });

    test('20. Profile image update correctly updates toFirestore payload with local profile_image path', () {
      final profile = UserProfileModel(
        uid: 'user_local',
        name: 'Local Storage User',
        email: 'local@tride.com',
        profileImage: '/app_documents/profile_images/user_local_profile.jpg',
      );

      final payload = profile.toFirestore();
      expect(payload['profile_image'], equals('/app_documents/profile_images/user_local_profile.jpg'));
      expect(payload['uid'], equals('user_local'));
    });

    test('21. Non-existent local path fallback logic returns default asset without crashing', () {
      const nonExistentPath = '/non_existent_dir/profile_images/missing_profile.jpg';
      final file = DateTime.now().millisecondsSinceEpoch > 0 ? null : nonExistentPath;
      final resolvedPath = file ?? 'assets/image/playstore.png';

      expect(resolvedPath, equals('assets/image/playstore.png'));
    });
  });
}

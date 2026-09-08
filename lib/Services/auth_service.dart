import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_tride/Database/database_helper.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/utils/session_manager.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
  final UserModel? userModel;

  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    this.userModel,
  });
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  User? get currentUser => _auth.currentUser;

  /// Mendaftarkan pengguna baru dengan Firebase Authentication & Firestore
  Future<AuthResult> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Buat user di Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. Perbarui Display Name di Firebase
        await user.updateDisplayName(name.trim());

        // 3. Simpan data user ke Cloud Firestore
        final userData = {
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'profile_image': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(
              userData,
              SetOptions(merge: true),
            );

        // 4. Simpan ke database lokal SQLite agar fitur offline/relasi tetap berfungsi
        UserModel? localUser;
        try {
          final modelToSave = UserModel(
            name: name.trim(),
            email: email.trim(),
            password: password,
          );
          final id = await DbHelper.instance.registerUser(modelToSave);
          if (id > 0) {
            localUser = modelToSave.copyWith(id: id);
          } else {
            localUser = await DbHelper.instance.getUserByEmail(email.trim());
          }
        } catch (_) {
          // Abaikan jika sudah ada di SQLite lokal
        }

        return AuthResult(
          isSuccess: true,
          user: user,
          userModel: localUser,
        );
      }

      return AuthResult(
        isSuccess: false,
        errorMessage: 'Gagal membuat akun. Silakan coba lagi.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _getReadableAuthErrorMessage(e.code, e.message),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Masuk dengan Firebase Authentication & sinkronisasi data user
  Future<AuthResult> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login dengan Firebase Authentication
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. Ambil profil pengguna dari Firestore (jika ada)
        String userName = user.displayName ?? '';
        String? profileImg = user.photoURL;

        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['name'] != null && (data['name'] as String).isNotEmpty) {
              userName = data['name'];
            }
            if (data['profile_image'] != null) {
              profileImg = data['profile_image'];
            }
          }
        } catch (_) {
          // Jika Firestore tidak dapat diakses (misal offline), gunakan fallback data
        }

        if (userName.isEmpty) {
          userName = email.trim().split('@').first;
        }

        // 3. Pastikan user tersimpan di SQLite lokal untuk session & relasi data
        UserModel? localUser =
            await DbHelper.instance.getUserByEmail(email.trim());

        if (localUser == null) {
          final newLocalUser = UserModel(
            name: userName,
            email: email.trim(),
            password: password,
            profileImage: profileImg,
          );
          final generatedId = await DbHelper.instance.insertUser(newLocalUser);
          localUser = newLocalUser.copyWith(id: generatedId);
        } else {
          // Update data lokal jika ada perubahan nama / profileImage dari server
          if (userName.isNotEmpty && localUser.nama != userName) {
            final updatedUser = localUser.copyWith(
              name: userName,
              profileImage: profileImg ?? localUser.profileImage,
            );
            await DbHelper.instance.updateUser(updatedUser);
            localUser = updatedUser;
          }
        }

        // 4. Simpan Session jika localUser valid
        if (localUser.id != null) {
          await SessionManager.saveSession(localUser.id!);
        }

        return AuthResult(
          isSuccess: true,
          user: user,
          userModel: localUser,
        );
      }

      return AuthResult(
        isSuccess: false,
        errorMessage: 'Gagal masuk. Silakan coba lagi.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _getReadableAuthErrorMessage(e.code, e.message),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Kirim link reset password ke email
  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _getReadableAuthErrorMessage(e.code, e.message),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Gagal mengirim email reset password: ${e.toString()}',
      );
    }
  }

  /// Keluar dari sesi login (Firebase & SQLite Session)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    await SessionManager.clearSession();
  }

  /// Menerjemahkan kode error Firebase Auth ke pesan yang mudah dipahami
  String _getReadableAuthErrorMessage(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan periksa kembali email Anda atau buat akun baru.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'invalid-credential':
        return 'Email atau password yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar! Silakan masuk atau gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan oleh administrator.';
      case 'operation-not-allowed':
        return 'Metode login ini belum diaktifkan di Firebase Console.';
      case 'weak-password':
        return 'Password terlalu lemah! Gunakan kombinasi minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan yang gagal. Harap tunggu beberapa saat.';
      default:
        return defaultMessage ??
            'Terjadi kesalahan pada autentikasi. Silakan coba lagi.';
    }
  }
}

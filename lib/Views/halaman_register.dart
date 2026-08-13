import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Constants/app_typography.dart';
import 'package:project_tride/Database/database_helper.dart';
import 'package:project_tride/Models/user_model.dart';
import 'package:project_tride/Views/halaman_login.dart';

class HalamanRegister extends StatefulWidget {
  const HalamanRegister({super.key});

  @override
  State<HalamanRegister> createState() => _HalamanRegisterState();
}

class _HalamanRegisterState extends State<HalamanRegister> {
  final TextEditingController namaC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool mata = false;
  bool mataConfirm = false;

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        nama: namaC.text.trim(),
        email: emailC.text.trim(),
        password: passwordC.text,
      );

      final result = await DatabaseHelper.instance.registerUser(newUser);

      if (!mounted) return;

      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email sudah terdaftar! Gunakan email lain."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan masuk."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HalamanLogin(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi gagal. Silakan coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
          child: Column(
            children: [
              const Image(
                image: AssetImage('assets/image/playstore.png'),
                height: 70,
                width: 70,
              ),
              const SizedBox(height: 20),
              Text("Buat Akun baru", style: AppTypography.displayLarge),
              const SizedBox(height: 10),
              Text(
                "Mulai perjalananmu bersama Tride hari ini",
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Nama Lengkap", style: AppTypography.bodyLarge),
                      ],
                    ),
                    TextFormField(
                      controller: namaC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Nama lengkap tidak boleh kosong";
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Masukkan nama lengkap',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [Text("Email", style: AppTypography.bodyLarge)],
                    ),
                    TextFormField(
                      controller: emailC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email tidak boleh kosong";
                        } else if (!value.contains('@')) {
                          return "Email tidak valid";
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Masukkan email kamu',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Password", style: AppTypography.bodyLarge),
                      ],
                    ),
                    TextFormField(
                      controller: passwordC,
                      obscureText: !mata,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password tidak boleh kosong";
                        } else if (value.length < 8) {
                          return "Password kurang dari 8 karakter";
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.key),
                        hintText: 'Masukkan kata sandi',
                        hintStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              mata = !mata;
                            });
                          },
                          icon: Icon(
                            mata ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Ulangi Password", style: AppTypography.bodyLarge),
                      ],
                    ),
                    TextFormField(
                      controller: confirmPasswordC,
                      obscureText: !mataConfirm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ulangi password tidak boleh kosong";
                        } else if (value != passwordC.text) {
                          return "Password tidak cocok";
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.key_outlined),
                        hintText: 'Ulangi Password',
                        hintStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              mataConfirm = !mataConfirm;
                            });
                          },
                          icon: Icon(
                            mataConfirm ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            AppColors.primary,
                          ),
                        ),
                        onPressed: _register,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: AppTypography.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HalamanLogin(),
                              ),
                            );
                          },
                          child: Text("Masuk", style: AppTypography.bodyLarge),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

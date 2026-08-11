import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Constants/app_typography.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool mata = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
          child: Column(
            children: [
              Image(
                image: AssetImage('assets/image/playstore.png'),
                height: 70,
                width: 70,
              ),
              SizedBox(height: 20),
              Text("Buat Akun baru", style: AppTypography.displayLarge),
              SizedBox(height: 10),
              Text(
                "Mulai perjalananmu bersama Tride hari ini",
                style: AppTypography.bodyLarge,
              ),
              SizedBox(height: 50),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email tidak boleh kosong";
                        } else if (!value.contains('@')) {
                          return "Email tidak valid";
                        }
                        return null;
                      },

                      controller: emailC,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Masukkan nama lengkap',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [Text("Email", style: AppTypography.bodyLarge)],
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email tidak boleh kosong";
                        } else if (!value.contains('@')) {
                          return "Email tidak valid";
                        }
                        return null;
                      },

                      controller: emailC,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Masukkan email kamu',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Password", style: AppTypography.bodyLarge),
                      ],
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password tidak boleh kosong";
                        } else if (value.length < 8) {
                          return "Password kurang dari 8 karakter";
                        }
                        return null;
                      },
                      controller: passwordC,
                      obscureText: mata,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.key),
                        hintText: 'masukan kata sandi',
                        hintStyle: TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              mata = !mata;
                            });
                          },
                          icon: Icon(
                            mata ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Ulangi Password", style: AppTypography.bodyLarge),
                      ],
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password tidak boleh kosong";
                        } else if (value.length < 8) {
                          return "Password kurang dari 8 karakter";
                        } else if (value == passwordC) {
                          return "Password tidak sesuai";
                        }
                        return null;
                      },
                      controller: passwordC,
                      obscureText: mata,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.key_outlined),
                        hintText: 'Ulangi Password',
                        hintStyle: TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              mata = !mata;
                            });
                          },
                          icon: Icon(
                            mata ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            AppColors.primary,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // login();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun",
                          style: AppTypography.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HalamanLogin(),
                                ),
                              );
                            });
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

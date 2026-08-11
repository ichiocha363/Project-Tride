import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_colors.dart';
import 'package:project_tride/Constants/app_typography.dart';
import 'package:project_tride/Views/halaman_register.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool mata = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
            child: Column(
              children: [
                Image(
                  image: AssetImage('assets/image/playstore.png'),
                  height: 70,
                  width: 70,
                ),
                SizedBox(height: 20),
                Text("Masuk ke Tride", style: AppTypography.displayLarge),
                SizedBox(height: 10),
                Text(
                  "Mulai petualanganmu hari ini",
                  style: AppTypography.bodyLarge,
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Email", style: AppTypography.bodyLarge),
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
                          prefixIcon: Icon(Icons.email_outlined),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Lupa Password?",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ],
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
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("atau"),
                          ),
                          Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/image/google.png'),
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Masuk dengan Google",
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 150),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun?"),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HalamanRegister(),
                                  ),
                                );
                              });
                            },
                            child: Text("Daftar"),
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
      ),
    );
  }
}

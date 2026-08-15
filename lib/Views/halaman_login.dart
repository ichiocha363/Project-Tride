import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_tride/Database/database_helper.dart';
import 'package:project_tride/Views/halaman beranda/halaman_beranda.dart';
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
  bool isLoading = false;

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final user = await DatabaseHelper.instance.loginUser(
        emailC.text.trim(),
        passwordC.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text("Selamat datang kembali, ${user.nama}!"),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF3E9C5D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanBeranda(user: user),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text("Email atau password tidak ditemukan!")),
              ],
            ),
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgNavy = Color(0xFF0F172A);
    const Color primaryBlue = Color(0xFF004AC6);
    const Color textLightBlue = Color(0xFFB4C5FF);
    const Color textAccentBlue = Color(0xFFC4E7FF);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Scrim & Blur
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: bgNavy.withValues(alpha: 0.55),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo Box
                            Container(
                              width: 72,
                              height: 72,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Image.asset(
                                'assets/image/playstore.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.explore,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Header Text
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Your next adventure awaits.",
                              style: TextStyle(
                                fontSize: 14,
                                color: textLightBlue,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Input Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text(
                                    "EMAIL ADDRESS",
                                    style: TextStyle(
                                      color: textLightBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: emailC,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Email tidak boleh kosong";
                                    } else if (!value.contains('@')) {
                                      return "Email tidak valid";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: textLightBlue,
                                    ),
                                    hintText: 'explorer@tride.com',
                                    hintStyle: TextStyle(
                                      color: textLightBlue.withValues(alpha: 0.6),
                                    ),
                                    filled: true,
                                    fillColor: bgNavy.withValues(alpha: 0.45),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.15),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.15),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Color(0xFFFFB4AB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Password Input Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(left: 4, bottom: 6),
                                      child: Text(
                                        "PASSWORD",
                                        style: TextStyle(
                                          color: textLightBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Silakan hubungi dukungan Tride untuk me-reset password.",
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Forgot?",
                                        style: TextStyle(
                                          color: textAccentBlue,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: passwordC,
                                  obscureText: !mata,
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Password tidak boleh kosong";
                                    } else if (value.length < 6) {
                                      return "Password minimal 6 karakter";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: textLightBlue,
                                    ),
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                      color: textLightBlue.withValues(alpha: 0.6),
                                    ),
                                    filled: true,
                                    fillColor: bgNavy.withValues(alpha: 0.45),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          mata = !mata;
                                        });
                                      },
                                      icon: Icon(
                                        mata
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: textLightBlue,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.15),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.15),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Color(0xFFFFB4AB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: textLightBlue,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HalamanRegister(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                      color: textAccentBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project_tride/Services/auth_service.dart';
import 'package:project_tride/Views/halaman_login.dart';
import 'package:project_tride/Views/halaman_privacy_policy.dart';
import 'package:project_tride/Views/halaman_terms_of_service.dart';

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
  bool agreeTerms = false;
  bool isLoading = false;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTermsOfService;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
  }

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HalamanTermsOfService()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HalamanPrivacyPolicy()),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (!agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Anda harus menyetujui Syarat dan Ketentuan Layanan.",
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFBC4800),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final result = await AuthService.instance.registerWithEmailPassword(
        name: namaC.text.trim(),
        email: emailC.text.trim(),
        password: passwordC.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Registrasi akun berhasil! Silakan masuk."),
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
          MaterialPageRoute(builder: (context) => const HalamanLogin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.errorMessage ??
                        "Registrasi gagal. Silakan coba lagi.",
                  ),
                ),
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
    const Color warmYellow = Color(0xFFFDB813);

    return Scaffold(
      backgroundColor: bgNavy,
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1200&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgNavy.withValues(alpha: 0.4),
                      bgNavy.withValues(alpha: 0.85),
                      bgNavy,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Registration Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Compass Icon Badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: const Icon(
                            Icons.explore_rounded,
                            color: warmYellow,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Text
                    const Text(
                      "Begin Your Journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Create an account to start planning your next great adventure.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textLightBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Full Name
                          _buildInputField(
                            controller: namaC,
                            hint: "Full Name",
                            icon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Nama lengkap tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email Address
                          _buildInputField(
                            controller: emailC,
                            hint: "Email Address",
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Email tidak boleh kosong";
                              } else if (!val.contains('@')) {
                                return "Email tidak valid";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
                          _buildInputField(
                            controller: passwordC,
                            hint: "Password",
                            icon: Icons.lock_outline_rounded,
                            obscureText: !mata,
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
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Password tidak boleh kosong";
                              } else if (val.length < 6) {
                                return "Password minimal 6 karakter";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirm Password
                          _buildInputField(
                            controller: confirmPasswordC,
                            hint: "Confirm Password",
                            icon: Icons.lock_reset_rounded,
                            obscureText: !mataConfirm,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  mataConfirm = !mataConfirm;
                                });
                              },
                              icon: Icon(
                                mataConfirm
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: textLightBlue,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Konfirmasi password tidak boleh kosong";
                              } else if (val != passwordC.text) {
                                return "Password tidak cocok";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Terms and Conditions Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: agreeTerms,
                                  onChanged: (val) {
                                    setState(() {
                                      agreeTerms = val ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF40C2FD),
                                  checkColor: bgNavy,
                                  side: BorderSide(
                                    color: textLightBlue.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: "I agree to the ",
                                    style: const TextStyle(
                                      color: textLightBlue,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Terms of Service",
                                        recognizer: _termsRecognizer,
                                        style: const TextStyle(
                                          color: textAccentBlue,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: textAccentBlue,
                                        ),
                                      ),
                                      const TextSpan(text: " and "),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        recognizer: _privacyRecognizer,
                                        style: const TextStyle(
                                          color: textAccentBlue,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: textAccentBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (isLoading || !agreeTerms) ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: primaryBlue.withValues(alpha: 0.35),
                                disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
                                elevation: agreeTerms ? 8 : 0,
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
                                          "Create Account",
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

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: textLightBlue,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HalamanLogin(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Log in here",
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    const Color textLightBlue = Color(0xFFB4C5FF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: textLightBlue),
            hintText: hint,
            hintStyle: TextStyle(
              color: textLightBlue.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
          ),
        ),
      ),
    );
  }
}

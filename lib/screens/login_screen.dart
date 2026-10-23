import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cek format email sederhana: teks, tanda @, teks, titik, lalu teks
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Login sederhana (tanpa server): email wajib diisi dan berformat benar,
    // password minimal 6 karakter
    if (email.isEmpty) {
      setState(() => _error = 'Email wajib diisi');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Format Email tidak valid');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Kata sandi minimal 6 karakter');
      return;
    }

    // Menghapus pesan error jika input sudah benar
    setState(() => _error = '');

    await context.read<AuthProvider>().login(email);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Border kolom input: radius 12 dengan garis tipis
  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // Satu kolom input lengkap dengan labelnya (komponen Field di Figma)
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: action,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 14, color: textPrimaryColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: textSecondaryColor),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, size: 20, color: textSecondaryColor),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: _border(borderColor, 1),
            enabledBorder: _border(borderColor, 1),
            focusedBorder: _border(primaryColor, 1.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
          child: Center(
            // Di layar lebar, form dibatasi 420 px dan berada di tengah
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Hero: logo, nama, tagline ---
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/logo.svg',
                        width: 88,
                        height: 88,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'SEHATYUK',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 36 / 28,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Informasi kesehatan terpercaya\ndalam genggamanmu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 22 / 14,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 52),

                  // --- Judul form ---
                  const Text(
                    'Masuk ke akun',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 30 / 22,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Email ---
                  _buildField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    icon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // --- Kata sandi ---
                  _buildField(
                    label: 'Kata sandi',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    action: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    suffix: GestureDetector(
                      onTap: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 16),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Lupa kata sandi ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: halaman lupa kata sandi (menunggu kesepakatan tim)
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa kata sandi?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  // --- Pesan error (hanya tampil jika ada) ---
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: errorColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: errorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: errorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // --- Tombol Masuk ---
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: textOnPrimaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Belum punya akun? Daftar ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(
                          fontSize: 14,
                          height: 22 / 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          // TODO: halaman daftar (menunggu kesepakatan tim)
                        },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: primaryColor,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

/// Layar Profil sederhana: info akun, tentang aplikasi, dan keluar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // Yang tersimpan sebagai "username" adalah email yang dipakai saat login
    final email = context.watch<AuthProvider>().username;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 30 / 22,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Kartu profil ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryLightColor,
                          child: Icon(
                            Icons.person_outline,
                            size: 28,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pengguna SEHATYUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 22 / 16,
                                  color: textPrimaryColor,
                                ),
                              ),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Tentang aplikasi ---
                  Material(
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: textSecondaryColor,
                      ),
                      title: const Text(
                        'Tentang aplikasi',
                        style: TextStyle(fontSize: 14, color: textPrimaryColor),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: textSecondaryColor,
                      ),
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'SEHATYUK',
                        applicationVersion: '1.0',
                        applicationLegalese:
                            'Aplikasi informasi kesehatan terpercaya dalam genggamanmu.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Keluar ---
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Keluar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(
                          color: errorColor.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
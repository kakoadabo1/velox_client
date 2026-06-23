import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nomade_client/services/auth_service.dart';
import 'package:nomade_client/services/notification_service.dart';
import 'package:nomade_client/screens/HomeScreen/home_screen_app.dart';

import '../../../constants.dart';
import 'sign_up_screen.dart';
import 'components/sign_in_form.dart';
import '../phoneLogin/phone_login_screen.dart';

// Palette locale (dark + lime, cohérente avec l'accueil)
const _kBg = Color(0xFF0E0E0E);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0xFF2E2E2E);
const _kLime = Color(0xFF9FFF88);
const _kHint = Color(0xFF8A8A8A);
const _kText = Color(0xFFF2F2F2);

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  bool _isLoadingGoogle = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        await NotificationService().refreshTokenForUser();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreenApp()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Logo + halo vert
              Center(
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kLime.withValues(alpha: 0.45),
                        blurRadius: 34,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo-velox.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Titre + sous-titre
              const Text(
                'Bienvenue sur VELOX',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecte-toi avec ton e-mail ou ton téléphone\npour commander.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kHint, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 30),

              // Formulaire e-mail / mot de passe
              const SignInForm(),
              const SizedBox(height: 22),

              // Séparateur "ou"
              Row(
                children: [
                  const Expanded(child: Divider(color: _kBorder, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou',
                        style: TextStyle(
                            color: _kHint.withValues(alpha: 0.8), fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: _kBorder, thickness: 1)),
                ],
              ),
              const SizedBox(height: 22),

              // Bouton Téléphone (contour)
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PhoneLoginScreen()),
                  ),
                  icon: const Icon(Icons.phone_android_rounded,
                      color: _kText, size: 20),
                  label: const Text(
                    'Continuer avec le téléphone',
                    style: TextStyle(
                        color: _kText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _kSurface,
                    side: const BorderSide(color: _kBorder, width: 1.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Bouton Google (blanc)
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoadingGoogle ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1A1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoadingGoogle
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/google.svg',
                                width: 20, height: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Continuer avec Google',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 26),

              // Lien inscription
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: _kHint, fontSize: 14),
                    text: 'Pas encore de compte ? ',
                    children: [
                      TextSpan(
                        text: 'Créer un compte',
                        style: const TextStyle(
                            color: _kLime, fontWeight: FontWeight.w800),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

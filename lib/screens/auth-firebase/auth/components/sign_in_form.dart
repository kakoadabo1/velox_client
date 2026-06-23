import 'package:flutter/material.dart';
import 'package:nomade_client/services/auth_service.dart';
import 'package:nomade_client/screens/HomeScreen/home_screen_app.dart';

import '../../../../constants.dart';
import '../../../../services/notification_service.dart';
import '../forgot_password_screen.dart';
import '../../../../translations/app_translations.dart';

// Palette locale (dark + lime, cohérente avec l'accueil)
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0xFF2E2E2E);
const _kLime = Color(0xFF9FFF88);
const _kOnLime = Color(0xFF0A2A0A);
const _kHint = Color(0xFF8A8A8A);
const _kText = Color(0xFFF2F2F2);

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.4),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kHint, fontSize: 15),
      prefixIcon: Icon(icon, color: _kHint, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _kSurface,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: border(_kBorder),
      focusedBorder: border(_kLime),
      errorBorder: border(Colors.red),
      focusedErrorBorder: border(Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Champ e-mail
          TextFormField(
            controller: _emailController,
            validator: emailValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: _kText, fontSize: 15),
            decoration: _decoration('Adresse e-mail', Icons.email_outlined),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 14),

          // Champ mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            validator: passwordValidator.call,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signIn(),
            style: const TextStyle(color: _kText, fontSize: 15),
            decoration: _decoration(
              'Mot de passe',
              Icons.lock_outline,
              suffix: IconButton(
                onPressed: () => setState(() => _obscureText = !_obscureText),
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _kHint,
                  size: 20,
                ),
              ),
            ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 10),

          // Mot de passe oublié
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                      color: _kLime, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Bouton Se connecter (primaire lime)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kLime,
                foregroundColor: _kOnLime,
                disabledBackgroundColor: _kLime.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(_kOnLime),
                      ),
                    )
                  : const Text(
                      'Se connecter',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

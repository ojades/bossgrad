import 'package:bossgrad/core/audio_service.dart';
import 'package:bossgrad/core/http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/boss_theme.dart';

class ParentAuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogin;

  const ParentAuthScreen({
    super.key,
    required this.onBack,
    required this.onLogin,
  });

  @override
  State<ParentAuthScreen> createState() => _ParentAuthScreenState();
}

class _ParentAuthScreenState extends State<ParentAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _displayName = 'Commander';

  @override
  void initState() {
    super.initState();
    AudioService().playBgm('auth.wav');
    _loadSavedIdentity();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Pre-fill the email if the device is bound to a parent
  Future<void> _loadSavedIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('parent_email');
    final savedName = prefs.getString('parent_name');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _displayName = savedName ?? 'Commander';
        _isLogin = true;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    if (!_isLogin && _nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_role', 'parent');

    try {
      UserCredential userCredential;

      if (_isLogin) {
        // LOGIN
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Retrieve display name directly from Firebase
        _displayName = userCredential.user?.displayName ?? 'Commander';
      } else {
        // SIGN UP
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Save display name to Firebase for future logins
        await userCredential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
        _displayName = _nameController.text.trim();
      }

      // Sync with Flask PostgreSQL Database
      final res = await HttpClient().dio.post(
        '/api/auth/parent/sync',
        data: {'display_name': _displayName},
      );

      final String parentId = res.data['id'];

      // Persist the rest of the identity locally
      await prefs.setString('parent_uid', parentId);
      await prefs.setString('parent_email', _emailController.text.trim());
      await prefs.setString('parent_name', _displayName);

      AudioService().stopBgm();
      if (mounted) {
        widget.onLogin();
      }
    } on DioException catch (e) {
      await prefs.remove('active_role');

      String errorMsg = 'Sync failed - ${dotenv.env['API_BASE_URL']} - ';
      if (e.response != null) {
        errorMsg += 'Server returned ${e.response?.statusCode}.';
      } else {
        errorMsg += 'Network error: ${e.type.name}';
      }

      debugPrint('Flask DB Sync Failed: ${e.message} - ${e.response?.data}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: BossColors.bossRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      await prefs.remove('active_role');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: BossColors.bossRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.32, 1.0],
            colors: [Color(0xFFFFF1A8), Color(0xFFFFF8DF), Color(0xFFE8DDFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: const Color(0xFFEADCF8), width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFCDBBE8), offset: Offset(0, 8)),
                    BoxShadow(
                      color: Color(0x294C2A82),
                      offset: Offset(0, 20),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => {
                        AudioService().playSfx('click.mp3'),
                        widget.onBack(),
                      },
                      child: const Text(
                        '‹ Choose another role',
                        style: TextStyle(
                          color: Color(0xFF697386),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEE8FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: theme.primaryAction,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PARENT MISSION CONTROL',
                                style: TextStyle(
                                  color: theme.primaryAction,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    color: Color(0xFF172033),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLogin
                                          ? 'Welcome back, \n'
                                          : 'Join the squad, \n',
                                    ),
                                    TextSpan(
                                      text: '$_displayName.',
                                      style: TextStyle(
                                        color: theme.primaryAction,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Enter your password to continue.'
                          : 'Create an account to track progress.',
                      style: const TextStyle(
                        color: Color(0xFF697386),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!_isLogin) ...[
                      const Text(
                        'Display Name',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        onChanged: (val) => setState(
                          () => _displayName = val.isEmpty ? 'Commander' : val,
                        ),
                        decoration: _inputDecoration(theme, 'e.g. Jordan'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Text(
                      'Email address',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        theme,
                        'commander@example.com',
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(theme, '••••••••'),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                AudioService().playSfx('click.mp3');
                                _authenticate();
                              },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryAction,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ).copyWith(
                              side: WidgetStateProperty.all(
                                const BorderSide(
                                  color: Color(0xFF4D2AB4),
                                  width: 0,
                                ),
                              ),
                            ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? 'Enter mission control'
                                        : 'Create account',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 14),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Login/Signup
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? "New here? Create an account"
                              : "Already have an account? Sign in",
                          style: TextStyle(
                            color: theme.primaryAction,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }

  InputDecoration _inputDecoration(BossGradTheme theme, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA49AB4), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8DEF5), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryAction, width: 2),
      ),
    );
  }
}

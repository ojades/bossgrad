import 'package:bossgrad/core/audio_service.dart';
import 'package:bossgrad/core/theme/boss_theme.dart';
import 'package:bossgrad/features/auth/child_auth_screen.dart';
import 'package:bossgrad/features/auth/parent_auth_screen.dart';
import 'package:bossgrad/features/auth/role_selection_screen.dart';
import 'package:bossgrad/features/child_hub/child_root_layout.dart';
import 'package:bossgrad/features/root_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await AudioService().init();

  runApp(const BossGradApp());
}

class BossGradApp extends StatelessWidget {
  const BossGradApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BossGrad',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Fredoka',
        scaffoldBackgroundColor: BossColors.backgroundSlate,
        extensions: const [
          BossGradTheme(
            primaryAction: BossColors.electricViolet,
            coinAccent: BossColors.arcadeYellow,
            background: BossColors.backgroundSlate,
            chunkyRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ],
      ),
      // We declare a named route so pushNamedAndRemoveUntil('/') works
      initialRoute: '/',
      routes: {'/': (context) => const AuthRouter()},
    );
  }
}

class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  final PageController _pageController = PageController(initialPage: 0);

  // Variables to ensure we only verify the user once per session load
  User? _lastCheckedUser;
  Future<String?>? _verificationFuture;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _slideCameraTo(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
  }

  /// Forces a server-side check of the cached token, AND retrieves the active role.
  Future<String?> _verifyUserAndRole(User user) async {
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'invalid-user-token') {
        await FirebaseAuth.instance.signOut();
        return null;
      }
    } catch (e) {
      // Network error, safe fallback
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_role'); // Returns 'parent', 'child', or null
  }

  Widget _buildAuthFlow() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        RoleSelectionScreen(
          onParentSelected: () => _slideCameraTo(1),
          onChildSelected: () => _slideCameraTo(2),
        ),
        ParentAuthScreen(
          onBack: () => _slideCameraTo(0),
          onLogin: () {
            // When login succeeds on a device that was ALREADY bound, the Firebase Stream
            // won't fire. We must manually trigger verification to pick up the new 'active_role'.
            if (FirebaseAuth.instance.currentUser != null) {
              setState(() {
                _verificationFuture = _verifyUserAndRole(
                  FirebaseAuth.instance.currentUser!,
                );
              });
            }
          },
        ),
        ChildAuthScreen(
          onBack: () => _slideCameraTo(0),
          onLogin: () {
            if (FirebaseAuth.instance.currentUser != null) {
              setState(() {
                _verificationFuture = _verifyUserAndRole(
                  FirebaseAuth.instance.currentUser!,
                );
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // NO LOCAL USER -> Show Auth Flow
        if (user == null) {
          return _buildAuthFlow();
        }

        // LOCAL USER DETECTED -> Run Verification
        if (_lastCheckedUser?.uid != user.uid || _verificationFuture == null) {
          _lastCheckedUser = user;
          _verificationFuture = _verifyUserAndRole(user);
        }

        return FutureBuilder<String?>(
          future: _verificationFuture,
          builder: (context, verifySnapshot) {
            // While checking the server and local storage, show a loading state
            if (verifySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final activeRole = verifySnapshot.data;

            // Route based on active role
            if (activeRole == 'parent') {
              return const RootLayout();
            } else if (activeRole == 'child') {
              return const ChildRootLayout();
            }

            // User is valid (device is bound), but NO active session (they logged out)
            return _buildAuthFlow();
          },
        );
      },
    );
  }
}

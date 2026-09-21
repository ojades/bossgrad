import 'package:bossgrad/core/audio_service.dart';
import 'package:bossgrad/core/http_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/boss_theme.dart';

class ChildAuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogin;

  const ChildAuthScreen({
    super.key,
    required this.onBack,
    required this.onLogin,
  });

  @override
  State<ChildAuthScreen> createState() => _ChildAuthScreenState();
}

class _ChildAuthScreenState extends State<ChildAuthScreen> {
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;

  String _pin = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AudioService().playBgm('auth.wav');
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString('parent_uid');

      // If the device isn't linked to a parent yet, fail gracefully.
      if (parentId == null) {
        if (mounted) {
          setState(() {
            _errorMessage =
                "Please log in as a Parent first to link this device.";
            _isLoading = false;
          });
        }
        return;
      }

      final res = await HttpClient().dio.get(
        '/api/auth/child/list?parent_id=$parentId',
      );

      if (mounted) {
        setState(() {
          _children = List<Map<String, dynamic>>.from(res.data);
          if (_children.isNotEmpty) {
            _selectedChild = _children.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load child profiles: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              "Please log in as a Parent first to link this device.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _authenticateChild() async {
    if (_selectedChild == null || _pin.length != 4) return;

    setState(() => _isLoading = true);

    try {
      final res = await HttpClient().dio.post(
        '/api/auth/child/login',
        data: {'child_id': _selectedChild!['id'], 'pin': _pin},
      );

      final String customToken = res.data['token'];

      // Sign into Firebase as the child
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_role', 'child');
      await prefs.setString(
        'child_name',
        res.data['display_name'] ?? _selectedChild!['name'],
      );
      await prefs.setString('child_id', _selectedChild!['id']);

      if (mounted) widget.onLogin();
    } catch (e) {
      debugPrint('Child Auth Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect PIN. Try again!'),
            backgroundColor: Color(0xFFFF6578),
          ),
        );
        setState(() {
          _pin = '';
          _isLoading = false;
        });
      }
    }
  }

  void _handlePinPress(String value) {
    if (_isLoading) return;

    setState(() {
      if (value == '<') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (value == 'GO') {
        if (_pin.length == 4) _authenticateChild();
      } else {
        if (_pin.length < 4) _pin += value;
      }
    });
  }

  Widget _buildAvatarIcon(String label) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B83FF), Color(0xFF5F44DC)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
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
                  vertical: 20,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
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
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null) ...[
                      const Icon(
                        LucideIcons.alertCircle,
                        color: Color(0xFFFF6578),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF241642),
                        ),
                      ),
                    ] else if (_isLoading && _children.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ] else ...[
                      // Header Row: Icon + Texts + Avatar Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1AE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.sports_esports_outlined,
                              color: Color(0xFF9C7200),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PLAYER LOGIN',
                                  style: TextStyle(
                                    color: Color(0xFF9C7200),
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
                                      const TextSpan(text: 'Ready to '),
                                      TextSpan(
                                        text: 'quest?',
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

                          // Dynamic Avatar Dropdown
                          if (_children.isNotEmpty)
                            PopupMenuButton<Map<String, dynamic>>(
                              tooltip: 'Select Player',
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (result) => setState(() {
                                _selectedChild = result;
                                _pin = ''; // Reset PIN on child switch
                              }),
                              itemBuilder: (BuildContext context) {
                                return _children.map((child) {
                                  return PopupMenuItem<Map<String, dynamic>>(
                                    value: child,
                                    child: Row(
                                      children: [
                                        _buildAvatarIcon(
                                          child['initials'] ?? 'P',
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          child['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF172033),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5BB),
                                  border: Border.all(
                                    color: theme.coinAccent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildAvatarIcon(
                                      _selectedChild?['initials'] ?? '?',
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF9C7200),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // PIN Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = _pin.length > index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? theme.primaryAction
                                  : Colors.transparent,
                              border: Border.all(
                                color: isFilled
                                    ? theme.primaryAction
                                    : const Color(0xFFCFC3DF),
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),

                      // PIN Pad
                      Column(
                        children: [
                          _PinRow(const ['1', '2', '3'], _handlePinPress),
                          const SizedBox(height: 8),
                          _PinRow(const ['4', '5', '6'], _handlePinPress),
                          const SizedBox(height: 8),
                          _PinRow(const ['7', '8', '9'], _handlePinPress),
                          const SizedBox(height: 8),
                          _PinRow(
                            const ['<', '0', 'GO'],
                            _handlePinPress,
                            isAction: true,
                            pinLength: _pin.length,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  final List<String> labels;
  final Function(String) onPress;
  final bool isAction;
  final int pinLength;
  final bool isLoading;

  const _PinRow(
    this.labels,
    this.onPress, {
    this.isAction = false,
    this.pinLength = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) {
        final isGo = label == 'GO';
        final canGo = isGo && pinLength == 4 && !isLoading;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                if (isLoading) return;
                onPress(label);
              },
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isGo
                      ? (canGo
                            ? const Color(0xFF28C995)
                            : const Color(0xFFE8DEF5))
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGo
                        ? (canGo ? const Color(0xFF18A77D) : Colors.transparent)
                        : const Color(0xFFE8DEF5),
                    width: 2,
                  ),
                  boxShadow: isGo && !canGo
                      ? []
                      : const [
                          BoxShadow(
                            color: Color(0xFFDFD1EF),
                            offset: Offset(0, 3),
                          ),
                        ],
                ),
                child: isGo
                    ? isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              color: canGo ? Colors.white : Colors.grey,
                              size: 18,
                            )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF172033),
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

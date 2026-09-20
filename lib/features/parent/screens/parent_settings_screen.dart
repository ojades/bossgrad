import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  bool _isLoading = true;
  String _displayName = '';

  List<dynamic> _subjects = [];
  List<dynamic> _grades = [];

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSettingsData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettingsData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _displayName = prefs.getString('parent_name') ?? 'Commander';
      _nameController.text = _displayName;

      final responses = await Future.wait([
        HttpClient().dio.get('/api/boss/subjects'),
        HttpClient().dio.get('/api/boss/grades'),
      ]);

      if (mounted) {
        setState(() {
          _subjects = responses[0].data;
          _grades = responses[1].data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == _displayName) return;

    try {
      await HttpClient().dio.post(
        '/api/auth/parent/sync',
        data: {'display_name': newName},
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('parent_name', newName);

      setState(() => _displayName = newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Color(0xFF28C995),
          ),
        );
      }
    } catch (e) {
      debugPrint('Profile update failed: $e');
    }
  }

  Future<void> _addSubject(String name) async {
    try {
      final res = await HttpClient().dio.post(
        '/api/boss/subjects',
        data: {'name': name},
      );
      setState(() => _subjects.add(res.data));
    } catch (e) {
      debugPrint('Add subject failed: $e');
    }
  }

  Future<void> _deleteSubject(String id) async {
    try {
      await HttpClient().dio.delete('/api/boss/subjects/$id');
      setState(() => _subjects.removeWhere((s) => s['id'] == id));
    } catch (e) {
      debugPrint('Delete subject failed: $e');
    }
  }

  Future<void> _addGrade(String name) async {
    try {
      final res = await HttpClient().dio.post(
        '/api/boss/grades',
        data: {'name': name, 'order_index': _grades.length},
      );
      setState(() => _grades.add(res.data));
    } catch (e) {
      debugPrint('Add grade failed: $e');
    }
  }

  Future<void> _deleteGrade(String id) async {
    try {
      await HttpClient().dio.delete('/api/boss/grades/$id');
      setState(() => _grades.removeWhere((g) => g['id'] == id));
    } catch (e) {
      debugPrint('Delete grade failed: $e');
    }
  }

  void _showAddDialog(String title, String hint, Function(String) onSubmit) {
    final TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        // 1. ADD SINGLE CHILD SCROLL VIEW HERE
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF756B91),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty) {
                          onSubmit(ctrl.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF172033),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 120,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO SECTION
          Row(
            children: [
              Icon(LucideIcons.settings, color: theme.primaryAction, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF241642),
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your profile, subjects, and grade levels.',
            style: TextStyle(
              color: Color(0xFF756B91),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // 2. PROFILE CARD
            _buildSettingsCard(
              title: 'Profile Information',
              icon: LucideIcons.user,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        labelStyle: const TextStyle(
                          color: Color(0xFF756B91),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryAction,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. SUBJECTS CARD
            _buildSettingsCard(
              title: 'Subjects Library',
              icon: LucideIcons.bookOpen,
              action: IconButton(
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: Color(0xFF28C995),
                ),
                onPressed: () => _showAddDialog(
                  'Add Subject',
                  'e.g. Computer Science',
                  _addSubject,
                ),
              ),
              child: _subjects.isEmpty
                  ? const Text(
                      'No subjects added yet.',
                      style: TextStyle(color: Color(0xFF756B91)),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _subjects
                          .map(
                            (s) => _buildPill(
                              s['name'],
                              () => _deleteSubject(s['id']),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // 4. GRADE LEVELS CARD
            _buildSettingsCard(
              title: 'Grade Levels',
              icon: LucideIcons.graduationCap,
              action: IconButton(
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: Color(0xFF28C995),
                ),
                onPressed: () => _showAddDialog(
                  'Add Grade Level',
                  'e.g. Primary 4',
                  _addGrade,
                ),
              ),
              child: _grades.isEmpty
                  ? const Text(
                      'No grade levels added yet.',
                      style: TextStyle(color: Color(0xFF756B91)),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _grades
                          .map(
                            (g) => _buildPill(
                              g['name'],
                              () => _deleteGrade(g['id']),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF7554F6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241642),
                    ),
                  ),
                ],
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPill(String label, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFEADFF7), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF241642),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE3E3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.x,
                size: 12,
                color: Color(0xFFFF6578),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

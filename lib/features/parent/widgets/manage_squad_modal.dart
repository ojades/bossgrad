import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';
import '../../../core/widgets/arcade_components.dart';

class ManageSquadModal extends StatefulWidget {
  final List<Map<String, dynamic>> childrenList;
  final VoidCallback onRefresh;

  const ManageSquadModal({
    super.key,
    required this.childrenList,
    required this.onRefresh,
  });

  @override
  State<ManageSquadModal> createState() => _ManageSquadModalState();
}

class _ManageSquadModalState extends State<ManageSquadModal> {
  bool _isEditing = false;
  bool _isProcessing = false;
  bool _isLoadingGrades = true;
  Map<String, dynamic>? _selectedChild;

  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  String? _selectedGrade;
  List<String> _gradeOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    try {
      final res = await HttpClient().dio.get('/api/boss/grades');
      if (mounted) {
        setState(() {
          _gradeOptions = (res.data as List)
              .map((g) => g['name'].toString())
              .toList();
          _isLoadingGrades = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load grades: $e');
      if (mounted) {
        setState(() => _isLoadingGrades = false);
      }
    }
  }

  void _openForm([Map<String, dynamic>? child]) {
    _selectedChild = child;
    if (child != null) {
      _nameController.text = child['name'];
      _pinController.text = '****';

      final childGrade = child['grade'];
      // Prevent Dropdown assertion errors if a child has a legacy grade not in the DB
      if (childGrade != null && !_gradeOptions.contains(childGrade)) {
        _gradeOptions.add(childGrade);
      }
      _selectedGrade = childGrade;
    } else {
      _nameController.clear();
      _pinController.clear();
      _selectedGrade = _gradeOptions.isNotEmpty ? _gradeOptions.first : null;
    }
    setState(() => _isEditing = true);
  }

  void _closeForm() {
    setState(() {
      _isEditing = false;
      _selectedChild = null;
    });
  }

  Future<void> _savePlayer() async {
    if (_nameController.text.isEmpty || _selectedGrade == null) return;
    if (!_isEditing && _pinController.text.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final headers = {'Authorization': 'Bearer $token'};

      // Auto-generate initials
      final initials = _nameController.text
          .trim()
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
          .toUpperCase();

      if (_selectedChild == null) {
        // CREATE
        await HttpClient().dio.post(
          '/api/auth/child/create',
          options: Options(headers: headers),
          data: {
            'display_name': _nameController.text.trim(),
            'grade_level': _selectedGrade,
            'pin': _pinController.text,
            'avatar_initials': initials,
          },
        );
      } else {
        // UPDATE
        await HttpClient().dio.put(
          '/api/auth/child/${_selectedChild!['id']}',
          options: Options(headers: headers),
          data: {
            'display_name': _nameController.text.trim(),
            'grade_level': _selectedGrade,
            'pin': _pinController.text == '****' ? null : _pinController.text,
            'avatar_initials': initials,
          },
        );
      }
      widget.onRefresh();
      _closeForm();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save player.')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deletePlayer(String childId) async {
    setState(() => _isProcessing = true);
    try {
      await HttpClient().dio.delete('/api/auth/child/$childId');
      widget.onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete player.')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Color(0xFFE5D9F4), width: 4)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'PLAYER SETUP' : 'SQUAD ROSTER',
                        style: const TextStyle(
                          color: Color(0xFF7447F5),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        _isEditing
                            ? (_selectedChild == null
                                  ? 'New Player'
                                  : 'Edit Player')
                            : 'Manage Squad',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF241642),
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, color: Color(0xFF756B91)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF4EFFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isEditing ? _buildForm(theme) : _buildRoster(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoster(BossGradTheme theme) {
    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        if (widget.childrenList.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              "No players found. Add one to begin!",
              style: TextStyle(
                color: Color(0xFF756B91),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ...widget.childrenList.map(
          (child) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEADFF7), width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                BossAvatar(
                  initials: child['initials'] ?? 'P',
                  colorType: child['color'] ?? 'violet',
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child['name'] ?? 'Unknown Player',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF241642),
                        ),
                      ),
                      Text(
                        child['grade'] ?? 'Unassigned Grade',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF756B91),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: Color(0xFF7447F5),
                  ),
                  onPressed: () => _openForm(child),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: Color(0xFFFF6578),
                  ),
                  onPressed: () => _deletePlayer(child['id']),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text(
              'Add Player',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F9F1),
              foregroundColor: const Color(0xFF16A47B),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BossGradTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Display Name'),
        _buildTextField(_nameController, 'e.g. Alex Junior'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Grade Level'),
                  _buildGradeDropdown(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Secret PIN (4 digits)'),
                  _buildTextField(_pinController, '••••', isPin: true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isProcessing ? null : _closeForm,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF756B91),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _savePlayer,
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryAction,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Color(0xFF4D2AB4), width: 0),
                      ),
                    ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Player',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFF241642),
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPin = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPin ? TextInputType.number : TextInputType.text,
      maxLength: isPin ? 4 : null,
      obscureText: isPin,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF241642),
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA4ADBB), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEADFF7), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7447F5), width: 2),
        ),
      ),
    );
  }

  Widget _buildGradeDropdown() {
    if (_isLoadingGrades) {
      return Container(
        height: 52, // Match approximate height of text field
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEADFF7), width: 2),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _gradeOptions.contains(_selectedGrade) ? _selectedGrade : null,
      icon: const Icon(
        LucideIcons.chevronDown,
        color: Color(0xFFA4ADBB),
        size: 18,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF241642),
      ),
      decoration: InputDecoration(
        hintText: 'Select grade',
        hintStyle: const TextStyle(color: Color(0xFFA4ADBB), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEADFF7), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7447F5), width: 2),
        ),
      ),
      items: _gradeOptions
          .map(
            (grade) =>
                DropdownMenuItem<String>(value: grade, child: Text(grade)),
          )
          .toList(),
      onChanged: (newValue) => setState(() => _selectedGrade = newValue),
    );
  }
}

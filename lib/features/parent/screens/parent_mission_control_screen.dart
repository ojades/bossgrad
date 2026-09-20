// /lib/features/parent/screens/parent_mission_control_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';

class ParentMissionControl extends StatefulWidget {
  const ParentMissionControl({super.key});

  @override
  State<ParentMissionControl> createState() => _ParentMissionControlState();
}

class _ParentMissionControlState extends State<ParentMissionControl> {
  bool _isLoading = false;

  // Dynamic Filters State
  String? _selectedGrade;
  String? _selectedSubject;
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _grades = [];

  List<dynamic> _bossLevels = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 1. Fetch Grades and Subjects from API
  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        HttpClient().dio.get('/api/boss/grades'),
        HttpClient().dio.get('/api/boss/subjects'),
      ]);

      if (mounted) {
        setState(() {
          _grades = List<Map<String, dynamic>>.from(responses[0].data);
          _subjects = List<Map<String, dynamic>>.from(responses[1].data);

          // Auto-select first items if available
          if (_grades.isNotEmpty) _selectedGrade = _grades.first['name'];
          if (_subjects.isNotEmpty) _selectedSubject = _subjects.first['name'];
        });

        // Only fetch levels if we actually have filters selected
        if (_selectedGrade != null && _selectedSubject != null) {
          await _fetchLevels();
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Failed to load filters: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLevels() async {
    if (_selectedGrade == null || _selectedSubject == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await HttpClient().dio.get(
        '/api/boss/list',
        queryParameters: {
          'grade_level': _selectedGrade,
          'subject': _selectedSubject,
        },
      );
      if (mounted) {
        setState(() {
          _bossLevels = res.data;
        });
      }
    } catch (e) {
      debugPrint('Failed to load levels: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBossLevel(String id, bool isActive) async {
    try {
      await HttpClient().dio.post(
        '/api/boss/$id/toggle',
        data: {'is_active': isActive},
      );
      final index = _bossLevels.indexWhere((l) => l['id'] == id);
      if (index != -1) {
        setState(() => _bossLevels[index]['is_active'] = isActive);
      }
    } catch (e) {
      debugPrint('Toggle failed: $e');
    }
  }

  Future<void> _toggleQuestion(
    String levelId,
    String questionId,
    bool isActive,
  ) async {
    try {
      await HttpClient().dio.post(
        '/api/boss/question/$questionId/toggle',
        data: {'is_active': isActive},
      );
      final levelIndex = _bossLevels.indexWhere((l) => l['id'] == levelId);
      if (levelIndex != -1) {
        final qIndex = (_bossLevels[levelIndex]['questions'] as List)
            .indexWhere((q) => q['id'] == questionId);
        if (qIndex != -1) {
          setState(
            () => _bossLevels[levelIndex]['questions'][qIndex]['is_active'] =
                isActive,
          );
        }
      }
    } catch (e) {
      debugPrint('Toggle failed: $e');
    }
  }

  void _openSubjectManager(BossGradTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubjectManagerModal(
        theme: theme,
        initialSubjects: _subjects,
        onUpdate: (newSubjects) {
          setState(() {
            _subjects = newSubjects;
            // Adjust selection if current subject was deleted
            final currentExists = _subjects.any(
              (s) => s['name'] == _selectedSubject,
            );
            if (!currentExists && _subjects.isNotEmpty) {
              _selectedSubject = _subjects.first['name'];
            } else if (_subjects.isEmpty) {
              _selectedSubject = null;
              _bossLevels = [];
            }
          });
          if (_selectedSubject != null) _fetchLevels();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 80, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.swords,
                        color: theme.primaryAction,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PARENT TOOLKIT · BOSS LIBRARY',
                        style: TextStyle(
                          color: theme.primaryAction,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        color: Color(0xFF241642),
                        letterSpacing: -2.0,
                      ),
                      children: [
                        const TextSpan(text: 'Manage '),
                        TextSpan(
                          text: 'boss levels.',
                          style: TextStyle(color: theme.primaryAction),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review generated questions, toggle visibility, and manage your subjects.',
                    style: TextStyle(
                      color: Color(0xFF756B91),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _openSubjectManager(theme),
                icon: const Icon(LucideIcons.settings2, size: 15),
                label: const Text(
                  'Manage Subjects',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF241642),
                  side: const BorderSide(color: Color(0xFFEADFF7), width: 2),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 2. FILTERS
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    theme,
                    value: _selectedGrade,
                    items: _grades.map((g) => g['name'].toString()).toList(),
                    hint: 'No Grades',
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedGrade = val);
                        _fetchLevels();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    theme,
                    value: _selectedSubject,
                    items: _subjects.map((s) => s['name'].toString()).toList(),
                    hint: 'No Subjects',
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSubject = val);
                        _fetchLevels();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. LEVELS LIST
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_bossLevels.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.ghost,
                      size: 48,
                      color: const Color(0xFFD8C9EB).withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No boss levels found for this subject.',
                      style: TextStyle(
                        color: Color(0xFF756B91),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._bossLevels.map(
              (level) => _BossLevelCard(
                theme: theme,
                levelData: level,
                onToggleLevel: (val) => _toggleBossLevel(level['id'], val),
                onToggleQuestion: (qId, val) =>
                    _toggleQuestion(level['id'], qId, val),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BossGradTheme theme, {
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value)
              ? value
              : (items.isNotEmpty ? items.first : null),
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFFAAB1BF), fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: theme.primaryAction,
          ),
          style: const TextStyle(
            color: Color(0xFF241642),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _BossLevelCard extends StatefulWidget {
  final BossGradTheme theme;
  final Map<String, dynamic> levelData;
  final ValueChanged<bool> onToggleLevel;
  final Function(String, bool) onToggleQuestion;

  const _BossLevelCard({
    required this.theme,
    required this.levelData,
    required this.onToggleLevel,
    required this.onToggleQuestion,
  });

  @override
  State<_BossLevelCard> createState() => _BossLevelCardState();
}

class _BossLevelCardState extends State<_BossLevelCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final questions = widget.levelData['questions'] as List<dynamic>? ?? [];
    final isLevelActive = widget.levelData['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLevelActive
              ? const Color(0xFFE5D9F4)
              : const Color(0xFFF1F2F6),
          width: 3,
        ),
        boxShadow: isLevelActive
            ? const [BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 6))]
            : null,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(21),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isLevelActive
                          ? const Color(0xFFFFF5B8)
                          : const Color(0xFFF1F2F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.swords,
                      color: isLevelActive
                          ? const Color(0xFFD89400)
                          : const Color(0xFFAAB1BF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.levelData['title'] ?? 'Unnamed Level',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isLevelActive
                                ? const Color(0xFF241642)
                                : const Color(0xFFAAB1BF),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${questions.length} questions attached',
                          style: TextStyle(
                            color: isLevelActive
                                ? const Color(0xFF756B91)
                                : const Color(0xFFAAB1BF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isLevelActive,
                    activeColor: const Color(0xFF28C995),
                    inactiveThumbColor: const Color(0xFFAAB1BF),
                    inactiveTrackColor: const Color(0xFFF1F2F6),
                    onChanged: widget.onToggleLevel,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    color: const Color(0xFFD8C9EB),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Questions List
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5D9F4), width: 2),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: questions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;
                  final isQActive = q['is_active'] ?? true;
                  final options = q['options'] as List<dynamic>? ?? [];
                  final correctIdx = q['correct_index'] as int? ?? 0;
                  final diagramSvg = q['diagram_svg'] as String?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isQActive ? const Color(0xFFF7F8FA) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEADFF7),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${idx + 1}.',
                          style: TextStyle(
                            color: widget.theme.primaryAction,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q['question_text'] ??
                                    q['question'] ??
                                    'Unknown Question',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isQActive
                                      ? const Color(0xFF241642)
                                      : const Color(0xFF9689AE),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ---> INTEGRATED SVG RENDERER <---
                              if (diagramSvg != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  height: 80, // Safe preview size
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.string(diagramSvg),
                                ),
                              ],

                              // ---> POLYMORPHIC OPTIONS MAPPER <---
                              ...options.asMap().entries.map((opt) {
                                final isCorrect = opt.key == correctIdx;
                                final prefix =
                                    '${String.fromCharCode(65 + opt.key)}. ';
                                Widget optionWidget;

                                if (opt.value is Map) {
                                  final optionData =
                                      opt.value as Map<String, dynamic>;
                                  final type = optionData['type'] ?? 'text';
                                  final value =
                                      optionData['value']?.toString() ?? '';

                                  if (type == 'svg') {
                                    optionWidget = Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          prefix,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isCorrect
                                                ? const Color(0xFF15966F)
                                                : const Color(0xFF756B91),
                                            fontWeight: isCorrect
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          height:
                                              24, // Constrain option SVG safely
                                          margin: const EdgeInsets.only(
                                            left: 4,
                                          ),
                                          child: SvgPicture.string(value),
                                        ),
                                      ],
                                    );
                                  } else {
                                    optionWidget = Text(
                                      '$prefix$value',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isCorrect
                                            ? const Color(0xFF15966F)
                                            : const Color(0xFF756B91),
                                        fontWeight: isCorrect
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                    );
                                  }
                                } else {
                                  // Legacy flat string option fallback
                                  optionWidget = Text(
                                    '$prefix${opt.value}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCorrect
                                          ? const Color(0xFF15966F)
                                          : const Color(0xFF756B91),
                                      fontWeight: isCorrect
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isCorrect
                                            ? LucideIcons.checkCircle2
                                            : LucideIcons.circle,
                                        size: 12,
                                        color: isCorrect
                                            ? const Color(0xFF28C995)
                                            : const Color(0xFFC3B3EE),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(child: optionWidget),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        Switch(
                          value: isQActive,
                          activeColor: widget.theme.primaryAction,
                          onChanged: (val) =>
                              widget.onToggleQuestion(q['id'], val),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// --- SUBJECT MANAGEMENT MODAL ---

class _SubjectManagerModal extends StatefulWidget {
  final BossGradTheme theme;
  final List<Map<String, dynamic>> initialSubjects;
  final ValueChanged<List<Map<String, dynamic>>> onUpdate;

  const _SubjectManagerModal({
    required this.theme,
    required this.initialSubjects,
    required this.onUpdate,
  });

  @override
  State<_SubjectManagerModal> createState() => _SubjectManagerModalState();
}

class _SubjectManagerModalState extends State<_SubjectManagerModal> {
  late List<Map<String, dynamic>> _subjects;
  final TextEditingController _ctrl = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _subjects = List.from(widget.initialSubjects);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final res = await HttpClient().dio.post(
        '/api/boss/subjects',
        data: {'name': text},
      );
      setState(() {
        _subjects.add(res.data);
        _ctrl.clear();
      });
      widget.onUpdate(_subjects);
    } catch (e) {
      debugPrint('Failed to add subject: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeSubject(String id) async {
    setState(() => _isProcessing = true);
    try {
      await HttpClient().dio.delete('/api/boss/subjects/$id');
      setState(() {
        _subjects.removeWhere((s) => s['id'] == id);
      });
      widget.onUpdate(_subjects);
    } catch (e) {
      debugPrint('Failed to delete subject: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Subjects',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Color(0xFF9689AE)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add or remove subjects. Changes map globally to your account.',
              style: TextStyle(color: Color(0xFF756B91), fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'New subject name...',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _addSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primaryAction,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _subjects.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No subjects added.",
                        style: TextStyle(color: Color(0xFFAAB1BF)),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFEADFF7),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subject['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF241642),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _isProcessing
                                  ? null
                                  : _removeSubject(subject['id']),
                              child: const Icon(
                                LucideIcons.trash2,
                                size: 16,
                                color: Color(0xFFFF6578),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

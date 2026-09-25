import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/audio_service.dart';
import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';

import '../widgets/boss_scanner/scanner_hero.dart';
import '../widgets/boss_scanner/upload_card.dart';
import '../widgets/boss_scanner/extract_card.dart';
import '../widgets/boss_scanner/generated_questions_card.dart';

class ParentBossScreen extends StatefulWidget {
  const ParentBossScreen({super.key});

  @override
  State<ParentBossScreen> createState() => _ParentBossScreenState();
}

class _ParentBossScreenState extends State<ParentBossScreen> {
  final List<XFile> _selectedImages = [];
  String? _uploadedImageUrl;
  bool _isProcessing = false;
  int _currentStep = 1;
  List<dynamic> _generatedQuestions = [];
  int? _generatedTimeLimit;

  // Mission Configuration State
  String? _selectedGrade;
  String? _selectedSubject;
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _subjects = [];
  final TextEditingController _topicController = TextEditingController();

  // Levels State
  List<dynamic> _existingLevels = [];
  String? _selectedLevelId;
  bool _isLoadingLevels = false;

  // ---> NEW: Retry State
  List<Map<String, dynamic>> _failedScans = [];
  String? _retryBossId;
  List<String> _remoteImages = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingLevels = true);
    try {
      final responses = await Future.wait([
        HttpClient().dio.get('/api/boss/grades'),
        HttpClient().dio.get('/api/boss/subjects'),
        HttpClient().dio.get('/api/scans/failed'), // Fetch Failed Scans
      ]);

      if (mounted) {
        setState(() {
          _grades = List<Map<String, dynamic>>.from(responses[0].data);
          _subjects = List<Map<String, dynamic>>.from(responses[1].data);
          _failedScans = List<Map<String, dynamic>>.from(responses[2].data);

          if (_grades.isNotEmpty) _selectedGrade = _grades.first['name'];
          if (_subjects.isNotEmpty) _selectedSubject = _subjects.first['name'];
        });

        if (_selectedGrade != null && _selectedSubject != null) {
          await _fetchLevels();
        } else {
          setState(() => _isLoadingLevels = false);
        }
      }
    } catch (e) {
      debugPrint('Failed to load filters: $e');
      if (mounted) setState(() => _isLoadingLevels = false);
    }
  }

  Future<void> _fetchFailedScansOnly() async {
    try {
      final res = await HttpClient().dio.get('/api/scans/failed');
      if (mounted) {
        setState(() {
          _failedScans = List<Map<String, dynamic>>.from(res.data);
        });
      }
    } catch (e) {
      debugPrint('Failed to load failed scans: $e');
    }
  }

  Future<void> _fetchLevels() async {
    if (_selectedGrade == null || _selectedSubject == null) return;

    setState(() => _isLoadingLevels = true);
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
          _existingLevels = res.data;
          _selectedLevelId = null;
          if (_retryBossId == null) _topicController.clear();
        });
      }
    } catch (e) {
      debugPrint('Failed to load levels: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLevels = false);
    }
  }

  // Load a failed scan into the Upload Card
  void _loadFailedScan(Map<String, dynamic> scan) {
    setState(() {
      _retryBossId = scan['id'];
      _selectedGrade = scan['grade_level'];
      _selectedSubject = scan['subject'];
      _selectedLevelId = scan['id'];
      _topicController.text = scan['title'] ?? '';

      final sourceImgs = scan['source_images'] as List<dynamic>? ?? [];
      _remoteImages = sourceImgs.map((i) => i.toString()).toList();
      _selectedImages.clear();

      _currentStep = 1;
      _generatedQuestions = [];
      _generatedTimeLimit = null;
    });
    // Ensure the dropdowns reflect the correct grade/subject combination
    _fetchLevels();
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          setState(() => _selectedImages.addAll(images));
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() => _selectedImages.add(image));
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _processImages() async {
    // ---> NEW: Retry Logic Fork
    if (_retryBossId != null) {
      setState(() {
        _isProcessing = true;
        _currentStep = 2;
      });

      try {
        final response = await HttpClient().dio.post(
          '/api/scans/$_retryBossId/retry',
        );

        if (mounted) {
          AudioService().playSfx('scan_success.wav'); // <--- PLAY SUCCESS
          setState(() {
            _generatedQuestions =
                response.data['boss_level']['questions'] ?? [];
            _generatedTimeLimit = response.data['time_limit'];
            _currentStep = 3;
            _isProcessing = false;
          });
        }
      } on DioException catch (e) {
        if (mounted) {
          AudioService().playSfx('scan_fail.wav'); // <--- PLAY FAIL
          setState(() {
            _isProcessing = false;
            _currentStep = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI is still unavailable. Please try again later.'),
            ),
          );
        }
      }
      return;
    }

    // Normal Upload Logic
    if (_selectedImages.isEmpty || _selectedGrade == null) return;

    setState(() {
      _isProcessing = true;
      _currentStep = 2;
    });

    try {
      final formData = FormData.fromMap({'grade_level': _selectedGrade});

      for (int i = 0; i < _selectedImages.length; i++) {
        final bytes = await _selectedImages[i].readAsBytes();
        formData.files.add(
          MapEntry(
            'images',
            MultipartFile.fromBytes(bytes, filename: 'scan_$i.jpg'),
          ),
        );
      }

      final response = await HttpClient().dio.post(
        '/api/scans/upload',
        data: formData,
      );

      if (mounted) {
        setState(() {
          _uploadedImageUrl = response.data['image_url'];

          if (response.data['status'] == 'failed') {
            AudioService().playSfx('scan_fail.wav');
            _currentStep = 1;
            _isProcessing = false;
            _clearImages();
            _fetchFailedScansOnly();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'AI busy. Scan safely queued for background processing!',
                ),
              ),
            );
          } else {
            AudioService().playSfx('scan_success.wav');
            _generatedQuestions = response.data['questions'] ?? [];
            _currentStep = 3;
            _isProcessing = false;
          }
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        AudioService().playSfx('scan_fail.wav');
        setState(() {
          _isProcessing = false;
          _currentStep = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate boss battle.')),
        );
      }
    }
  }

  Future<void> _deployBossBattle() async {
    // Normal Deploy Logic
    if (_selectedGrade == null || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a grade and subject first.'),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final topicTitle = _topicController.text.trim();
      await HttpClient().dio.post(
        '/api/boss/create',
        data: {
          'boss_level_id': _selectedLevelId,
          'grade_level': _selectedGrade,
          'subject': _selectedSubject,
          'title': topicTitle.isNotEmpty
              ? topicTitle
              : 'Level ${_existingLevels.length + 1}',
          'image_url': _uploadedImageUrl,
          'questions': _generatedQuestions,
          'time_limit': _generatedTimeLimit,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boss Battle Deployed!'),
            backgroundColor: Color(0xFF28C995),
          ),
        );
        setState(() {
          _currentStep = 1;
          _generatedQuestions = [];
          _selectedImages.clear();
          _uploadedImageUrl = null;
        });
        await _fetchLevels();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Deployment failed.')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _clearImages() {
    setState(() {
      _selectedImages.clear();
      _remoteImages.clear();
      _retryBossId = null;
      _uploadedImageUrl = null;
      _generatedQuestions = [];
      _currentStep = 1;
      _isProcessing = false;
      _topicController.clear();
      _generatedTimeLimit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 80, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScannerHero(theme: theme, currentStep: _currentStep),
          const SizedBox(height: 32),

          // Failed Scans Alert Queue
          if (_failedScans.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFB3BD), width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.alertTriangle,
                        color: Color(0xFFFF6578),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'ACTION REQUIRED: FAILED AI GENERATIONS',
                        style: TextStyle(
                          color: Color(0xFFFF6578),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _failedScans.length,
                      itemBuilder: (context, index) {
                        final scan = _failedScans[index];
                        final hasImage =
                            scan['source_images'] != null &&
                            (scan['source_images'] as List).isNotEmpty;

                        return GestureDetector(
                          onTap: () => _loadFailedScan(scan),
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _retryBossId == scan['id']
                                    ? const Color(0xFFFF6578)
                                    : const Color(0xFFFFD1D6),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFFFE3E6),
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F8FA),
                                    borderRadius: BorderRadius.circular(12),
                                    image: hasImage
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              scan['source_images'][0],
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: !hasImage
                                      ? const Icon(
                                          LucideIcons.image,
                                          color: Color(0xFFCFC3DF),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${scan['subject']} · ${scan['grade_level']}',
                                        style: const TextStyle(
                                          color: Color(0xFF756B91),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        scan['title'] ?? 'Draft Mission',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF241642),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Row(
                                        children: [
                                          Text(
                                            'Tap to Retry',
                                            style: TextStyle(
                                              color: Color(0xFFFF6578),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            LucideIcons.arrowRight,
                                            size: 10,
                                            color: Color(0xFFFF6578),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          SizedBox(
            height: 600,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: UploadCard(
                    theme: theme,
                    isProcessing: _isProcessing,
                    currentStep: _currentStep,
                    selectedGrade: _selectedGrade,
                    selectedSubject: _selectedSubject,
                    grades: _grades,
                    subjects: _subjects,
                    existingLevels: _existingLevels,
                    selectedLevelId: _selectedLevelId,
                    topicController: _topicController,
                    selectedImages: _selectedImages,
                    remoteImages: _remoteImages, // Passed down
                    isRetryMode: _retryBossId != null, // Passed down
                    onGradeChanged: (val) {
                      setState(() => _selectedGrade = val);
                      _fetchLevels();
                    },
                    onSubjectChanged: (val) {
                      setState(() => _selectedSubject = val);
                      _fetchLevels();
                    },
                    onLevelSelected: (val) =>
                        setState(() => _selectedLevelId = val),
                    onPickImages: _pickImages,
                    onProcessImages: _processImages,
                    onClearImages: _clearImages,
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: ExtractCard(
                    theme: theme,
                    currentStep: _currentStep,
                    isProcessing: _isProcessing,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          if (_currentStep == 3 && _generatedQuestions.isNotEmpty)
            GeneratedQuestionsCard(
              theme: theme,
              generatedQuestions: _generatedQuestions,
              isProcessing: _isProcessing,
              onDelete: (idx) =>
                  setState(() => _generatedQuestions.removeAt(idx)),
              onDeploy: _deployBossBattle,
            ),
        ],
      ),
    );
  }
}
